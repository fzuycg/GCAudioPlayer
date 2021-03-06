//
//  Common.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "Common.h"

@implementation Common

//展示时间
+ (void)updataTimerLableWithLable:(UILabel *)lable Second:(NSInteger)time{
    
    lable.text = [self updataTimerLableWithSecond:time];
}

//转换时间
+ (NSString *)updataTimerLableWithSecond:(NSInteger)time {
    NSString *minutes; NSString *seconds;
    if (time < 60) {
        seconds = [NSString stringWithFormat:@"%@",[self changeModeWithCount:time]];
        minutes = @"00";
    }else if (60 <= time && time <= 3600){
        minutes = [NSString stringWithFormat:@"%@",[self changeModeWithCount:time / 60]];
        seconds = [NSString stringWithFormat:@"%@",[self changeModeWithCount:time % 60]];
    }
    return [NSString stringWithFormat:@"%@:%@",minutes,seconds];
}
//小于10加一个0
+ (NSString *)changeModeWithCount:(NSInteger)count {
    if (count < 10) {
        return [NSString stringWithFormat:@"0%ld",(long)count];
    }else {
        return [NSString stringWithFormat:@"%ld",(long)count];
    }
}
@end
