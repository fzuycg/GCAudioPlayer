//
//  GCAudioPlayTimeView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CFTTimingType) {
    CFTTimingType_noOpen = 0,   //未开启
    CFTTimingType_currentEnd,   //当前播完
    CFTTimingType_oneMoment,    //15分钟
    CFTTimingType_twoMoment,    //30分钟
    CFTTimingType_fourMoment    //60分钟
};


@interface GCAudioPlayTimeView : UIView

@property (nonatomic, assign) CFTTimingType timingType;

@property(nonatomic, copy) void(^timingBlock)(CFTTimingType timingType);

@end

NS_ASSUME_NONNULL_END
