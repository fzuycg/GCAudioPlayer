//
//  GCAudioPlayViewController.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayViewController.h"
#import "UIImage+ImageEffects.h"
#import "GCConstantMacro.h"
#import "UIButton+Style.h"
#import "UIView+Addtion.h"
#import "Common.h"
#import "GCAudioPlayRateView.h"
#import "GCCoverImageView.h"

@interface GCAudioPlayViewController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;                   //内容容器

@property (nonatomic, strong) UIView *bottomOprateView;              //底部视图

@property (nonatomic, strong) UIView *middlePlayView;                //中间视图展示
@property (nonatomic, strong) UIButton *playListBtn;                 //播放列表
@property (nonatomic, strong) UIButton *cyclicBtn;                   //顺序播放
@property (nonatomic, strong) UIButton *multiplierBtn;               //倍速播放
@property (nonatomic, strong) UIButton *timeBtn;                     //时间倒计时

@property (nonatomic, strong) UIButton *retreatBtn;                  //快退
@property (nonatomic, strong) UIButton *advanceBtn;                  //快进
@property (nonatomic, strong) UILabel *beginTime;                    //起始时间
@property (nonatomic, strong) UILabel *endTime;                      //结束时间
@property (nonatomic, strong) UIProgressView *progressView;          //缓冲进度条
@property (nonatomic, strong) UISlider *sliderView;                  //播放进度条

@property (nonatomic, strong) UIButton *formerBtn;                   //上一首
@property (nonatomic, strong) UIButton *playBtn;                     //播放、暂停
@property (nonatomic, strong) UIButton *nextBtn;                     //下一首

@property (nonatomic, strong) UIImageView *topBGImageView;           //背景虚图
@property (nonatomic, strong) UIButton *leftBtn;                     //左上角向下按钮
@property (nonatomic, strong) UIButton *rightBtn;                    //右边分享按钮

@property (nonatomic, strong) GCCoverImageView *coverImageView;      //专栏图片
@property (nonatomic, strong) UILabel *articleTitle;                 //音频名字
@property (nonatomic, strong) UILabel *authorTitle;                  //作者名字
@property (nonatomic, strong) UILabel *albumTitle;                   //专辑名字

@property (nonatomic, strong) GCAudioPlayListView *playListView;     //播放列表选择器
@property (nonatomic, strong) UIView *playListMaskView;

@property (nonatomic, strong) UIView *timeSelectView;                //时间选择视图
@property (nonatomic, strong) UIView *timeListMaskView;

@property (nonatomic, strong) GCAudioPlayTimeView *timingSelectView; //时间选择视图
@property (nonatomic, strong) UIView *timingSelectMaskView;

@property (nonatomic, strong) GCAudioPlayRateView *rateSelectView;   //倍速选择
@property (nonatomic, strong) UIView *rateSelectMaskView;

@property (nonatomic, strong)CABasicAnimation *basicAnimation;

@end

@implementation GCAudioPlayViewController{
    SlidleStatue slideStatue;
    CGFloat gesturePullDown; //手势下拉距离
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentView];
    
    [self setNavigationBarHidden];
    [self initView];
    [self initPlayListView];
    [self initTimingSelectView];
    [self initRateSelectView];
    
    // 监听进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //添加手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
//    [panGesture setEnabled:YES];
//    [panGesture delaysTouchesEnded];
//    [panGesture cancelsTouchesInView];

    [self.contentView addGestureRecognizer:panGesture];
}

- (void)setNavigationBarHidden {
    self.navigationController.navigationBarHidden = YES;
}

