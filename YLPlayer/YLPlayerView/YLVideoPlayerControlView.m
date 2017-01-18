//
//  ZXVideoPlayerControlView.m
//  ZXVideoPlayer
//
//  Created by Shawn on 16/4/21.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "YLVideoPlayerControlView.h"

static const CGFloat kVideoControlAnimationTimeInterval = 0.3;
static const CGFloat kVideoControlBarAutoFadeOutTimeInterval = 5.0;

@interface YLVideoPlayerControlView ()<UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL isHasGesture;
@end

@implementation YLVideoPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isBarShowing = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];        
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        // 快进、快退指示器
        [self addSubview:self.timeIndicatorView];
        
        [self bringSubviewToFront:self.bottomView];
        [self bringSubviewToFront:self.topView];
        
        [self configConstraints];
        self.isHasGesture = NO;
    }
    return self;
}

- (void)configConstraints {
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.equalTo(self.topView).offset(10);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.topView);
    }];
    
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(8);
        make.centerY.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-8);
        make.top.bottom.equalTo(self.bottomView);
        make.width.equalTo(self.fullScreenBtn.mas_height).multipliedBy(1);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullScreenBtn.mas_left);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.timeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playOrPauseBtn.mas_right).with.offset(8);
        make.right.equalTo(self.timeLabel.mas_left).with.offset(-8);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [self.timeIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(96, 60));
    }];
}

/**
 添加屏幕手势
 */
- (void)addGesture {
    if (!self.isHasGesture) {
        //单击
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        //双击
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        [singleTap requireGestureRecognizerToFail:pan];
        [doubleTap requireGestureRecognizerToFail:pan];
        self.isHasGesture = YES;
    }
}

#pragma mark - Setter

- (void)setIsUpdateTopViewLayout:(BOOL)isUpdateTopViewLayout {
    _isUpdateTopViewLayout = isUpdateTopViewLayout;
    if (isUpdateTopViewLayout) {
        if (!self.isBarShowing) {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(60);
                make.top.equalTo(self).offset(-60);
            }];
            
        } else {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(60);
            }];
        }
        
        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView).offset(10);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(self.topView).offset(10);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.topView);
            make.centerY.equalTo(self.topView).offset(10);
        }];

        
    } else {
        if (self.isBarShowing) {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(40);
            }];
        } else {
            [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(40);
                make.top.equalTo(self).offset(-40);
            }];
        }
        
        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(self.topView).offset(10);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topView);
        }];
    }
}


- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;    
    if (_isFullScreen || self.isUpdateTopViewLayout) {
        if (!self.isBarShowing) {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(60);
                make.top.equalTo(self).offset(-60);
            }];

        } else {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(60);
            }];
        }
        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView).offset(10);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(self.topView).offset(10);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.topView);
            make.centerY.equalTo(self.topView).offset(10);
        }];
        
    } else {
        if (self.isBarShowing) {
            [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self);
                make.height.mas_equalTo(40);
            }];
        } else {
            [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(40);
                make.top.equalTo(self).offset(-40);
            }];
        }
        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(self.topView).offset(10);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topView);
        }];
    }
}

#pragma mark - Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]] || [touch.view.accessibilityIdentifier isEqualToString:@"TopView"]) {
        return NO;
    }
    return YES;
}


- (void)onTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        BOOL isAvailable = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(availableVideoPlayerControlViewDidTapped)]) {
           isAvailable = [self.delegate availableVideoPlayerControlViewDidTapped];
        }
        if (!isAvailable) {
            return;
        }
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }
}

- (void)onDoubleTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerControlViewDidDoubleTapped)]) {
        [self.delegate videoPlayerControlViewDidDoubleTapped];
    }
}

- (void)panDirection:(UIPanGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerControlViewPanGesture:)]) {
        [self.delegate videoPlayerControlViewPanGesture:gesture];
    }
}

- (void)showControlView {
    if (_isFullScreen || self.isUpdateTopViewLayout) {
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(60);
        }];
    } else {
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(40);
        }];
    }
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
}

- (void)hiddenControlView {
    if (_isFullScreen || self.isUpdateTopViewLayout) {
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(60);
            make.top.equalTo(self).offset(-60);
        }];
    } else {
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.height.mas_equalTo(40);
            make.top.equalTo(self).offset(-40);
        }];
    }
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self).offset(40);
    }];
}

- (void)animateHide {
    if (!self.isBarShowing) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kGQPlayerControlViewHideNotification object:nil];
    
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        [self hiddenControlView];
        [self layoutIfNeeded];
        if (self.isFullScreen) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    } completion:^(BOOL finish){
        if (finish) {
            self.isBarShowing = NO;
        }
    }];
}

- (void)animateShow {
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeInterval animations:^{
        [self showControlView];
        [self layoutIfNeeded];
        if (self.isFullScreen) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
    } completion:^(BOOL finish){
        if (finish) {
            self.isBarShowing = YES;
            [self autoFadeOutControlBar];
        }
    }];

}


- (void)autoFadeOutControlBar {
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeInterval];
}

- (void)cancelAutoFadeOutControlBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}


#pragma mark - Getter

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.accessibilityIdentifier = @"TopView";
        _topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [_topView addSubview:self.backButton];
        [_topView addSubview:self.titleLabel];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [_bottomView addSubview:self.playOrPauseBtn];
        [_bottomView addSubview:self.progressSlider];
        [_bottomView addSubview:self.fullScreenBtn];
        [_bottomView addSubview:self.timeLabel];
    }
    return _bottomView;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"player_pausekey"] forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
}

- (YLPlayerSlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[YLPlayerSlider alloc] initWithFrame:CGRectZero];
        _progressSlider.progressSlider.minimumValue = 0.0;
        _progressSlider.progressSlider.value = 0.0;
        [_progressSlider.progressSlider setThumbImage:[UIImage imageNamed:@"progressbar_dot"]  forState:UIControlStateNormal];
        [_progressSlider.progressSlider setMinimumTrackImage:[UIImage imageNamed:@"progressbar"] forState:UIControlStateNormal];
        [_progressSlider.progressSlider setMaximumTrackImage:[UIImage imageNamed:@"progressbar_default"] forState:UIControlStateNormal];
        _progressSlider.progressView.progressTintColor = [UIColor clearColor];
        _progressSlider.progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressSlider;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
    }
    return _timeLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"player_fullscreen"] forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_backButton setImage:[UIImage imageNamed:@"player_close"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (YLVideoPlayerTimeIndicatorView *)timeIndicatorView {
    if (!_timeIndicatorView) {
        _timeIndicatorView = [[YLVideoPlayerTimeIndicatorView alloc] initWithFrame:CGRectZero];
    }
    return _timeIndicatorView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

@end
