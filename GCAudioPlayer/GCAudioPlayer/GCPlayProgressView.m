//
//  GCPlayProgressView.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCPlayProgressView.h"

@implementation GCPlayProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView {
//    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    
    self.progressBarColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.progressWidth = 2;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    [_progressBarColor set];
    
    //设置圆环的宽度
    CGContextSetLineWidth(ctx, _progressWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
    //半径
    CGFloat radius = (MIN(rect.size.width, rect.size.height) -_progressWidth)/2;
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
    CGContextStrokePath(ctx);
}

@end
