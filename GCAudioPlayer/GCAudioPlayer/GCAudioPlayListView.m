//
//  GCAudioPlayListView.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayListView.h"
#import "GCAudioPlayListCell.h"
#import "GCConstantMacro.h"
#import "UIColor+Addition.h"

@interface GCAudioPlayListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *statueArray;

@property (nonatomic, assign) NSInteger currentSelectIndex;

@property (nonatomic, strong) UIImageView *styleImageView;
@property (nonatomic, strong) UILabel *playStyleLabel;

@end

@implementation GCAudioPlayListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *changeStyleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    changeStyleBtn.backgroundColor = [UIColor whiteColor];
    [changeStyleBtn addTarget:self action:@selector(changeStyleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:changeStyleBtn];
    
    _styleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 20, 20)];
    _styleImageView.image = [UIImage imageNamed:@"audioPlayer_shunxu_2"];
    [changeStyleBtn addSubview:_styleImageView];
    
    _playStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_styleImageView.frame)+4, _styleImageView.frame.origin.y, 120, _styleImageView.frame.size.height)];
    _playStyleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _playStyleLabel.text = @"顺序播放";
    _playStyleLabel.textColor = [UIColor colorWithARGBString:@"#333333"];
    [changeStyleBtn addSubview:_playStyleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(changeStyleBtn.frame), self.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor colorWithARGBString:@"#F5F5F5"];
    [self addSubview:lineView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), kScreenWidth, self.frame.size.height-CGRectGetMaxY(lineView.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    _tableView.separatorColor = [UIColor colorWithARGBString:@"#F5F5F5"];
    _tableView.rowHeight = 62;
    [self addSubview:_tableView];
}

- (void)changeStyleBtnAction {
    if (_playerStyle == CFTAudioPlayerStyle_list) {
        self.playerStyle = CFTAudioPlayerStyle_cyclic;
    } else if (_playerStyle == CFTAudioPlayerStyle_cyclic) {
        self.playerStyle = CFTAudioPlayerStyle_random;
    } else if (_playerStyle == CFTAudioPlayerStyle_random) {
        self.playerStyle = CFTAudioPlayerStyle_list;
    }
    
    if (self.playerStyleBlock) self.playerStyleBlock(_playerStyle);
}

#pragma mark - setter && getter

- (NSMutableArray *)allListModelArray {
    if (_allListModelArray == nil) {
        _allListModelArray = [NSMutableArray array];
    }
    return _allListModelArray;;
}

- (void)setCurrentModel:(GCAudioPlayModel *)currentModel {
    _currentModel = currentModel;
    _statueArray = @[].mutableCopy;
    _currentSelectIndex = [self.allListModelArray indexOfObject:currentModel];
    [self setStatueWithAllData:self.allListModelArray currentIndex:_currentSelectIndex];
}

- (void)setPlayerStyle:(CFTAudioPlayerStyle)playerStyle {
    _playerStyle = playerStyle;
    if (_playerStyle == CFTAudioPlayerStyle_list) {
        _playStyleLabel.text = @"列表播放";
        _styleImageView.image = [UIImage imageNamed:@"audioPlayer_shunxu_2"];
    } else if (_playerStyle == CFTAudioPlayerStyle_cyclic) {
        _playStyleLabel.text = @"单曲循环";
        _styleImageView.image = [UIImage imageNamed:@"audioPlayer_xunhuan_2"];
    } else if (_playerStyle == CFTAudioPlayerStyle_random) {
        _playStyleLabel.text = @"随机播放";
        _styleImageView.image = [UIImage imageNamed:@"audioPlayer_suiji_2"];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  self.allListModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellContent = @"cellContent";
    GCAudioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellContent];
    if (!cell) {
        cell = [[GCAudioPlayListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellContent];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.playModel = self.allListModelArray[indexPath.row];
    cell.isPlaying =[_statueArray[indexPath.row] isEqualToString:@"1"] ? YES : NO;
    __weak typeof(self) weakSelf = self;
    
    cell.deleteCellBlock = ^(UIButton * _Nonnull sender) {
        CGPoint point = [sender convertPoint:sender.bounds.origin toView:tableView];
        NSIndexPath *newIndexPath = [tableView indexPathForRowAtPoint:point];
        
        [weakSelf.statueArray removeObjectAtIndex:newIndexPath.row];
        [weakSelf.allListModelArray removeObjectAtIndex:newIndexPath.row];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    };
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentSelectIndex = indexPath.row;
    [self setStatueWithAllData:self.allListModelArray currentIndex:_currentSelectIndex];
    if (self.readPlayAudio) self.readPlayAudio(indexPath.row, self.allListModelArray[indexPath.row]);
}

- (void)setStatueWithAllData:(NSArray *)allDate currentIndex:(NSInteger)currentIndex {
    [_statueArray removeAllObjects];
    for (NSInteger i = 0; i < allDate.count; i++) {
        if (currentIndex == i) {
            [_statueArray addObject:@"1"];
        }else {
            [_statueArray addObject:@"0"];
        }
    }
    
    [self.tableView reloadData];
}

@end