- (void)applicationBecomeActive {
    if (self.coverImageView) {
        [self.coverImageView resumeRotate];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - 手势操作
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    // 获取平移的坐标点
    CGPoint transPoint =  [recognizer translationInView:self.view];
//    CGPoint locationPoint = [recognizer locationInView:self.view];//点击位置坐标变化
    
    // 在之前的基础上移动图片
    recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, 0, transPoint.y);
    gesturePullDown += transPoint.y;
    
    NSLog(@"下拉的距离=%f", gesturePullDown);
    // 复原，必需复原
    // 每次都清空一下消除坐标叠加
    [recognizer setTranslation:CGPointZero inView:self.view];
    
    if (gesturePullDown > kScreenHeight/3) {
        [self _leftBtnAction];
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"结束手势");
        if (gesturePullDown>= kScreenHeight/5) {
            [self _leftBtnAction];
        }else{
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [UIView animateWithDuration:0.3 animations:^{
                recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, 0, -self->gesturePullDown);
            } completion:^(BOOL finished) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }];
        }
        gesturePullDown = 0;
    }
}


#pragma mark - 初始化页面
- (void)initView {
    //背景图
    _topBGImageView = [UIImageView new];
    _topBGImageView.userInteractionEnabled = YES;
    _topBGImageView.contentMode = UIViewContentModeScaleAspectFill;
    _topBGImageView.image = [[UIImage imageNamed:@"audioPlayer_cover"] blurImage];
    _topBGImageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.contentView addSubview:_topBGImageView];
    
    CGFloat topBtnW = 28;
    
    //下拉收起按钮
    _leftBtn = [UIButton new];
    _leftBtn.size = CGSizeMake(topBtnW, topBtnW);
    _leftBtn.left = 16;
    _leftBtn.top = 32 + SafeAreaTopAddHeight;
    [_leftBtn setImage:[UIImage imageNamed:@"fullView_down_arrow"] forState:UIControlStateNormal];
    [_leftBtn addTarget:self action:@selector(_leftBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topBGImageView addSubview:_leftBtn];
    
    //分享按钮
    _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-topBtnW-16, _leftBtn.frame.origin.y, topBtnW, topBtnW)];
    [_rightBtn setImage:[UIImage imageNamed:@"fullView_share"] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(_rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_topBGImageView addSubview:_rightBtn];
    
    //专栏图片
    _coverImageView = [[GCCoverImageView alloc] initWithFrame:CGRectMake((kScreenWidth-GAFixFloatToiPhone6Width(240))/2, 120 + SafeAreaTopAddHeight, GAFixFloatToiPhone6Width(240), GAFixFloatToiPhone6Width(240))];
    if (self.currentModel.coverImage) {
        self.coverImageView.image = self.currentModel.coverImage;
        self.topBGImageView.image = [self.currentModel.coverImage blurImage];
    }else{
        _coverImageView.image = [UIImage imageNamed:@"audioPlayer_cover"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //NSString -> NSURL -> NSData -> UIImage
            NSURL *imageURL = [NSURL URLWithString:self.currentModel.audioPic];
            //下载图片
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                //从子线程回到主线程(方式二：常用)
                //组合：主队列异步执行
                dispatch_async(dispatch_get_main_queue(), ^{
                    //更新界面
                    self.coverImageView.image = image;
                    self.topBGImageView.image = [image blurImage];
                });
            }
        });
    }
    _coverImageView.layer.cornerRadius = GAFixFloatToiPhone6Width(240)/2;
    _coverImageView.layer.masksToBounds = YES;
    [_coverImageView startRotating];
    [_topBGImageView addSubview:_coverImageView];
    
    //音频名字
    _articleTitle = [UILabel new];
    _articleTitle.font = FONT(24);
    _articleTitle.left = 16;
    _articleTitle.top = _coverImageView.bottom + 24;
    _articleTitle.size = CGSizeMake(kScreenWidth - 32, 60);
    _articleTitle.textColor = [UIColor whiteColor];
    _articleTitle.textAlignment = NSTextAlignmentCenter;
    _articleTitle.numberOfLines = 0;
    _articleTitle.text = _currentModel.audioTitle;
    [_topBGImageView addSubview:_articleTitle];
    
    //作者名
    _authorTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(_articleTitle.frame)+8, kScreenWidth-32, 15)];
    _authorTitle.font = [UIFont systemFontOfSize:15];
    _authorTitle.textAlignment = NSTextAlignmentCenter;
    _authorTitle.textColor = [UIColor grayColor];
    _authorTitle.text = [NSString stringWithFormat:@"%@《%@》", _currentModel.audioAuthor, _currentModel.audioAlbum];
    [_topBGImageView addSubview:_authorTitle];
    //专辑名
    
