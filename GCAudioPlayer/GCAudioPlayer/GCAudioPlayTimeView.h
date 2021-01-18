//
//  GCAudioPlayTimeView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CGYTimingType) {
    CGYTimingType_noOpen = 0,   //未开启
    CGYTimingType_currentEnd,   //当前播完
    CGYTimingType_oneMoment,    //15分钟
    CGYTimingType_twoMoment,    //30分钟
    CGYTimingType_fourMoment    //60分钟
};


@interface GCAudioPlayTimeView : UIView

@property (nonatomic, assign) CGYTimingType timingType;

@property(nonatomic, copy) void(^timingBlock)(CGYTimingType timingType);

@end

NS_ASSUME_NONNULL_END
