//
//  GCPlayProgressView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCPlayProgressView : UIView

/**
 下载进度,内部按1.0计算
 */
@property (nonatomic, assign) CGFloat progress;

/**
 宽度 默认10
 */
@property (nonatomic, assign) CGFloat progressWidth;

/** 进度条颜色 */
@property(nonatomic, strong) UIColor *progressBarColor;

@end

NS_ASSUME_NONNULL_END
