//
//  GCAudioPlayListCell.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayListCell.h"
#import "UIView+Addtion.h"
#import "GCConstantMacro.h"
#import "Common.h"
#import "UIColor+Addition.h"
#import "GCAudioPlayModel.h"

@implementation GCAudioPlayListCell{
    UILabel *_titleLable;
    UILabel *_timeLable;
    UILabel *_nameLable;
    UIButton *_deleteButton;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 6, 50, 50)];
    [_deleteButton setImage:[UIImage imageNamed:@"fullView_delete"] forState:UIControlStateNormal];
    [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(15, 14, 15, 16)];
    [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    _titleLable = [UILabel new];
    _titleLable.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.top = 12;
    _titleLable.left = 16;
    _titleLable.size = CGSizeMake(kScreenWidth - 60, 16);
    _titleLable.textColor = [UIColor colorWithARGBString:@"#333333"];
    _titleLable.numberOfLines = 0;
    [self.contentView addSubview:_titleLable];
    
    UIImageView *audioCable = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_titleLable.frame), CGRectGetMaxY(_titleLable.frame)+8, 14, 14)];
    audioCable.image = [UIImage imageNamed:@"fullView_audioCable"];
    [self addSubview:audioCable];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(audioCable.frame)+2, audioCable.frame.origin.y, 65, 14)];
    _timeLable.font = FONT(14);
    _timeLable.textAlignment = NSTextAlignmentLeft;
    _timeLable.textColor = [UIColor colorWithARGBString:@"#999999"];
    [self.contentView addSubview:_timeLable];
}

- (void)setPlayModel:(GCAudioPlayModel *)playModel {
    if (playModel == nil) return;
    _playModel = playModel;
    _titleLable.text = playModel.audioTitle;
    _timeLable.text = [Common updataTimerLableWithSecond:playModel.audioLength];
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (isPlaying) {
        _titleLable.textColor = [UIColor colorWithARGBString:@"#3098F2"];
    }else {
        _titleLable.textColor = [UIColor colorWithARGBString:@"#333333"];
    }
    _deleteButton.hidden = isPlaying;
}

- (void)deleteButtonClick:(UIButton *)sender {
    if (self.deleteCellBlock) {
        self.deleteCellBlock(sender);
    }
}

@end
