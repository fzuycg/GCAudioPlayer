//
//  UIColor+Addition.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Addition)

+ (UIColor *)colorWithARGBString:(NSString *)argbString;
+ (UIColor *)colorWithHexString:(NSString *)color;

@end

@interface UIAlertAction (Color)

- (void)setButtonColor:(UIColor *)color;

@end
