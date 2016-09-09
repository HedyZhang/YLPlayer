//
//  GQPlayerView.h
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/22.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YLVideoPlaybackState) {
    YLVideoPlaybackStateBackward,
    YLVideoPlaybackStateForward,
};

@interface YLVideoPlayerTimeIndicatorView : UIView

@property (nonatomic, strong, readwrite) NSString *labelText;
@property (nonatomic, assign, readwrite) YLVideoPlaybackState playState;

@end
