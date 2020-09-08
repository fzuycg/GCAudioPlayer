//
//  GCAudioPlayListCell.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GCAudioPlayModel;

@interface GCAudioPlayListCell : UITableViewCell

@property(nonatomic, strong) GCAudioPlayModel *playModel;

@property(nonatomic, assign) BOOL isPlaying;     //是否为播放对象

@property (nonatomic, copy) void(^deleteCellBlock)(UIButton *sender);

@end

NS_ASSUME_NONNULL_END
