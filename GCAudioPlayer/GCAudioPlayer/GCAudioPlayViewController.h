//
//  GCAudioPlayViewController.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCAudioPlayModel.h"
#import <AVFoundation/AVFoundation.h>
#import "GCAudioPlayListView.h"
#import "GCAudioPlayTimeView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SlidleStatue) {
    NoMove = 0,          //没有滑动
    MoveForward,         //前滑
    MoveBack,            //后滑
};

@interface GCAudioPlayViewController : UIViewController

@property(nonatomic, assign) NSTimeInterval currentProgress;    //当前播放进度

@property(nonatomic, assign) NSTimeInterval buffingProgress;    //缓冲进度

@property(nonatomic, assign) NSTimeInterval totleTime;          //总时长

@property(nonatomic, strong) NSMutableArray *audioArray;        //播放列表资源展示

@property(nonatomic, strong) GCAudioPlayModel *currentModel;    //当前播放音乐数据model

@property(nonatomic, assign) BOOL isFirstAudio;         //是否是第一首

@property(nonatomic, assign) BOOL isLastAudio;          //是否是最后一首

@property(nonatomic, assign) BOOL isPlaying;           //是否正在播放

@property(nonatomic, assign) NSInteger clockTime;       //定时时间

@property(nonatomic, assign) NSInteger overPlayNum;         //已经播放的歌曲数

@property (nonatomic, assign) CGYAudioPlayerStyle playerStyle;  //播放模式
@property (nonatomic, assign) CGFloat rate;                     //播放速率
@property (nonatomic, assign) CGYTimingType selectTimeZone;     //定时关闭方式

@property (nonatomic, copy) NSArray *shareArray;

//关闭全屏视图按钮
@property(nonatomic, copy) void(^closeBtnAction)(GCAudioPlayModel *currentModel, NSTimeInterval seconds,CGYTimingType selectTimeZone,BOOL isPlaying);
//上一首按钮点击回调
@property(nonatomic, copy) void(^formerBtnAction)(CGYTimingType selectTimeZone);
//下一首按钮点击回调
@property(nonatomic, copy) void(^nextBtnAction)(CGYTimingType selectTimeZone);
//播放按钮点击回调
@property(nonatomic, copy) void(^playBtnAction)(BOOL buttenSeleted);
//设置定时结束
@property(nonatomic, copy) void(^setTimerPlayOver)(void);
//设置进度
@property(nonatomic, copy) void(^seekProgress)(NSTimeInterval progress);
//列表选择播放
@property(nonatomic, copy) void(^readPlayAudio)(NSInteger currentSelectPlayListIndex,GCAudioPlayModel *model);
//当前剩余的定时时间
@property(nonatomic, copy) void(^currentClockTime)(NSTimeInterval seconds,CGYTimingType selectzon);
//定时显示
@property(nonatomic, copy) void(^bottomBtnAction)(UIButton *button,GCAudioPlayModel *model,BOOL showNarrowView);
//播放模式
@property(nonatomic, copy) void(^playerStyleBlock)(CGYAudioPlayerStyle playerStyle);
//播放速率
@property(nonatomic, copy) void(^rateBlock)(CGFloat rate);

- (void)updataTimeShowWithCurrentTime:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
