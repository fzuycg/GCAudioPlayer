//
//  GCAudioPlayOpration.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayOpration.h"

@implementation GCAudioPlayOpration{
    dispatch_semaphore_t _lock;
}

- (instancetype)init{
    self = [super init];
    _currentPlayModelArray = @[];
    _currentPlayIndex = 0;
    _lock = dispatch_semaphore_create(1);
    return self;
}

- (GCAudioPlayModel *)playNewAudioQueueWithModelArray:(NSArray *)audioModelArray {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = 0;
    _isFirstData = YES;
    _isLastData = (_currentPlayModelArray.count == 1) ? YES : NO;
    _currentPlayModelArray = audioModelArray;
    dispatch_semaphore_signal(_lock);
    GCAudioPlayModel *model;
    for (int i = 0; i < _currentPlayModelArray.count; i++) {
        model = _currentPlayModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            return model;
        }
    }
    return  nil;
}

- (GCAudioPlayModel *)playNewAudioQueueWithModelArray:(NSArray *)audioModelArray PlayIndex:(NSInteger)index {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = index;
    _currentPlayModelArray = audioModelArray;
    _isFirstData = (_currentPlayIndex == 0) ? YES : NO;
    _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
    dispatch_semaphore_signal(_lock);
    GCAudioPlayModel *model;
    for (NSInteger i = index; i < audioModelArray.count; i++) {
        model = audioModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            return model;
        }
    }
    return  nil;
}

// 获取下一首（顺序）
- (GCAudioPlayModel *)getNextModel {
    GCAudioPlayModel *model;
    //已经是最后一首没有下一首
    if (_isLastData) return nil;
    for (NSInteger i = _currentPlayIndex + 1; i < _currentPlayModelArray.count; i++) {
        model = _currentPlayModelArray[i];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i;
            _isFirstData = NO;
            _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
            return model;
        }
    }
    return  nil;
}

// 获取下一首（随机）
- (GCAudioPlayModel *)getNextRandomModel {
    GCAudioPlayModel *model;
    
    int i = (int)(arc4random() % (_currentPlayModelArray.count + 1));
    
    model = _currentPlayModelArray[i];
    if (model.audioUrl.length > 0) {
        _currentPlayIndex = i;
        _isFirstData = NO;
        _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
        return model;
    }
    return  nil;
}

// 获取上一首
- (GCAudioPlayModel *)getFormerModel {
    GCAudioPlayModel *model;
    //第一首没有上一首
    if (_isFirstData) return nil;
    for (NSInteger i = _currentPlayIndex; i > 0; i--) {
        model = _currentPlayModelArray[i - 1];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = i - 1;
            _isFirstData = (_currentPlayIndex == 0 ) ? YES : NO;
            _isLastData =  NO;
            return model;
        }
    }
    return  nil;
}

- (GCAudioPlayModel *)getIndexModelWith:(NSInteger)index {
    if (index < _currentPlayModelArray.count) {
        GCAudioPlayModel *model = _currentPlayModelArray[index];
        if (model.audioUrl.length > 0) {
            _currentPlayIndex = index;
            _isFirstData = (_currentPlayIndex == 0) ? YES : NO;
            _isLastData = (_currentPlayIndex == _currentPlayModelArray.count - 1) ? YES : NO;
            return model;
        }
    }
    return nil;
}

- (void)removeAllSelectData {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _currentPlayIndex = 0;
    _currentPlayModelArray = @[].mutableCopy;
    _isFirstData = YES ;
    _isLastData = YES;
    dispatch_semaphore_signal(_lock);
}

@end
