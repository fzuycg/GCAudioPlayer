//
//  ViewController.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "ViewController.h"
#import "GCAudioPlayModel.h"
#import "GCAudioPlayManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *infoModelArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AudioResource" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    self.infoModelArray = @[].mutableCopy;
    
    for (NSDictionary *dic in array) {
        GCAudioPlayModel *model = [[GCAudioPlayModel alloc] init];
        model.audioTitle = dic[@"audioName"];
        model.audioUrl = dic[@"audioUrl"];
        model.audioPic = dic[@"audioImage"];
        model.audioLength = 300;
        model.audioAuthor = dic[@"audioSinger"];
        model.audioAlbum = dic[@"audioAlbum"];
        model.audioLyrics = dic[@"audioLyric"];
        [self.infoModelArray addObject:model];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    button.center = self.view.center;
    [button setTitle:@"打开播放器" forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick:(UIButton *)sender {
    //准备资源
    [[GCAudioPlayManager sharedManager] loadAudioSouceWithArray:self.infoModelArray];
    
    //开始播放
    [[GCAudioPlayManager sharedManager] beginPlayTagAudioWithIndex:0 NarrowViewStatue:ViewFull];
}


@end
