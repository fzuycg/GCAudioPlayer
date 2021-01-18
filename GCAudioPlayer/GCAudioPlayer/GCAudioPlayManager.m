//
//  GCAudioPlayManager.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import "UIView+Addtion.h"
#import "GCConstantMacro.h"
#import "XHToast.h"
#import <CallKit/CallKit.h>

@interface GCAudioPlayManager()<CXCallObserverDelegate>

@property (nonatomic, strong) GCAudioPlayNarrowView *narrowView;

@property (nonatomic, strong) GCAudioPlayViewController *fullScreenVC;

@property (nonatomic, strong) GCAudioModelArray *playAudioArray;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger timerSeconds;            //定时时间

@property (nonatomic, assign) BOOL isEndPlay;       //是否刚结束播放

@property (nonatomic, assign) CGYTimingType timeZone; //定时关闭方式

@property (nonatomic, assign) NSInteger orderPlayNum;        //正常顺序播放歌曲数

@property (nonatomic, strong) CXCallObserver *callCenter;

@property (nonatomic, assign) CGYAudioPlayerStyle playerStyle;  //播放模式
@property (nonatomic, assign) CGFloat rate;                     //播放速率

@end

@implementation GCAudioPlayManager{
    CGFloat _playViewY;
    NSArray *_playArray;
    NSInteger _playIndex;
}

+ (instancetype)sharedManager {
    static GCAudioPlayManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _oprationPlay = [[GCAudioPlayOpration alloc]init];
        self.callCenter = [[CXCallObserver alloc] init];
        [self.callCenter setDelegate:self queue:nil];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];//设置后台播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
        [self initAudioActionManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAudioPlayer) name:@"CGYAudioPlayerStopNotification" object:nil];
    }
    return self;
}

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    if (call.outgoing) {
        //电话接通
        if (!self.isPlaying) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self pausePlay];
            NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
            [userDefult setObject:@"1" forKey:@"isSystemStopPlay"];
            [userDefult synchronize];
        });
    }
}

-(void)initAudioActionManager{
    if (self.isPlaying) {
        [self pausePlay];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //耳机拔出，停止播放操作
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pausePlay];
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

- (void)audioInterruption:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict     valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber* seccondReason = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"收到中断，停止音频播放");
            if (!self.isPlaying) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pausePlay];
                NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
                [userDefult setObject:@"1" forKey:@"isSystemStopPlay"];
                [userDefult synchronize];
            });
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"系统中断结束");
            break;
    }
    switch ([seccondReason integerValue]) {
        case AVAudioSessionInterruptionOptionShouldResume:
            NSLog(@"恢复音频播放");
            break;
        default:
            break;
    }
}

//加载新资源播放信息
- (void)loadAudioSouceWithArray:(GCAudioModelArray *)audioArray {
    //废除之前的播放器对象
    if (_currentAudioPlayer != nil) {
        [_currentAudioPlayer stop];
        if(self.playerDidToEnd)self.playerDidToEnd(self.currentAudioPlayer);
        _currentAudioPlayer = nil;
    }
    _playAudioArray = audioArray;
    _playViewY = kScreenHeight-100-SafeAreaBottomHeight;
    _playIndex = 0;
    _currentPlayModel = [_oprationPlay playNewAudioQueueWithModelArray:_playAudioArray PlayIndex:_playIndex];
    if (_currentPlayModel == nil) return;
    //建立新的对象
    _currentAudioPlayer = [[GCAudioPlayer alloc]initWithAudioModel:_currentPlayModel];
    //处理block
    [self playerManagerCallbcak];
    //处理是否显示UI
    if (_playViewY == 0) {
        if (_narrowView != nil) [_narrowView removeFromSuperview];
    }else {
        if(_narrowView == nil) {
            //没有创建一次
            _orderPlayNum = 0;
            _narrowView = [[GCAudioPlayNarrowView alloc]initWithFrame:CGRectMake(4, kScreenHeight-100-SafeAreaBottomHeight, kScreenWidth-8, 50) AudioModel:_currentPlayModel];
            //初始化状态
            _narrowView.showState = ViewBegin;
            //处理回调
            [self narrowViewCallbcak];
            [[UIApplication sharedApplication].keyWindow addSubview:_narrowView];
        }else {
            //创建过更新UI
            [self updateNarrowInfoWithModel:_currentPlayModel];
        }
    }
}

