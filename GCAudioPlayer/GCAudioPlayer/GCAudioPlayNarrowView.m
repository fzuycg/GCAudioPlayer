//
//  GCAudioPlayNarrowView.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayNarrowView.h"
#import "AutoScrollLabel.h"
#import "UIView+Addtion.h"
#import "GCConstantMacro.h"
#import "Common.h"
#import "UIColor+Addition.h"
#import "GCPlayProgressView.h"
#import "GCAudioPlayModel.h"

@interface GCAudioPlayNarrowView()

@property(nonatomic, strong) UIButton *hiddenBtn;

@property(nonatomic, strong) UIButton *playBtn;

@property(nonatomic, strong) AutoScrollLabel *titleLable;

@property(nonatomic, strong) UILabel *timeLable;

@property(nonatomic, strong) UIButton *closeBtn;

@property(nonatomic, strong) GCPlayProgressView *progressView;

@end

@implementation GCAudioPlayNarrowView{
    CGFloat _btndge;   //按钮边距
    CGFloat _buttonRadius;  //按钮半径
}

- (instancetype)initWithFrame:(CGRect)frame AudioModel:(GCAudioPlayModel *)model{
    if (self = [super initWithFrame:frame]) {
        _currentPlayModel = model;
        [self initView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];//创建手势
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:pan];
        
        _btndge = (kScreenWidth-self.frame.size.width)/2;
        _buttonRadius = frame.size.width/2;
    }
    return self;
}

- (void)initView {
    // 设置渐变色
    UIColor *colorLeft = [UIColor colorWithARGBString:@"#34486E"];
    UIColor *colorRight = [[UIColor colorWithARGBString:@"#34486E"] colorWithAlphaComponent:0.6];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)colorLeft.CGColor,
                        (id)colorRight.CGColor];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    [self.layer addSublayer:gradient];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, self.frame.size.height)];
    [_closeBtn setImage:[UIImage imageNamed:@"narrow_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    _hiddenBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-26, 0, 26, self.frame.size.height)];
    [_hiddenBtn setImage:[UIImage imageNamed:@"narrow_left_btn"] forState:UIControlStateNormal];
    _hiddenBtn.selected = YES;
    [_hiddenBtn addTarget:self action:@selector(hideButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_hiddenBtn];
    
    _progressView = [[GCPlayProgressView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self addSubview:_progressView];
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(_hiddenBtn.frame)-30-5, 0, 30, self.frame.size.height)];
    [_playBtn setImage:[UIImage imageNamed:@"narrow_playBtn_puse"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"narrow_playBtn_play"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    _progressView.center = _playBtn.center;
    
    _titleLable = [[AutoScrollLabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_closeBtn.frame), (self.frame.size.height-32)/2, CGRectGetMinX(_playBtn.frame)-CGRectGetMaxX(_closeBtn.frame), 16)];
    _titleLable.font =FONT(16);
    _titleLable.textColor = [UIColor whiteColor];
    _titleLable.scrollSpeed = 30;
    _titleLable.textAlignment = NSTextAlignmentLeft;
    _titleLable.fadeLength = 12.f;
    _titleLable.scrollDirection = CBAutoScrollDirectionLeft;
    [_titleLable observeApplicationNotifications];
    _titleLable.text = _currentPlayModel.audioTitle;
    [self addSubview:_titleLable];
    
    UIImageView *audioCable = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_titleLable.frame), CGRectGetMaxY(_titleLable.frame)+2, 14, 14)];
    audioCable.image = [UIImage imageNamed:@"narrow_audioCable"];
    [self addSubview:audioCable];
    
    _timeLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(audioCable.frame)+2, audioCable.frame.origin.y, _titleLable.frame.size.width-16, 14)];
    _timeLable.font = FONT(14);
    _timeLable.textColor = [UIColor whiteColor];
    _timeLable.userInteractionEnabled = YES;
    NSString *lengthStr = [Common updataTimerLableWithSecond:_currentPlayModel.audioLength];
    _timeLable.text = [NSString stringWithFormat:@"00:00/%@", lengthStr];
    [self addSubview:_timeLable];
    
    UIButton *pushButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_closeBtn.frame), 0, CGRectGetMinX(_playBtn.frame)-CGRectGetMaxX(_closeBtn.frame), self.frame.size.height)];
    [pushButton addTarget:self action:@selector(pushBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pushButton];
}

