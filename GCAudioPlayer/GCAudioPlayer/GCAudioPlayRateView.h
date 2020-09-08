//
//  GCAudioPlayRateView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAudioPlayRateView : UIView

@property (nonatomic, assign) CGFloat currentRate;

@property(nonatomic, copy) void(^rateBlock)(CGFloat rate);

@end

NS_ASSUME_NONNULL_END
