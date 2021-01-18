//
//  GCAudioLyricsTableView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/9.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GCAudioLyricsTableView;

@protocol GCAudioLyricsTableViewDelegate <NSObject>

@optional
- (void)gc_lyricsTableView:(GCAudioLyricsTableView *)lyricsTableView
           onPlayingLyrics:(NSString *)onPlayingLyrics;

@end

@interface GCAudioLyricsTableView : UITableView

@property (nonatomic, weak) id<GCAudioLyricsTableViewDelegate> lyricsDelegate;

@property (nonatomic, assign) BOOL stopUpdate;

@property (nonatomic, assign) CGFloat cellRowHeight;

@property (nonatomic, strong) UIColor *cellBackgroundColor;

@property (nonatomic, strong) UIColor *currentLineLrcForegroundTextColor;

@property (nonatomic, strong) UIColor *currentLineLrcBackgroundTextColor;

@property (nonatomic, strong) UIColor *otherLineLrcBackgroundTextColor;

@property (nonatomic, strong) UIFont *currentLineLrcFont;

@property (nonatomic, strong) UIFont *otherLineLrcFont;

@property (nonatomic, strong) UIView *lrcTableViewSuperview;

@end

NS_ASSUME_NONNULL_END
