//
//  Common.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Common : NSObject

//展示时间
+ (void)updataTimerLableWithLable:(UILabel *)lable Second:(NSInteger)time;

//转换时间
+ (NSString *)updataTimerLableWithSecond:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
