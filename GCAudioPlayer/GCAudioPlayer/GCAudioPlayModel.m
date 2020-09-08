//
//  GCAudioPlayModel.m
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/4.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import "GCAudioPlayModel.h"

@implementation GCAudioPlayModel

- (void)setAudioPic:(NSString *)audioPic {
    _audioPic = audioPic;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSString -> NSURL -> NSData -> UIImage
        NSURL *imageURL = [NSURL URLWithString:audioPic];
        //下载图片
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image) {
            self.coverImage = image;
        }
    });
}

@end
