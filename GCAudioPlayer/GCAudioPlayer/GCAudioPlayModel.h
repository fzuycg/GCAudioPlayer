//
//  GCAudioPlayModel.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAudioPlayModel : NSObject

@property (nonatomic, copy) NSString *audioUrl;         //音频链接

@property (nonatomic, copy) NSString *audioTitle;       //音频标题

@property (nonatomic, copy) NSString *audioPic;         //音频图片

@property (nonatomic, copy) NSString *audioAuthor;      //音频作者

@property (nonatomic, copy) NSString *audioAlbum;       //专辑

@property (nonatomic, copy) NSString *audioLyrics;      //专辑

@property (nonatomic, assign) NSInteger audioLength;    //音频长度

@property (nonatomic, assign) NSInteger isCurrentPlay;  //当前播放 1 是播放 0 不需要当前播放

@property (nonatomic, strong) UIImage *coverImage;      //封面图

@end

NS_ASSUME_NONNULL_END
