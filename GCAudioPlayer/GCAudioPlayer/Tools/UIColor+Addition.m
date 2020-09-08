//
//  UIColor+Addition.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "UIColor+Addition.h"

@implementation UIColor (Addition)

+ (UIColor *)colorWithARGBString:(NSString *)argbString {
    if ([argbString isEqualToString:@"clear"]) {
        return [UIColor clearColor];
    }
    
    if(argbString.length < 8) {
        return [self colorWithHexString:argbString];
    }
    
    if([self judgeColorString:argbString]) {
        argbString = [argbString substringWithRange:NSMakeRange(1, 8)];
    }
    else {
        return nil;
    }
    
    NSRange alphaRange = NSMakeRange(0, 2);
    NSRange redRange = NSMakeRange(2, 2);
    NSRange greenRange = NSMakeRange(4, 2);
    NSRange blueRange = NSMakeRange(6, 2);
    
    CGFloat alpha = [self valueOfHexString:[argbString substringWithRange:alphaRange]];
    CGFloat red = [self valueOfHexString:[argbString substringWithRange:redRange]];
    CGFloat green = [self valueOfHexString:[argbString substringWithRange:greenRange]];
    CGFloat blue = [self valueOfHexString:[argbString substringWithRange:blueRange]];
    
    return [UIColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:alpha/255.];
}

+ (NSUInteger)valueOfHexString:(NSString *)Hexstring {  // ff -> 255
    NSScanner *scanner = [NSScanner scannerWithString:Hexstring];
    unsigned int value = 0;
    [scanner scanHexInt:&value];
    NSUInteger retValue = value;
    return retValue;
}

+ (BOOL)judgeColorString:(NSString *)colorString { //@"#ffeeaa00"
    NSString *regix = @"^#[a-fA-F\\d]{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regix];
    return [predicate evaluateWithObject:colorString];
}

+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }else if([color length] > 8){
        return [self colorWithARGBString:color];
    }
    // 判断前缀
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}



@end

@implementation UIAlertAction (Color)

- (void)setButtonColor:(UIColor *)color {
    @try {
        [self setValue:color forKey:@"titleTextColor"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

@end
