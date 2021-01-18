//
//  GCAudioPlayTimeView.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayTimeView.h"
#import "GCConstantMacro.h"
#import "UIColor+Addition.h"

@implementation GCAudioPlayTimeView{
    NSArray *_timingArray;            //播放速度选项
    NSMutableArray *_buttonArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timingType = CGYTimingType_noOpen;
        _timingArray = @[@"未开启", @"播完当前", @"15分钟", @"30分钟", @"60分钟"];
        _buttonArray = [NSMutableArray arrayWithCapacity:_timingArray.count];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, kScreenWidth-32, 44)];
    title.text = @"定时停止播放";
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    title.textColor = [UIColor colorWithARGBString:@"#333333"];
    [self addSubview:title];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(title.frame), kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithARGBString:@"#F5F5F5"];
    [self addSubview:line];
    
    CGFloat buttonY = CGRectGetMaxY(line.frame);
    for (int i=0; i<_timingArray.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, buttonY, kScreenWidth-32, 44)];
        button.tag = 100+i;
        button.backgroundColor = [UIColor clearColor];
        if (_timingType == i) {
            [button setTitleColor:[UIColor colorWithARGBString:@"#3098F2"] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor colorWithARGBString:@"#333333"] forState:UIControlStateNormal];
        }
        [button setTitle:_timingArray[i] forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [_buttonArray addObject:button];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-1, button.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithARGBString:@"#F5F5F5"];
        [button addSubview:lineView];
        
        buttonY += 44;
    }
    
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, buttonY+SafeAreaBottomHeight);
}

- (void)buttonAction:(UIButton *)sender {
    self.timingType = sender.tag-100;
    if (self.timingBlock) self.timingBlock(_timingType);
}

#pragma mark - setter

- (void)setTimingType:(CGYTimingType)timingType {
    _timingType = timingType;
    for (int i=0; i<_timingArray.count; i++) {
        UIButton *rateButton = _buttonArray[i];
        if (timingType == i) {
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#3098F2"] forState:UIControlStateNormal];
        }else{
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#333333"] forState:UIControlStateNormal];
        }
    }
}

@end
