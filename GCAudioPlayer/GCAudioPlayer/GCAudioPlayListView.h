//
//  GCAudioPlayListView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GCAudioPlayModel;

typedef NS_ENUM(NSInteger, CGYAudioPlayerStyle) {
    CGYAudioPlayerStyle_list = 0,       //列表顺序播放
    CGYAudioPlayerStyle_cyclic,         //单曲循环
    CGYAudioPlayerStyle_random          //随机播放
};

@interface GCAudioPlayListView : UIView

@property(nonatomic, strong) NSMutableArray *allListModelArray;

@property(nonatomic, strong) GCAudioPlayModel *currentModel;

@property(nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) CGYAudioPlayerStyle playerStyle;

@property(nonatomic, copy) void(^readPlayAudio)(NSInteger currentSelectTimeListIndex,GCAudioPlayModel *model);

@property(nonatomic, copy) void(^playerStyleBlock)(CGYAudioPlayerStyle playerStyle);

@end

NS_ASSUME_NONNULL_END
