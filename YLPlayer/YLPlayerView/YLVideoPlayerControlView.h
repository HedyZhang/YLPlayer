//
//  ZXVideoPlayerControlView.h
//  ZXVideoPlayer
//
//  Created by Shawn on 16/4/21.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

#import "YLVideoPlayerTimeIndicatorView.h"
#import "YLPlayerSlider.h"

#define kGQPlayerControlViewHideNotification @"GQPlayerControlViewHideNotification"

@protocol YLVideoPlayerControlViewDelegage <NSObject>

@optional
- (BOOL)availableVideoPlayerControlViewDidTapped;
- (void)videoPlayerControlViewDidDoubleTapped;
- (void)videoPlayerControlViewPanGesture:(UIPanGestureRecognizer *)pan;

@end

@interface YLVideoPlayerControlView : UIView

@property (nonatomic, assign) id<YLVideoPlayerControlViewDelegage> delegate;

@property (nonatomic, strong) UIView   *topView;
@property (nonatomic, strong) UIView   *bottomView;
//滑杆
@property (nonatomic, strong) YLPlayerSlider *progressSlider;
//播放时间
@property (nonatomic, strong) UILabel  *timeLabel;
//全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;
//播放、暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;
//是否top、bottom在显示
@property (nonatomic, assign) BOOL  isBarShowing;
//返回按钮
@property (nonatomic, strong) UIButton *backButton;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;
// 快进、快退指示器
@property (nonatomic, strong) YLVideoPlayerTimeIndicatorView *timeIndicatorView;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign) BOOL isUpdateTopViewLayout;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

//添加音量、亮度、快进/快退手势
- (void)addGesture;

@end