- (void)pushBtnAction:(UIButton *)sender {
    if(self.bgImageViewTapAction) self.bgImageViewTapAction();
}

- (void)hideButtonAction:(UIButton *)sender {
    if(self.hideBtnAction) self.hideBtnAction(sender.selected);
    sender.selected = !sender.selected;
}

- (void)playBtnAction:(UIButton *)button{
    button.selected = !button.selected;
    if(self.playBtnAction) self.playBtnAction(button.selected);
}

- (void)closeButtonAction {
    if(self.closeBtnAction) self.closeBtnAction();
}

- (void)updateNewAudioWithModel:(GCAudioPlayModel *)model IsPlaying:(BOOL)isPlay{
    if (model != nil) {
        _currentPlayModel = model;
        _titleLable.text = model.audioTitle;
        [self updateCurrentProgress:0 totleTime:_currentPlayModel.audioLength];
        _playBtn.selected = !isPlay;
    }
}

- (void)updateCurrentProgress:(NSTimeInterval)currentProgress totleTime:(NSTimeInterval)totleTime {
    NSString *currentStr = [Common updataTimerLableWithSecond:currentProgress];
    NSString *lengthStr = [Common updataTimerLableWithSecond:totleTime];
    _timeLable.text = [NSString stringWithFormat:@"%@/%@", currentStr, lengthStr];
    _progressView.progress = currentProgress/totleTime;
}

#pragma mark - setter
- (void)setIsPlaying:(BOOL )isPlaying {
    _isPlaying = isPlaying;
    _playBtn.selected = !isPlaying;
}

#pragma mark - 手势
- (void)handlePan:(UIPanGestureRecognizer *)rec {
    
    CGFloat safeBottomDistance = 0;
    if (@available(iOS 11.0, *)) {
        safeBottomDistance = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    
    CGPoint point = [rec translationInView:[UIApplication sharedApplication].keyWindow];
    
    rec.view.center = CGPointMake(rec.view.center.x + point.x, rec.view.center.y + point.y);
    
    [rec setTranslation:CGPointZero inView:[UIApplication sharedApplication].keyWindow];
    
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (self.frame.origin.x < kScreenWidth/2) {
            [self viewMove:rec.view point:CGPointMake((_buttonRadius+_btndge), rec.view.center.y + point.y)];
            if (self.frame.origin.y < (START_POSITION+44) ) {
                [self viewMove:rec.view point:CGPointMake((_buttonRadius+_btndge), (START_POSITION+44) + (_buttonRadius+_btndge))];
            }
            if (self.frame.origin.y > kScreenHeight - (49+safeBottomDistance)) {
                [self viewMove:rec.view point:CGPointMake((_buttonRadius+_btndge), kScreenHeight - (49+safeBottomDistance) - (_buttonRadius+_btndge))];
            }
        }else {
            [self viewMove:rec.view point:CGPointMake(kScreenWidth - (_buttonRadius+_btndge), rec.view.center.y + point.y)];
            if (self.frame.origin.y < (START_POSITION+44) ) {
                [self viewMove:rec.view point:CGPointMake(kScreenWidth - (_buttonRadius+_btndge), (START_POSITION+44) + (_buttonRadius+_btndge))];
            }
            if (self.frame.origin.y > kScreenHeight - (49+safeBottomDistance)) {
                [self viewMove:rec.view point:CGPointMake(kScreenWidth - (_buttonRadius+_btndge), kScreenHeight - (49+safeBottomDistance) - (_buttonRadius+_btndge))];
            }
        }
    }
}

- (void)viewMove:(UIView *)view point:(CGPoint)point {
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.center = point;
                     }
                     completion:nil];
}

@end
