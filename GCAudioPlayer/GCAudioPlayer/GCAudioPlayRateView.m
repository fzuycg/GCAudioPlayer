//
//  GCAudioPlayRateView.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayRateView.h"
#import "GCConstantMacro.h"
#import "UIColor+Addition.h"

@implementation GCAudioPlayRateView{
    NSArray *_rateArray;            //播放速度选项
    NSMutableArray *_rateButtonArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentRate = 1.0;
        _rateArray = @[@"0.75", @"1.0", @"1.25", @"1.5", @"1.75", @"2.0"];
        _rateButtonArray = [NSMutableArray arrayWithCapacity:_rateArray.count];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, kScreenWidth-32, 44)];
    title.text = @"播放速度";
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    title.textColor = [UIColor colorWithARGBString:@"#333333"];
    [self addSubview:title];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(title.frame), kScreenWidth, 1)];
    line.backgroundColor = [UIColor colorWithARGBString:@"#F5F5F5"];
    [self addSubview:line];
    
    CGFloat buttonY = CGRectGetMaxY(line.frame);
    for (int i=0; i<_rateArray.count; i++) {
        UIButton *rateButton = [[UIButton alloc] initWithFrame:CGRectMake(16, buttonY, kScreenWidth-32, 44)];
        rateButton.tag = 100+i;
        rateButton.backgroundColor = [UIColor clearColor];
        NSString *rateString = _rateArray[i];
        if (_currentRate == [rateString floatValue]) {
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#3098F2"] forState:UIControlStateNormal];
        }else{
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#333333"] forState:UIControlStateNormal];
        }
        [rateButton setTitle:[NSString stringWithFormat:@"X%@", rateString] forState:UIControlStateNormal];
        rateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        rateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [rateButton addTarget:self action:@selector(rateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rateButton];
        [_rateButtonArray addObject:rateButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, rateButton.frame.size.height-1, rateButton.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithARGBString:@"#F5F5F5"];
        [rateButton addSubview:lineView];
        
        buttonY += 44;
    }
    
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, buttonY+SafeAreaBottomHeight);
}

- (void)rateButtonAction:(UIButton *)sender {
    NSString *rateString = _rateArray[sender.tag-100];
    self.currentRate = [rateString floatValue];
    if (self.rateBlock) self.rateBlock(_currentRate);
}

#pragma mark - setter

- (void)setCurrentRate:(CGFloat)currentRate {
    _currentRate = currentRate;
    for (int i=0; i<_rateArray.count; i++) {
        UIButton *rateButton = _rateButtonArray[i];
        NSString *rateString = _rateArray[i];
        if (currentRate == [rateString floatValue]) {
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#3098F2"] forState:UIControlStateNormal];
        }else{
            [rateButton setTitleColor:[UIColor colorWithARGBString:@"#333333"] forState:UIControlStateNormal];
        }
    }
}

@end