#pragma mark - 播放功能部分
    
    //中间容器视图
    _middlePlayView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - SafeAreaBottomHeight - 280, kScreenWidth, 280)];
    [self.contentView addSubview:_middlePlayView];
    
    CGFloat btnW = 54;
    CGFloat btnEdge = (kScreenWidth-6*btnW)/5;
    CGFloat btnX = btnW+btnEdge;
    CGFloat btnY = 10;
    
    //播放列表
    _playListBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnW)];
    [_playListBtn setTitle:@"播放列表" forState:UIControlStateNormal];
    [_playListBtn setImage:[UIImage imageNamed:@"audioPlayer_list"] forState:UIControlStateNormal];
    _playListBtn.titleLabel.font = FONT(10);
    [_playListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playListBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:4];
    [_playListBtn addTarget:self action:@selector(_playListBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_playListBtn];
    btnX += btnEdge+btnW;
    
    //循环播放
    _cyclicBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnW)];
    [self setPlayerStyle:_playerStyle];
    _cyclicBtn.titleLabel.font = FONT(10);
    [_cyclicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cyclicBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:4];
    [_cyclicBtn addTarget:self action:@selector(_cyclicBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_cyclicBtn];
    btnX += btnEdge+btnW;
    
    //定时关闭
    _timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnW)];
    NSString *timeS = _clockTime > 0 ? [Common updataTimerLableWithSecond:_clockTime] : @"定时关闭";
    [_timeBtn setTitle:timeS forState:UIControlStateNormal];
    _timeBtn.titleLabel.font = FONT(10);
    _timeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"audioPlayer_time"] forState:UIControlStateNormal];
    [_timeBtn addTarget:self action:@selector(_timingBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:4];
    [_middlePlayView addSubview:_timeBtn];
    btnX += btnEdge+btnW;
    
    //倍速播放
    _multiplierBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnW)];
    [_multiplierBtn setTitle:@"倍速播放" forState:UIControlStateNormal];
    [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x1"] forState:UIControlStateNormal];
    _multiplierBtn.titleLabel.font = FONT(10);
    [_multiplierBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_multiplierBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:4];
    [_multiplierBtn addTarget:self action:@selector(_multiplierBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_multiplierBtn];
    btnX += btnEdge+btnW;
    
#pragma mark - 播放进度部分
    
    //后退按钮
    _retreatBtn = [[UIButton alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(_multiplierBtn.frame)+36, 30, 30)];
    [_retreatBtn setImage:[UIImage imageNamed:@"audioPlayer_retreat"] forState:UIControlStateNormal];
    [_retreatBtn addTarget:self action:@selector(_retreatBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_retreatBtn];
    
    //前进按钮
    _advanceBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-32-30, _retreatBtn.frame.origin.y, 30, 30)];
    [_advanceBtn setImage:[UIImage imageNamed:@"audioPlayer_advance"] forState:UIControlStateNormal];
    [_advanceBtn addTarget:self action:@selector(_advanceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_middlePlayView addSubview:_advanceBtn];
    
    //缓冲进度条
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_retreatBtn.frame)+6, _retreatBtn.frame.origin.y+9, kScreenWidth - (CGRectGetMaxX(_retreatBtn.frame)+6)*2, 3)];
    _progressView.centerY = _retreatBtn.centerY;
    _progressView.layer.masksToBounds = YES;
    _progressView.layer.cornerRadius = 1.5;
    _progressView.trackTintColor= [[UIColor whiteColor] colorWithAlphaComponent:0.2];//设置进度条颜色
    _progressView.progressTintColor= [UIColor grayColor];//缓冲进度条上进度的颜色
    _progressView.progress = _buffingProgress / self.currentModel.audioLength;
    [_middlePlayView addSubview:_progressView];
    
    //播放进度条
    _sliderView = [[UISlider alloc]initWithFrame:CGRectMake(_progressView.frame.origin.x-2, _retreatBtn.frame.origin.y, _progressView.frame.size.width+4, 20)];
    _sliderView.centerY = _progressView.centerY;
    _sliderView.layer.masksToBounds = YES;
    _sliderView.layer.cornerRadius = 1.5;
    _sliderView.minimumValue = 0;
    _sliderView.maximumValue = self.currentModel.audioLength;
    _sliderView.value = self.currentProgress;
    _sliderView.continuous = YES;
    _sliderView.minimumTrackTintColor = [UIColor whiteColor];//XHAPPMainColor;
    _sliderView.maximumTrackTintColor = [UIColor clearColor];
    [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderView addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
    [_sliderView setThumbImage:[UIImage imageNamed:@"fullView_progress"] forState:UIControlStateNormal];
    [_middlePlayView addSubview:_sliderView];
    
    //开始时间
    _beginTime = [UILabel new];
    _beginTime.left = _progressView.left;
    _beginTime.top = _progressView.bottom + 8;
    _beginTime.size = CGSizeMake(80, 14);
    _beginTime.text = @"00:00";
    _beginTime.font = FONT(10);
    _beginTime.textColor = [UIColor whiteColor];//XHAPPTipsColor;
    [_middlePlayView addSubview:_beginTime];
    [Common updataTimerLableWithLable:_beginTime Second:_currentProgress];
    
    //结束时间
    _endTime = [UILabel new];
    _endTime.left = _progressView.right - 80;
    _endTime.top = _progressView.bottom + 8;
    _endTime.size = CGSizeMake(80, 14);
    _endTime.textAlignment = NSTextAlignmentRight;
    _endTime.text = @"00:00";
    _endTime.font = FONT(10);
    _endTime.textColor = [UIColor whiteColor];//XHAPPTipsColor;
    [_middlePlayView addSubview:_endTime];
    [Common updataTimerLableWithLable:_endTime Second:_currentModel.audioLength];
    
#pragma mark - 播放控制部分
    
    //播放
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, CGRectGetMaxY(_retreatBtn.frame)+30, 60, 60)];
    [_playBtn setImage:[UIImage imageNamed:@"fullView_ playBtn_play"] forState:UIControlStateSelected];
    [_playBtn setImage:[UIImage imageNamed:@"fullView_ playBtn_puse"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(_playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.selected = !_isPlaying;
    [_middlePlayView addSubview:_playBtn];
    
    //上一首
    _formerBtn = [UIButton new];
    _formerBtn.size = CGSizeMake(46, 46);
    _formerBtn.left = (kScreenWidth / 2 - 39 - 48 ) / 2 - 23 + 48;
    _formerBtn.centerY = _playBtn.centerY;
    [_formerBtn setImage:[UIImage imageNamed:@"fullView_playBtn_left_n"] forState:UIControlStateNormal];
    [_formerBtn setImage:[UIImage imageNamed:@"fullView_playBtn_left_f"] forState:UIControlStateDisabled];
    [_formerBtn addTarget:self action:@selector(_formerBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    if (_isFirstAudio) _formerBtn.enabled = NO;
    [_middlePlayView addSubview:_formerBtn];
    
    //下一首
    _nextBtn = [UIButton new];
    _nextBtn.size = CGSizeMake(46, 46);
    _nextBtn.left = kScreenWidth / 2 + 39 + (kScreenWidth / 2 - 39 - 48 ) / 2 - 23;
    _nextBtn.centerY = _playBtn.centerY;
    [_nextBtn setImage:[UIImage imageNamed:@"fullView_playBtn_right_n"] forState:UIControlStateNormal];
    [_nextBtn setImage:[UIImage imageNamed:@"fullView_playBtn_right_f"] forState:UIControlStateDisabled];
    [_nextBtn addTarget:self action:@selector(_nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    if (_isLastAudio) _nextBtn.enabled = NO;
    [_middlePlayView addSubview:_nextBtn];
}

- (void)initPlayListView {
    _playListMaskView = [[UIView alloc] initWithFrame:self.view.frame];
    _playListMaskView.alpha = 0.3;
    _playListMaskView.backgroundColor = GCUIColorFromRGB(0x000000);
    _playListMaskView.hidden = YES;
    UITapGestureRecognizer *playListMaskViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playListMaskViewTapAction)];
    [_playListMaskView addGestureRecognizer:playListMaskViewTap];
    [self.contentView addSubview:_playListMaskView];
    
    _playListView = [[GCAudioPlayListView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight/2)];
    _playListView.allListModelArray = self.audioArray;
    [self.contentView addSubview:_playListView];
}

- (void)initTimingSelectView {
    _timingSelectMaskView = [[UIView alloc] initWithFrame:self.view.frame];
    _timingSelectMaskView.alpha = 0.3;
    _timingSelectMaskView.backgroundColor = GCUIColorFromRGB(0x000000);
    _timingSelectMaskView.hidden = YES;
    UITapGestureRecognizer *timingSelectMaskViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timingSelectMaskViewTapAction)];
    [_timingSelectMaskView addGestureRecognizer:timingSelectMaskViewTap];
    [self.contentView addSubview:_timingSelectMaskView];
    
    _timingSelectView = [[GCAudioPlayTimeView alloc] init];
    _timingSelectView.timingType = self.selectTimeZone;
    [self.contentView addSubview:_timingSelectView];
}

- (void)initRateSelectView {
    _rateSelectMaskView = [[UIView alloc] initWithFrame:self.view.frame];
    _rateSelectMaskView.alpha = 0.3;
    _rateSelectMaskView.backgroundColor = GCUIColorFromRGB(0x000000);
    _rateSelectMaskView.hidden = YES;
    UITapGestureRecognizer *rateSelectMaskViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(rateSelectMaskViewTapAction)];
    [_rateSelectMaskView addGestureRecognizer:rateSelectMaskViewTap];
    [self.contentView addSubview:_rateSelectMaskView];
    
    _rateSelectView = [[GCAudioPlayRateView alloc] init];
    _rateSelectView.currentRate = self.rate;
    [self.contentView addSubview:_rateSelectView];
}

- (NSMutableArray *)audioArray {
    if (_audioArray == nil) {
        _audioArray = [NSMutableArray array];
    }
    return _audioArray;
}

#pragma mark - set
- (void)setCurrentModel:(GCAudioPlayModel *)currentModel {
    if (currentModel == nil) return;
    _currentModel  = currentModel;
    //中间图
    self.coverImageView.image = self.currentModel.coverImage;
    self.topBGImageView.image = [self.currentModel.coverImage blurImage];
    _articleTitle.text = currentModel.audioTitle;
    _authorTitle.text = [NSString stringWithFormat:@"%@《%@》", currentModel.audioAuthor, currentModel.audioAlbum];
    
    //进度条
    self.totleTime = self.currentModel.audioLength;
    self.sliderView.maximumValue = self.currentModel.audioLength;//音乐总共时长
    [Common updataTimerLableWithLable:_endTime Second:currentModel.audioLength];
    
    //上一首，下一首，更新定时显示
    if(self.selectTimeZone == CGYTimingType_currentEnd)[self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:currentModel];
}

- (void)setCurrentProgress:(NSTimeInterval)currentProgress {
    _currentProgress = currentProgress;
    _sliderView.value  = currentProgress;
    [Common updataTimerLableWithLable:_beginTime Second:currentProgress];
}
- (void)setBuffingProgress:(NSTimeInterval)buffingProgress {
    _buffingProgress = buffingProgress;
    _progressView.progress = buffingProgress / self.totleTime;
}

- (void)setTotleTime:(NSTimeInterval)totleTime {
    _totleTime = totleTime;
    [Common updataTimerLableWithLable:_endTime Second:totleTime];
    _sliderView.maximumValue = totleTime;
}
- (void)setIsLastAudio:(BOOL)isLastAudio {
    _isLastAudio = isLastAudio;
//    _nextBtn.enabled = !isLastAudio;
}
- (void)setIsFirstAudio:(BOOL)isFirstAudio {
    _isFirstAudio = isFirstAudio;
//    _formerBtn.enabled = !isFirstAudio;
}
- (void)setIsPlaying:(BOOL )isPlaying {
    _isPlaying = isPlaying;
    _playBtn.selected = !isPlaying;
}
- (void)setClockTime:(NSInteger)clockTime {
    _clockTime = clockTime;
    //当选择10分钟以上定时，由外部管理定时不需要重新计算
    if (self.selectTimeZone != CGYTimingType_currentEnd && self.selectTimeZone != CGYTimingType_noOpen) return;
    NSString *timeS = _clockTime > 0 ? [Common updataTimerLableWithSecond:_clockTime] : @"定时关闭";
    [_timeBtn setTitle:timeS forState:UIControlStateNormal];
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:2];
}
- (void)setPlayerStyle:(CGYAudioPlayerStyle)playerStyle {
    _playerStyle = playerStyle;
    if (playerStyle == CGYAudioPlayerStyle_list) {
        [self.cyclicBtn setTitle:@"顺序播放" forState:UIControlStateNormal];
        [self.cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_shunxu_1"] forState:UIControlStateNormal];
    } else if (playerStyle == CGYAudioPlayerStyle_cyclic) {
        [self.cyclicBtn setTitle:@"循环播放" forState:UIControlStateNormal];
        [self.cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_xunhuan_1"] forState:UIControlStateNormal];
    } else if (playerStyle == CGYAudioPlayerStyle_random) {
        [self.cyclicBtn setTitle:@"随机播放" forState:UIControlStateNormal];
        [self.cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_suiji_1"] forState:UIControlStateNormal];
    }
}
- (void)setRate:(CGFloat)rate {
    _rate = rate;
    _rateSelectView.currentRate = rate;
    if (rate == 0.5) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x05"] forState:UIControlStateNormal];
    }else if (rate == 0.75) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x075"] forState:UIControlStateNormal];
    }else if (rate == 1.0) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x1"] forState:UIControlStateNormal];
    }else if (rate == 1.25) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x125"] forState:UIControlStateNormal];
    }else if (rate == 1.5) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x15"] forState:UIControlStateNormal];
    }else if (rate == 1.75) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x175"] forState:UIControlStateNormal];
    }else if (rate == 2.0) {
        [_multiplierBtn setImage:[UIImage imageNamed:@"audioPlayer_rate_x2"] forState:UIControlStateNormal];
    }
}

