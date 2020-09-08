//
//  GCCoverImageView.h
//  GCAudioPlayer
//
//  Created by 杨春贵 on 2020/9/7.
//  Copyright © 2020 com.yangcg.learn. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCCoverImageView : UIImageView

@property (nonatomic, copy) NSString *imageUrl;

- (void)startRotating;

- (void)stopRotating;

- (void)resumeRotate;

@end

NS_ASSUME_NONNULL_END
