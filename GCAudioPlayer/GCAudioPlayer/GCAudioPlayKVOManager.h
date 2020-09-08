//
//  GCAudioPlayKVOManager.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAudioPlayKVOManager : NSObject
- (instancetype)initWithTarget:(NSObject *)target;

- (void)safelyAddObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  options:(NSKeyValueObservingOptions)options
                  context:(nullable void *)context;

- (void)safelyRemoveObserver:(NSObject *)observer
                  forKeyPath:(NSString *)keyPath;

- (void)safelyRemoveAllObservers;
@end

NS_ASSUME_NONNULL_END
