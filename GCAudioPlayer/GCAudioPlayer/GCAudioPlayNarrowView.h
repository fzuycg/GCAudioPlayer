//
//  GCAudioPlayNarrowView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GCAudioPlayModel;

typedef NS_ENUM(NSUInteger, ViewShowState) {
    ViewRight = 1,          //右侧缩小状态
    ViewShow,               //正常展示状态
    ViewHidden,             //隐藏状态
    ViewBegin,              //初始状态
    ViewFull,               //全屏状态
};

@interface GCAudioPlayNarrowView : UIView

@property(nonatomic, strong) GCAudioPlayModel *currentPlayModel;

@property(nonatomic, assign) ViewShowState showState;

@property(nonatomic, assign) BOOL isPlaying;           //是否正在播放

@property(nonatomic, copy) void(^hideBtnAction)(BOOL buttenSeleted);

@property(nonatomic, copy) void(^playBtnAction)(BOOL buttenSeleted);

@property(nonatomic, copy) void(^bgImageViewTapAction)(void);

@property(nonatomic, copy) void(^closeBtnAction)(void);

- (instancetype)initWithFrame:(CGRect)frame AudioModel:(GCAudioPlayModel *)model;

//更新新音乐
- (void)updateNewAudioWithModel:(GCAudioPlayModel *)model IsPlaying:(BOOL)isPlay;

//更新播放时间
- (void)updateCurrentProgress:(NSTimeInterval)currentProgress totleTime:(NSTimeInterval)totleTime;

@end

NS_ASSUME_NONNULL_END