- (void)setSelectTimeZone:(CGYTimingType)selectTimeZone {
    _selectTimeZone = selectTimeZone;
    self.timingSelectView.timingType = selectTimeZone;
}

#pragma mark - 顶上按钮点击事件
- (void)_leftBtnAction {
   
//    if (self.progressTimer != nil) {
//        [self.progressTimer invalidate];
//        self.progressTimer = nil;
//    }
    //传出数据
    if (self.closeBtnAction) self.closeBtnAction(_currentModel,_clockTime, _selectTimeZone,_isPlaying);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_rightBtnAction {
    
}

#pragma mark - CGYShareDelegate
-(void)actionType:(NSString *)type data:(NSString *)dateStr {
    
}

#pragma mark - 中间播放控制视图按钮事件
/// 播放列表按钮点击事件
- (void)_playListBtnAction {
    //弹出列表
    _playListMaskView.hidden = NO;
    _playListView.currentModel = self.currentModel;
    _playListView.isPlaying = self.isPlaying;
    _playListView.playerStyle = self.playerStyle;
    @weakify(self)
    _playListView.readPlayAudio = ^(NSInteger currentSelectPlayListIndex, GCAudioPlayModel *model) {
        @strongify(self)
        if (![self.currentModel.audioTitle isEqualToString:model.audioTitle]) {
            if(self.readPlayAudio)self.readPlayAudio(currentSelectPlayListIndex, model);
        }
        [self playListMaskViewTapAction];
    };
    _playListView.playerStyleBlock = ^(CGYAudioPlayerStyle playerStyle) {
        @strongify(self)
        self.playerStyle = playerStyle;
        if (self.playerStyleBlock) self.playerStyleBlock(playerStyle);
    };
    [UIView animateWithDuration:0.3 animations:^{
        self->_playListView.y = kScreenHeight - self->_playListView.height;
    }];
    
}
/// 播放列表遮罩点击事件
- (void)playListMaskViewTapAction {
    _playListMaskView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self->_playListView.y = kScreenHeight;
    }];
}
/// 切换播放方式按钮点击事件
- (void)_cyclicBtnAction {
    //切换播放方式
    if (_playerStyle == CGYAudioPlayerStyle_list) {
        [_cyclicBtn setTitle:@"单曲循环" forState:UIControlStateNormal];
        [_cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_xunhuan_1"] forState:UIControlStateNormal];
        _playerStyle = CGYAudioPlayerStyle_cyclic;
    } else if (_playerStyle == CGYAudioPlayerStyle_cyclic) {
        [_cyclicBtn setTitle:@"随机播放" forState:UIControlStateNormal];
        [_cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_suiji_1"] forState:UIControlStateNormal];
        _playerStyle = CGYAudioPlayerStyle_random;
    } else if (_playerStyle == CGYAudioPlayerStyle_random) {
        [_cyclicBtn setTitle:@"列表播放" forState:UIControlStateNormal];
        [_cyclicBtn setImage:[UIImage imageNamed:@"audioPlayer_shunxu_1"] forState:UIControlStateNormal];
        _playerStyle = CGYAudioPlayerStyle_list;
    }
    
    if (self.playerStyleBlock) self.playerStyleBlock(_playerStyle);
}
/// 定时关闭按钮点击事件
- (void)_timingBtnAction {
    _timingSelectMaskView.hidden = NO;
    @weakify(self)
    _timingSelectView.timingBlock = ^(CGYTimingType timingType) {
        @strongify(self)
        NSLog(@"选择定时关闭方式 %ld", (long)timingType);
        [self timingSelectMaskViewTapAction];
        //开始计时
        if(self.selectTimeZone == timingType)return;
        self.selectTimeZone = timingType;
        [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
    };
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_timingSelectView.y = kScreenHeight - self->_timingSelectView.height;
    }];
}

/// 定时选择遮罩点击事件
- (void)timingSelectMaskViewTapAction {
    _timingSelectMaskView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self->_timingSelectView.y = kScreenHeight;
    }];
}
/// 倍速播放按钮点击事件
- (void)_multiplierBtnAction {
    //切换倍速播放
    _rateSelectMaskView.hidden = NO;
    @weakify(self)
    _rateSelectView.rateBlock = ^(CGFloat rate) {
        @strongify(self)
        NSLog(@"选择倍速 %f", rate);
        self.rate = rate;
        if (self.rateBlock) self.rateBlock(rate);
        [self rateSelectMaskViewTapAction];
    };
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_rateSelectView.y = kScreenHeight - self->_rateSelectView.height;
    }];
}
/// 速率选择遮罩点击事件
- (void)rateSelectMaskViewTapAction {
    _rateSelectMaskView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self->_rateSelectView.y = kScreenHeight;
    }];
}

