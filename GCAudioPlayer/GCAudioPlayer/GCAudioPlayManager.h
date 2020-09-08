//
//  GCAudioPlayManager.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCAudioPlayOpration.h"
#import "GCAudioPlayer.h"
#import "GCAudioPlayViewController.h"
#import "GCAudioPlayNarrowView.h"
#import "GCConstantMacro.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<GCAudioPlayModel *> GCAudioModelArray;

@protocol GCAudioPlayManagerDelegate <NSObject>

@optional

-(void)bottomBtnClick:(UIButton *)button Model:(GCAudioPlayModel *)model;
@end

@interface GCAudioPlayManager : NSObject

@property(nonatomic, strong) GCAudioPlayOpration *oprationPlay;

@property(nonatomic, strong) GCAudioPlayer *currentAudioPlayer;

@property(nonatomic, strong) GCAudioPlayModel *currentPlayModel;

@property(nonatomic, assign) id<GCAudioPlayManagerDelegate> delegate;

@property(nonatomic, assign) BOOL isRunning;    //播放器正在运行,用来标记是否移除播放器

@property (nonatomic, readonly) BOOL isPlaying; //播放器在播放还是暂停

@property (nonatomic, readonly) BOOL isClosePlay; //播放器是否关闭

@property (nonatomic, copy) NSArray *shareArray; //分享内容
//@property (nonatomic, strong) CFTAudioModel *audioModel;

//当前播放缓冲进度
@property (nonatomic, readonly) NSTimeInterval buffingProgress;
//当前播放音乐已播放时间
@property (nonatomic, readonly) NSTimeInterval currentTime;
//当前播放音乐总时间
@property (nonatomic, readonly) NSTimeInterval totalTime;
//当前播放音乐所在的下标
@property (nonatomic, readonly) NSInteger currentPlayIndex;
//是否是最后一首
@property (nonatomic, readonly) BOOL isLastAudio;
//是否是第一首
@property (nonatomic, readonly) BOOL isFirstAudio;
//已准备资源
@property (nonatomic, copy, nullable) void(^playerPrepareToPlay)(id object, GCAudioPlayModel *model);
//已准备播放
@property (nonatomic, copy, nullable) void(^playerReadyToPlay)(id object, GCAudioPlayModel *model);
//播放进度
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id object, NSTimeInterval currentTime, NSTimeInterval duration);
//缓冲进度
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id object, NSTimeInterval bufferTime);
//播放状态
@property (nonatomic, copy, nullable) void(^playerPlayStateChanged)(id object, ICAudioPlayerState playState);
//加载状态
@property (nonatomic, copy, nullable) void(^playerLoadStateChanged)(id asset, ICPlayerLoadState loadState);
//播放失败
@property (nonatomic, copy, nullable) void(^playerPlayFailed)(id object, id error);
//一首音乐播放结束
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id object);
//文章、收藏、分享
@property(nonatomic, copy, nullable) void(^bottomBtnAction)(UIButton *button,GCAudioPlayModel *model);
//关闭播放器
@property (nonatomic, copy, nullable) void(^playerClosed)(void);

+ (instancetype)sharedManager;
/**
 加载播放的数据
 @param audioArray 需要播放的数据集合
 */
- (void)loadAudioSouceWithArray:(GCAudioModelArray *)audioArray;

//开始播放当前音乐
- (void)beginCurrentPlay;

//开始播放当前队列的第一首歌
- (void)beginPlayFirstAudio;

//播放当前队列指定下标
- (void)beginPlayTagAudioWithIndex:(NSInteger)index NarrowViewStatue:(ViewShowState)statue;

//播放下一首
- (void)playNextAudio;

//播放上一首
- (void)playFormerAudio;

//暂停当前音乐的播放
- (void)pausePlay;

//继续播放当前音乐
- (void)continuePlayCurrentAudio;

//结束播放，结束队列播放，清空资源
- (void)stopPlay;

//设置播放进度
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

- (void)showNorrowView;

- (void)hiddenNorrowView;

@end

NS_ASSUME_NONNULL_END
