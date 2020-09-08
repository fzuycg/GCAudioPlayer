//
//  GCAudioPlayOpration.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <UIKit/UIKit.h>
#import "GCAudioPlayModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCAudioPlayOpration : NSObject

/// Current image url.
@property (nonatomic, strong) NSArray *currentPlayModelArray;

@property (nonatomic, assign) NSInteger currentPlayIndex;

@property(nonatomic, assign) BOOL isLastData;

@property(nonatomic, assign) BOOL isFirstData;

- (GCAudioPlayModel *)playNewAudioQueueWithModelArray:(NSArray *)audioModelArray;

- (GCAudioPlayModel *)playNewAudioQueueWithModelArray:(NSArray *)audioModelArray PlayIndex:(NSInteger)index;

- (GCAudioPlayModel *)getNextModel;

- (GCAudioPlayModel *)getNextRandomModel;

- (GCAudioPlayModel *)getFormerModel;

- (GCAudioPlayModel *)getIndexModelWith:(NSInteger)index;

- (void)removeAllSelectData;

@end

NS_ASSUME_NONNULL_END
