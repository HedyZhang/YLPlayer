
//
//  GQPlayerView.h
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/22.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "YLVideoPlayerControlView.h"

#define kDeviceOrientationDidChangeNotification @"GQPlayerViewDeviceOrientationDidChangeNotification"
#define kCloseMediaNotification @"GQPlayerViewCloseMediaNotification"
#define kMediaPlayFailNotification @"GQPlayerViewMediaPlayFailNotification"
#define kMediaPlayDidEndNotification @"GQPlayerViewMediaPlayDidEndNotification"

//音量、亮度调节因子
#define kPanVerticalControlScaleFactor 10000
//进度调节因子
#define kPanHorizontalControlScaleFactor 200

typedef NS_ENUM(NSInteger, YLPanDirection){
    YLPanDirectionNone,
    YLPanDirectionHorizontal, // 横向移动
    YLPanDirectionVertical,   // 纵向移动
};

typedef NS_ENUM(NSInteger, YLMoviePlaybackState) {
    YLMoviePlaybackStateStart,
    YLMoviePlaybackStateStopped,
    YLMoviePlaybackStatePlaying,
    YLMoviePlaybackStatePaused,
    YLMoviePlaybackStateFailed,
    YLMoviePlaybackStateSeeking,
    YLMoviePlaybackStateBuffering,
};



@import MediaPlayer;
@import AVFoundation;

@interface YLPlayerView : UIView

@property (nonatomic, weak) UIView   *contrainerView;
@property (nonatomic, copy) NSString *videoURLStr;
@property (nonatomic, copy) NSString *movieTitle;

@property (nonatomic, strong) AVPlayerItem *currentItem;

@property (nonatomic, strong) YLVideoPlayerControlView *videoControl;

//是否全屏
@property (nonatomic, assign) BOOL isFullscreen;

//是否显示controlView 默认YES
@property (nonatomic, assign) BOOL isControlShow;

//是否响应手势调节音量、亮度
@property (nonatomic, assign) BOOL shouldGestureChangeVertical;

//快进/快退
@property (nonatomic, assign) BOOL shouldGestureChangeHorizontal;

//是否支持自动转屏 default YES
@property (nonatomic, assign) BOOL shouldAutoOrientation;

//是否重复播放
@property (nonatomic, assign) BOOL isRepeatPlay;
//是否自动播放
@property (nonatomic, assign) BOOL shouldAutoplay;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL muted;
//是否被用户暂停
@property (nonatomic, assign) BOOL isPauseByUser;
//是否进入后台
@property (nonatomic, assign) BOOL isDidEnterBackground;

/**
 *  初始化Player的方法
 *
 *  @param frame       frame
 *  @param videoURLStr URL字符串，包括网络的和本地的URL
 *
 *  @return id类型，实际上就是Player的一个对象
 */
- (instancetype)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr;

- (void)play;
- (void)pause;

- (void)releasePlayer;

- (void)configSystemObserver;

- (void)removeSystemObserver;

@end