#pragma mark -publicFunction
//开始播放当前音乐
- (void)beginCurrentPlay {
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    //播放
    [_currentAudioPlayer play];
    //有定时重新计时
    if(self.timerSeconds > 0 && self.timeZone == CGYTimingType_currentEnd) self.timerSeconds = [self totleTimeClockWithType:self.timeZone CurrentModel:self.currentPlayModel];
    if (!(_narrowView.showState == ViewShow || _narrowView.showState == ViewRight)) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.narrowView.top =  self->_playViewY;
            self.narrowView.showState = ViewShow;
        } completion:nil];
    }else {
        //已有显示更新UI
        [self updateNarrowInfoWithModel:_currentPlayModel];
        [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
    }
    if (!self.isRunning) [self createRemoteCommandCenter];
    self.isRunning = YES;
}

//开始播放当前队列的第一首歌
- (void)beginPlayFirstAudio {
    [self beginPlayTagAudioWithIndex:0 NarrowViewStatue:_narrowView.showState];
}

//播放当前队列指定下标
- (void)beginPlayTagAudioWithIndex:(NSInteger)index NarrowViewStatue:(ViewShowState)statue{
    _currentPlayModel = [_oprationPlay getIndexModelWith:index];
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    //播放
    [_currentAudioPlayer playAudioWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentAudioPlayer play];
    //有定时重新计时
    if(self.timerSeconds > 0 && self.timeZone == CGYTimingType_currentEnd) self.timerSeconds = [self totleTimeClockWithType:self.timeZone CurrentModel:self.currentPlayModel];
    //展示UI
    if (statue == ViewFull) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.narrowView.top = self->_playViewY;
            self.narrowView.showState = ViewShow;
        } completion:nil];
        //开始播放马上进入播放页面
        if(self.narrowView.bgImageViewTapAction) self.narrowView.bgImageViewTapAction();
    }else if (statue == ViewBegin) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.narrowView.top = self->_playViewY;
            self.narrowView.showState = ViewShow;
        } completion:nil];
    } else {
        //已有显示更新UI
        [self updateNarrowInfoWithModel:_currentPlayModel];
        [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
    }
    if (!self.isRunning) [self createRemoteCommandCenter];
    self.isRunning = YES;
}

//播放下一首
- (void)playNextAudio {
    if (_playerStyle == CGYAudioPlayerStyle_cyclic || _playAudioArray.count == 1) {
        [_currentAudioPlayer replay];
        self.fullScreenVC.isPlaying = YES;
        return;
    }else if (_playerStyle == CGYAudioPlayerStyle_list) {
        _currentPlayModel = [_oprationPlay getNextModel];
    }else if (_playerStyle == CGYAudioPlayerStyle_random) {
        _currentPlayModel = [_oprationPlay getNextRandomModel];
    }
    
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentAudioPlayer);
    //播音乐
    [_currentAudioPlayer playAudioWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentAudioPlayer play];
    //处理UI显示
    [self updateNarrowInfoWithModel:_currentPlayModel];
    //初始播放当前进度调整为0
    self.fullScreenVC.currentProgress = 0;
    //更新数据
    [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
}

