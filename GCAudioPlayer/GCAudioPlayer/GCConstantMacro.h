//
//  GCConstantMacro.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#ifndef GCConstantMacro_h
#define GCConstantMacro_h

/**
 * 强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 * 调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 * 示例：
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

//颜色
#define GCUIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:1.0]
#define GCUIColorFromRGBA(rgbValue, a) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:a]

//尺寸
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height>=812)?YES:NO)
#define START_POSITION ([UIApplication sharedApplication].statusBarFrame.size.height)

#define FONT(a)             [UIFont systemFontOfSize:a]

//屏幕百分比以6s为基础
#define GCScreenWidthPercentage(a) (kScreenWidth*((a)/667.00))
#define GCScreenHeightPercentage(a) (kScreenHeight *((a)/375.00))

#define STATUS_BAR_HIGHT        (IS_IPHONEX ? 44: 20)//状态栏
#define NAVI_BAR_HIGHT          (IS_IPHONEX ? 88: 64)//导航栏
#define SafeAreaTopAddHeight    (IS_IPHONEX ? 24: 0)//导航栏多出的高度
#define SafeAreaTopHeight       (IS_IPHONEX ? 88.0 : 64.0)
#define SafeAreaBottomHeight    (IS_IPHONEX ? 34 : 0)

CG_INLINE CGFloat GAFixFloatToiPhone6Width(CGFloat floatValue) {
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    CGFloat scale = CGRectGetWidth(mainFrame) /375;
    return floatValue *scale;
}

#endif /* GCConstantMacro_h */