#pragma mark - 底部播放控制按钮事件
- (void)_retreatBtnAction {
    //快退
    if (_currentProgress <= 15) {
        self.currentProgress = 0;
    }else{
        self.currentProgress = _currentProgress-15;
    }
    if (self.seekProgress) self.seekProgress(_currentProgress);
    //设置完进度后更新时间
    if(self.selectTimeZone == CGYTimingType_currentEnd) [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
}
- (void)_advanceBtnAction {
    //快进
    if (_currentModel.audioLength-_currentProgress <= 15) {
        self.currentProgress = _currentModel.audioLength;
    }else{
        self.currentProgress = _currentProgress+15;
    }
    if (self.seekProgress) self.seekProgress(_currentProgress);
    //设置完进度后更新时间
    if(self.selectTimeZone == CGYTimingType_currentEnd) [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
}
- (void)_playBtnAction:(UIButton *)button {
    //播放、暂停
    button.selected = !button.selected;
    _isPlaying = !button.selected;
    if (self.playBtnAction) self.playBtnAction(button.selected);
}

- (void)_formerBtnAction {
    //上一曲,先处理定时
    self.currentProgress = 0;
    if(self.formerBtnAction) self.formerBtnAction(self.selectTimeZone);
}

- (void)_nextBtnAction {
    //下一曲,先处理定时
    self.currentProgress = 0;
    if (self.nextBtnAction) self.nextBtnAction(self.selectTimeZone);
}

-(void)sliderValueChanged:(UISlider *)slider {
    [Common updataTimerLableWithLable:_beginTime Second:slider.value];
}

- (void)sliderTouchUpInSide:(UISlider *)slider {
    //滑动进度条暂停
    if (slider.value > self.currentProgress) {
        slideStatue = MoveForward;
    }else {
        slideStatue = MoveBack;
    }
    self.currentProgress = slider.value;
    if (self.seekProgress) self.seekProgress(slider.value);
    //设置完进度后更新时间
    if(self.selectTimeZone == CGYTimingType_currentEnd) [self computationTimeDisplayTimeLableWithSelectZone:self.selectTimeZone NewModel:self.currentModel];
}
#pragma mark - 选择定时时间
- (void)updataTimeShowWithCurrentTime:(NSInteger)time {
    if (time == 0) {
        [_timeBtn setTitle:@"定时关闭" forState:UIControlStateNormal];
    }else {
        NSString *timertitle = [Common updataTimerLableWithSecond:time];
        [_timeBtn setTitle:timertitle forState:UIControlStateNormal];
    }
    [_timeBtn layoutButtonWithEdgeInsetsStyle:ICButtonEdgeInsetsStyleTop imageTitleSpace:4];
}
#pragma mark - private
- (void)computationTimeDisplayTimeLableWithSelectZone:(CGYTimingType)zone NewModel:(GCAudioPlayModel *)model{
    //计算时间
    self.clockTime = (zone == CGYTimingType_noOpen) ? 0 : [self totleTimeClockWithType:zone CurrentModel:model];
    if(self.currentClockTime) self.currentClockTime(self.clockTime,zone);
}

//计算定时
- (NSInteger)totleTimeClockWithType:(CGYTimingType)type CurrentModel:(GCAudioPlayModel *)model {
    NSInteger clockSum = 0;
    
    switch (type) {
        case CGYTimingType_noOpen:
            clockSum = 0;
            break;
        case CGYTimingType_currentEnd:
            clockSum = model.audioLength - self.currentProgress;
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

@end