//播放上一首
- (void)playFormerAudio {
    if (_playerStyle == CGYAudioPlayerStyle_cyclic || _playAudioArray.count == 1) {
        [_currentAudioPlayer replay];
        self.fullScreenVC.isPlaying = YES;
        return;
    }
    _currentPlayModel = [_oprationPlay getFormerModel];
    if (_currentPlayModel == nil) return;
    self.isEndPlay = YES;
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentAudioPlayer);
    //播音乐
    [_currentAudioPlayer playAudioWithModel:_currentPlayModel PlayStatue:self.isRunning];
    [_currentAudioPlayer play];
    //处理UI显示
    [self updateNarrowInfoWithModel:_currentPlayModel];
    //初始播放当前进度调整为0
    self.fullScreenVC.currentProgress = 0;
    //更新数据
    [self updateFullScreenVCInfoWithModel:_currentPlayModel PlayStatue:YES];
}

//暂停当前音乐的播放
- (void)pausePlay {
    if (_currentAudioPlayer.isPlaying) {
        [_currentAudioPlayer pause];
        if (self.fullScreenVC != nil)self.fullScreenVC.isPlaying = NO;
        //停止计时
        if (self.timeZone == CGYTimingType_currentEnd) [self deallocTimer];
    }
}

//继续播放当前音乐
- (void)continuePlayCurrentAudio {
    if (_currentAudioPlayer.playState == ICAudioPlayerStatePaused || _currentAudioPlayer.playState == ICAudioPlayerStateReady){
        [_currentAudioPlayer play];
        if (self.fullScreenVC != nil) self.fullScreenVC.isPlaying = YES;
        //开始计时
        if(self.timerSeconds > 0) [self creatNewTimerWithBeginTime:self.timerSeconds];
    }
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if (time > _currentPlayModel.audioLength) return;
    [self.currentAudioPlayer seekToTime:time completionHandler:completionHandler];
}
//结束播放，结束队列播放，清空资源
- (void)stopPlay {
    if (self.currentAudioPlayer) [_currentAudioPlayer stop];
    [self.oprationPlay removeAllSelectData];
    _currentPlayModel = nil;
    _timerSeconds = 0;
    _orderPlayNum = 0;
    self.isRunning = NO;
    self.isEndPlay = YES;
    if (self.narrowView != nil) {
        [self.narrowView removeFromSuperview];
        self.narrowView = nil;
    }
    if (self.fullScreenVC != nil) {
        [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
        self.fullScreenVC = nil;
    }
    [self deallocTimer];
    //去除远程控制
    [self closeRemoteCommandCenter];
    if(self.playerDidToEnd)self.playerDidToEnd(self.currentAudioPlayer);
    if(self.playerClosed)self.playerClosed();
}
- (void)showNorrowView {
    [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
}
- (void)hiddenNorrowView {
    if(self.narrowView) {
        self.narrowView.showState = ViewHidden;
        self.narrowView.hidden = YES;
    }
}
#pragma mark - private
//加载计时器
- (void)creatNewTimerWithBeginTime:(NSInteger )beginTime {
    self.timerSeconds = beginTime;
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
//注销计时器
- (void)deallocTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
//更新小屏显示信息(开始播放)
- (void)updateNarrowInfoWithModel:(GCAudioPlayModel *)model {
    if (self.narrowView == nil) return;
    //开始播放IsPlaying设为yes
    [self.narrowView updateNewAudioWithModel:model IsPlaying:YES];
}
//更新全屏显示控制器信息
- (void)updateFullScreenVCInfoWithModel:(GCAudioPlayModel *)model PlayStatue:(BOOL)isPlaying{
    if (self.fullScreenVC == nil) return;
    self.fullScreenVC.playerStyle = self.playerStyle;
    self.fullScreenVC.rate = self.rate ? : 1.0;
    self.fullScreenVC.overPlayNum = self.orderPlayNum;
    self.fullScreenVC.audioArray = self.playAudioArray;
    self.fullScreenVC.isPlaying = isPlaying;
    self.fullScreenVC.isLastAudio = self.oprationPlay.isLastData;
    self.fullScreenVC.isFirstAudio = self.oprationPlay.isFirstData;
    self.fullScreenVC.buffingProgress = self.currentAudioPlayer.bufferTime;
    self.fullScreenVC.currentProgress = self.currentAudioPlayer.currentTime;
    self.fullScreenVC.totleTime = self.currentPlayModel.audioLength;
    self.fullScreenVC.shareArray = self.shareArray;
    self.fullScreenVC.selectTimeZone = self.timerSeconds > 0 ? self.timeZone : CGYTimingType_noOpen;
    if(self.timerSeconds > 0) self.fullScreenVC.clockTime = self.timerSeconds;
    //最后处理model，
    self.fullScreenVC.currentModel = model;
}

//计算定时
- (NSInteger)totleTimeClockWithType:(CGYTimingType)type CurrentModel:(GCAudioPlayModel *)model{
    NSInteger clockSum = 0;
    switch (type) {
        case CGYTimingType_noOpen:
            clockSum = 0;
            break;
        case CGYTimingType_currentEnd:
            clockSum = model.audioLength - self.currentAudioPlayer.currentTime;
            break;
        case CGYTimingType_oneMoment:
            clockSum = 15*60;
            break;
        case CGYTimingType_twoMoment:
            clockSum = 30*60;
            break;
        case CGYTimingType_fourMoment:
            clockSum = 60*60;
            break;
        default:
            break;
    }
    return clockSum;
}

//播放结束
- (void)timeOverPlayStop {
    [XHToast showToastVieWiththContent:@"播放已结束"];
    self.timeZone = CGYTimingType_noOpen;
    self.timerSeconds = 0;
    self.orderPlayNum = 0;
    self.fullScreenVC.selectTimeZone = CGYTimingType_noOpen;
    self.fullScreenVC.clockTime = 0;
    self.fullScreenVC.overPlayNum = 0;
    //定时器到时间
    [self pausePlay];
}

#pragma mark - get
- (NSTimeInterval)buffingProgress {
    return self.currentAudioPlayer.bufferTime;
}
- (NSTimeInterval)currentTime {
    return self.currentAudioPlayer.currentTime;
}
- (NSTimeInterval)totalTime {
    return self.currentPlayModel.audioLength;
}
- (NSInteger)currentPlayIndex {
    return self.oprationPlay.currentPlayIndex;
}
- (BOOL)isLastAudio {
    return self.oprationPlay.isLastData;
}
- (BOOL)isFirstAudio {
    return self.oprationPlay.isFirstData;
}
- (BOOL)isPlaying {
    return self.currentAudioPlayer.isPlaying;
}
- (BOOL)isClosePlay {
    return  _currentPlayModel == nil ? YES : NO;
}
#pragma mark - playerBlock
- (void)playerManagerCallbcak {
    @weakify(self)
    self.currentAudioPlayer.playerPrepareToPlay = ^(id object, GCAudioPlayModel *model) {
        @strongify(self)
        if (self.playerPrepareToPlay) self.playerPrepareToPlay(object,model);
    };
    
    self.currentAudioPlayer.playerReadyToPlay = ^(id object, GCAudioPlayModel *model) {
        @strongify(self)
        //准备播放，开启动画
        if (self.playerReadyToPlay) self.playerReadyToPlay(object,model);
    };
    
    self.currentAudioPlayer.playerPlayTimeChanged = ^(id object, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)

        if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(object,currentTime,duration);
        if (self.fullScreenVC != nil) {
            self.fullScreenVC.currentProgress = currentTime;
            self.fullScreenVC.totleTime = duration;
        }
        if (self.narrowView != nil) {
            [self.narrowView updateCurrentProgress:currentTime totleTime:duration];
        }
        
        if (!self.currentPlayModel) return;
        //重置结束状态
        self.isEndPlay = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            //显示锁屏播放信息
            GCAudioPlayer *player = object;
            GCAudioPlayModel *model = player.currentPlayModel;
            if (model == nil) return;
            NSMutableDictionary * audioDic = [[NSMutableDictionary alloc] init];
            //设置歌曲题目
            [audioDic setObject:model.audioTitle forKey:MPMediaItemPropertyTitle];
            //设置歌手名
            NSString *teacherName = model.audioAuthor;
            [audioDic setObject:teacherName forKey:MPMediaItemPropertyArtist];
            //设置专辑名
            [audioDic setObject:model.audioAlbum forKey:MPMediaItemPropertyAlbumTitle];
            //设置歌曲时长
            [audioDic setObject:[NSNumber numberWithDouble:duration]  forKey:MPMediaItemPropertyPlaybackDuration];
            //设置已经播放时长
            [audioDic setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            //设置播放速率
            [audioDic setObject:[NSNumber numberWithInteger:player.rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
            //设置显示的海报图片
            MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(250, 250) requestHandler:^UIImage * _Nonnull(CGSize size) {
                return model.coverImage;
            }];
            [audioDic setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:audioDic];
        });
    };
    
    self.currentAudioPlayer.playerBufferTimeChanged = ^(id object, NSTimeInterval bufferTime) {
        @strongify(self)
        if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(object,bufferTime);
        //处理缓冲进度条UI
        if (self.fullScreenVC != nil) {
            self.fullScreenVC.buffingProgress = bufferTime;
        }
    };
    
    self.currentAudioPlayer.playerPlayStateChanged = ^(id object, ICAudioPlayerState playState) {
        @strongify(self)
        if (self.playerPlayStateChanged) self.playerPlayStateChanged(object, playState);
    };
    
    self.currentAudioPlayer.playerLoadStateChanged = ^(id object, ICPlayerLoadState loadState) {
        @strongify(self)
        if (self.playerLoadStateChanged) self.playerLoadStateChanged(object, loadState);
    };
    
    self.currentAudioPlayer.playerDidToEnd = ^(id object) {
        @strongify(self)
        //播放下一首
        self.isEndPlay = YES;
        if (self.timeZone == CGYTimingType_currentEnd) self.orderPlayNum += 1;
        if (self.oprationPlay.isLastData && self.playerStyle == CGYAudioPlayerStyle_list) {
            //已经是最后一首
            if (self.timeZone != CGYTimingType_currentEnd && self.timeZone != CGYTimingType_currentEnd) {
                [XHToast showToastVieWiththContent:@"播放已结束"];
                [self pausePlay];
            }else {
                [self timeOverPlayStop];
            }
            self.fullScreenVC.currentProgress = 0;
            [self seekToTime:0 completionHandler:nil];
        }else {
            [self playNextAudio];
        }
        if (self.playerDidToEnd) self.playerDidToEnd(object);
    };
    
    self.currentAudioPlayer.playerPlayFailed = ^(id object, id  _Nonnull error) {
        @strongify(self)
        NSLog(@"---------播放出错error:%@--------",error);
        if (self.playerPlayFailed) self.playerPlayFailed(object, error);
    };
}

//锁屏界面开启和监控远程控制事件
- (void)createRemoteCommandCenter{
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    //耳机线控的暂停/播放
    commandCenter.togglePlayPauseCommand.enabled = YES;
    __weak typeof(self) weakSelf = self;
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (weakSelf.isPlaying) {
            [weakSelf.currentAudioPlayer pause];
        }else {
            [weakSelf.currentAudioPlayer play];
        }
        if (weakSelf.fullScreenVC) weakSelf.fullScreenVC.isPlaying = weakSelf.isPlaying;
        if (weakSelf.narrowView) weakSelf.narrowView.isPlaying = weakSelf.isPlaying;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentAudioPlayer pause];
        if (weakSelf.fullScreenVC) weakSelf.fullScreenVC.isPlaying = NO;
        if (weakSelf.narrowView) weakSelf.narrowView.isPlaying = NO;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.stopCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentAudioPlayer stop];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [weakSelf.currentAudioPlayer play];
        if (weakSelf.fullScreenVC) weakSelf.fullScreenVC.isPlaying = YES;
        if (weakSelf.narrowView) weakSelf.narrowView.isPlaying = YES;
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"上一首");
        if (!weakSelf.isFirstAudio){
            [weakSelf playFormerAudio];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"下一首");
        if (!weakSelf.isLastAudio) {
            [weakSelf playNextAudio];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    //在控制台拖动进度条调节进度
    [commandCenter.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        [weakSelf.currentAudioPlayer seekToTime: playbackPositionEvent.positionTime  completionHandler:^(BOOL finished) {
        
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
}

//关闭远程控制中心
- (void)closeRemoteCommandCenter {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.pauseCommand removeTarget:self];
    [commandCenter.playCommand removeTarget:self];
    [commandCenter.previousTrackCommand removeTarget:self];
    [commandCenter.nextTrackCommand removeTarget:self];
    [commandCenter.changePlaybackPositionCommand removeTarget:self];
    commandCenter = nil;
}

#pragma mark - narrowViewBlock
- (void)narrowViewCallbcak {
    @weakify(self)
    self.narrowView.bgImageViewTapAction = ^{
        //点击背景，展示全图
        @strongify(self)
        self.narrowView.hidden = YES;
        self.narrowView.showState = ViewHidden;
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC.presentedViewController != nil) {
            [rootVC.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
        self.fullScreenVC = [[GCAudioPlayViewController alloc]init];
        [self updateFullScreenVCInfoWithModel:self.currentPlayModel PlayStatue:self.currentAudioPlayer.isPlaying];
        [self fullScreenVCCallbcak];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.fullScreenVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [rootVC presentViewController:nav animated:YES completion:nil];
    };
    self.narrowView.hideBtnAction = ^(BOOL buttenSeleted) {
        //点击右缩按钮
        @strongify(self)
        if (buttenSeleted) {
            //缩进
            [UIView animateWithDuration:0.3 animations:^{
                self.narrowView.left = 24 - self.narrowView.width;
                self.narrowView.showState = ViewRight;
            }];
        }else {
            //展开
            [UIView animateWithDuration:0.3 animations:^{
                self.narrowView.left = (kScreenWidth - self.narrowView.width)/2;
                self.narrowView.showState = ViewShow;
            }];
        }
    };
    self.narrowView.playBtnAction = ^(BOOL buttenSeleted) {
        //点击播放按钮
        @strongify(self)
        if (buttenSeleted) {
            //暂停
            [self pausePlay];
        }else {
            //播放
            [self continuePlayCurrentAudio];
        }
    };
    self.narrowView.closeBtnAction = ^{
        //关闭小的播放展示器
        @strongify(self)
        [UIView animateWithDuration:0.3 animations:^{
            self.narrowView.top = kScreenHeight;
            self.narrowView.showState = ViewHidden;
        }completion:^(BOOL finished) {
            [self stopPlay];
        }];
    };
}

#pragma mark - fullScreenVCCallbcak
- (void)fullScreenVCCallbcak {
    @weakify(self)
    self.fullScreenVC.closeBtnAction = ^(GCAudioPlayModel * _Nonnull currentModel, NSTimeInterval seconds, CGYTimingType selectTimeZone,BOOL isPlaying) {
        @strongify(self)
        //处理显示
        self.currentPlayModel = currentModel;
        self.narrowView.hidden = NO;
        self.narrowView.showState = ViewShow;
        [self.narrowView updateNewAudioWithModel:currentModel IsPlaying:isPlaying];
        self.fullScreenVC = nil;
        self.timeZone = selectTimeZone;
    };

    self.fullScreenVC.formerBtnAction = ^(CGYTimingType selectTimeZone){
        @strongify(self)
        //上一首
        self.timeZone = selectTimeZone;
        [self playFormerAudio];
    };
    self.fullScreenVC.nextBtnAction = ^(CGYTimingType selectTimeZone) {
        @strongify(self)
        //下一首
        self.timeZone = selectTimeZone;
        [self playNextAudio];
    };
    self.fullScreenVC.playBtnAction = ^(BOOL buttenSeleted) {
        @strongify(self)
        if (buttenSeleted) {
            //暂停
            [self pausePlay];
        }else {
            //播放
            [self continuePlayCurrentAudio];
        }
    };
    self.fullScreenVC.seekProgress = ^(NSTimeInterval progress) {
        @strongify(self)
        [self seekToTime:progress completionHandler:nil];
    };
    self.fullScreenVC.setTimerPlayOver = ^{
        @strongify(self)
        [self stopPlay];
    };
    self.fullScreenVC.readPlayAudio = ^(NSInteger currentSelectPlayListIndex, GCAudioPlayModel * _Nonnull model) {
        @strongify(self)
        [self beginPlayTagAudioWithIndex:currentSelectPlayListIndex NarrowViewStatue:self.narrowView.showState];
    };
    self.fullScreenVC.currentClockTime = ^(NSTimeInterval seconds,CGYTimingType selectzon) {
        @strongify(self)
        //选择新的定时，把之前记录已播完的音乐去除
        if(self.timeZone != selectzon)self.orderPlayNum = 0;
        //记录选择定时下标、区域
        self.timeZone = selectzon;
        if (selectzon == CGYTimingType_noOpen) {
            self.timerSeconds = 0;
            [self.fullScreenVC updataTimeShowWithCurrentTime:self.timerSeconds];
            [self deallocTimer];
        }else {
            self.timerSeconds = seconds;
            if (!self.isPlaying && selectzon == CGYTimingType_currentEnd) {
                //选择第一段而且暂停播放，此时不计时
                [self deallocTimer];
                [self.fullScreenVC updataTimeShowWithCurrentTime:seconds];
            }else {
                //开始计时
                if(self.timerSeconds > 0)[self creatNewTimerWithBeginTime:seconds];
            }
        }
    };
    self.fullScreenVC.bottomBtnAction = ^(UIButton * _Nonnull button,GCAudioPlayModel *model,BOOL showNarrowView) {
        @strongify(self)
        if(button.tag == 100) {
            self.narrowView.hidden = NO;
            if (showNarrowView) return;
            [self.fullScreenVC dismissViewControllerAnimated:YES completion:nil];
            self.fullScreenVC = nil;
        }
        if (self.bottomBtnAction) self.bottomBtnAction(button,model);
        if (self.delegate && [self.delegate respondsToSelector:@selector(bottomBtnClick:Model:)]) {
            [self.delegate bottomBtnClick:button Model:model];
        }
    };
    self.fullScreenVC.playerStyleBlock = ^(CGYAudioPlayerStyle playerStyle) {
        @strongify(self)
        self.playerStyle = playerStyle;
    };
    self.fullScreenVC.rateBlock = ^(CGFloat rate) {
        @strongify(self)
        self.rate = rate;
        self.currentAudioPlayer.rate = rate;
    };
}

- (void)updateTime {
    if (self.timerSeconds == 0) {
        //停止计时器
        [self deallocTimer];
        [self.fullScreenVC updataTimeShowWithCurrentTime:0];
        //已经是最后一首
        [self timeOverPlayStop];
        if (self.oprationPlay.isLastData) {
            self.fullScreenVC.currentProgress = 0;
            [self seekToTime:0 completionHandler:nil];
        }
        return;
    }
    [self.fullScreenVC updataTimeShowWithCurrentTime:self.timerSeconds];
    if(self.timerSeconds > 0) self.timerSeconds -= 1;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Action
//通知关闭音频播
- (void)closeAudioPlayer {
    if (_currentAudioPlayer) {
        [UIView animateWithDuration:0.3 animations:^{
            self.narrowView.top = kScreenHeight;
            self.narrowView.showState = ViewHidden;
        }completion:^(BOOL finished) {
            [self stopPlay];
        }];
    }
}

@end
