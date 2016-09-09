
//
//  GQPlayerView.m
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/22.
//  Copyright © 2016年 yanshu. All rights reserved.
//


#import "YLPlayerView.h"
#import "YLPlayerBrightnessView.h"

@interface YLPlayerView ()<YLVideoPlayerControlViewDelegage, YLPlayerSliderDelegate>

@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerLayer          *playerLayer;

@property (nonatomic, strong) UISlider               *systemVolumeSlider;

@property (nonatomic, strong) NSTimer                *durationTimer;
@property (nonatomic, assign) YLPanDirection         panDirection;
/// 快进退的总时长
@property (nonatomic, assign) CGFloat                sumTime;
/// 是否在调节音量
@property (nonatomic, assign) BOOL                   isVolumeAdjust;
@property (nonatomic, assign) YLMoviePlaybackState   playbackState;
@property (nonatomic, assign) CGRect                 originRect;
@property (nonatomic, strong) UIWindow               *myWindow;
@property (nonatomic, strong) YLPlayerBrightnessView *lightView;
@property (nonatomic, assign) CGFloat  currentVolume;

@end


@implementation YLPlayerView

- (void)dealloc {
    NSLog(@"dealloc");
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString {
    NSURL *movieURL;
      if ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"]) {
          movieURL = [NSURL URLWithString:urlString];
      } else {
          movieURL = [NSURL fileURLWithPath:urlString];
      }
    AVAsset *movieAsset = [AVURLAsset assetWithURL:movieURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    return playerItem;
}

- (instancetype)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
        self.videoURLStr = videoURLStr;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self configUI]; 
    }
    return self;
}

- (void)configUI {
    self.originRect = self.frame;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    self.myWindow = [[UIApplication sharedApplication].delegate window];
    [self addSubview:self.videoControl];
    
    if (CGRectEqualToRect(self.frame, CGRectMake(0, 0, kScreenWidth, kScreenHeight)) || CGRectEqualToRect(self.frame, CGRectMake(0, 0, kScreenHeight, kScreenWidth))) {
        self.videoControl.isUpdateTopViewLayout = YES;
    }
    [self configSystemVolume];
    [self initDefault];
    [self configConstrints];
    [self configSystemObserver];
    [self configControlAction];
}

- (void)initDefault {
    self.shouldGestureChangeVertical = YES;
    self.shouldGestureChangeHorizontal = YES;
    self.isPlaying = NO;
    self.isControlShow = YES;
    self.shouldAutoplay = YES;
    self.isPauseByUser = YES;
    self.shouldAutoOrientation = YES;
    self.playbackState = YLMoviePlaybackStateStart;
    self.videoControl.playOrPauseBtn.enabled = NO;
    self.videoControl.playOrPauseBtn.selected = YES;
}

- (void)configConstrints {
    self.videoControl.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)configSystemVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.systemVolumeSlider = [[UISlider alloc] init];
    self.systemVolumeSlider.backgroundColor = [UIColor clearColor];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.systemVolumeSlider = (UISlider *)view;
        }
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setImage:nil forState:UIControlStateNormal];
            [view sizeToFit];
        }
    }
    self.systemVolumeSlider.autoresizesSubviews = NO;
    self.systemVolumeSlider.autoresizingMask = UIViewAutoresizingNone;
    self.systemVolumeSlider.hidden = YES;
    
    self.currentVolume = self.systemVolumeSlider.value;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)configSystemObserver {
    //屏幕旋转通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChangeListenerCallback:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    //app放弃活跃
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

}

- (void)removeSystemObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)removePlayItemObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)addPlayItemObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，需要等待数据
    [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区有足够数据可以播放了
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"监听");
}

#pragma mark - 播放/暂停
- (void)play {
    if (self.isPlaying || !self.isPauseByUser) {
        return;
    }
    self.videoControl.playOrPauseBtn.selected = NO;
    [self.player play];
    self.isPlaying = YES;
}
- (void)pause {
    if (!self.isPlaying) {
        return;
    }
    self.videoControl.playOrPauseBtn.selected = YES;
    [self.player pause];
    self.isPlaying = NO;
    [self.currentItem.asset cancelLoading];
}

#pragma mark - App 系统通知

- (void)appWillResignActive:(NSNotification *)notification {
    self.isDidEnterBackground = YES;
    [self pause];
    [self stopDurationTimer];
    self.playbackState = YLMoviePlaybackStatePaused;
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    if (self.isDidEnterBackground) {
        [self.videoControl autoFadeOutControlBar];
        [self startDurationTimer];
        [self play];
         self.playbackState = YLMoviePlaybackStatePlaying;
        self.isDidEnterBackground = NO;
    }
}

#pragma mark - Setter

- (void)setIsControlShow:(BOOL)isControlShow {
    _isControlShow = isControlShow;
    self.videoControl.hidden = !_isControlShow;
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    self.videoControl.isFullScreen = _isFullscreen;
}

- (void)setMovieTitle:(NSString *)movieTitle {
    _movieTitle = movieTitle;
    self.videoControl.titleLabel.text = _movieTitle;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (_player) {
        self.player.muted = _muted;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
     UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        self.originRect = frame;
    }
}


#pragma mark - 添加按钮事件

// 控件点击事件
- (void)configControlAction {
    [self.videoControl.playOrPauseBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.backButton addTarget:self action:@selector(closeTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    self.videoControl.progressSlider.delegate = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.videoControl.frame = self.bounds;
}

#pragma mark - Action

- (void)playOrPause:(UIButton *)sender {
    [self.videoControl cancelAutoFadeOutControlBar];
    self.videoControl.playOrPauseBtn.selected = !sender.selected;
    self.isPauseByUser = !sender.selected;
    if (self.player.rate != 1.f && !self.videoControl.playOrPauseBtn.selected) {
        if ([self currentTime] == [self duration]) {
            [self setCurrentTime:0.f];
        }
        [self play];
    } else {
        [self pause];
    }
    [self.videoControl autoFadeOutControlBar];
}

- (void)fullScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.videoControl cancelAutoFadeOutControlBar];
    if (self.isFullscreen) {
        [self toOrientation:UIInterfaceOrientationPortrait];
    } else {
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
    }
    [self.videoControl autoFadeOutControlBar];
}

-(void)closeTheVideo:(UIButton *)sender {
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseMediaNotification object:nil];
}

- (void)sliderValueChangeDidBegin:(YLPlayerSlider *)slider {
    [self pause];
    self.playbackState = YLMoviePlaybackStatePaused;
    [self stopDurationTimer];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)sliderValueChanged:(YLPlayerSlider *)slider {
    self.playbackState = YLMoviePlaybackStateSeeking;
    double currentTime = slider.progressSlider.value;
    CMTime playerDuration = [self playerItemDuration];
    double duration = CMTimeGetSeconds(playerDuration);
    self.videoControl.timeLabel.text = [[NSString alloc] initWithFormat:@"-%@", [self convertTime:duration - currentTime]];
}

- (void)sliderValueChangeDidEnd:(YLPlayerSlider *)slider {
    __weak __typeof(self) weakSelf = self;
    double seekToTime = floor(slider.progressSlider.value);
    [self setCurrentTime:seekToTime completionHandler:^(BOOL finished) {
        [weakSelf play];
        weakSelf.playbackState = YLMoviePlaybackStatePlaying;
        [weakSelf startDurationTimer];
        [weakSelf.videoControl autoFadeOutControlBar];
    }];
}

#pragma mark - 音量更新

- (void)updateSystemVolume {
    self.systemVolumeSlider.value = self.currentVolume;
}

#pragma mark - 定时器
//开启播放时间定时器
- (void)startDurationTimer {
    if (self.durationTimer) {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [self.durationTimer fire];
    NSLog(@"启动timer");

}

//暂停播放定时器
- (void)stopDurationTimer {
    if (self.durationTimer) {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
}

#pragma mark - 设置播放的视频

- (void)setVideoURLStr:(NSString *)videoURLStr {
    if (!videoURLStr) {
        return;
    }
    [self originSet];
    if (self.currentItem) {
        [self removePlayItemObserver];
    }
    self.currentItem = [self getPlayItemWithURLString:videoURLStr];
    
    if (!_player) {
        self.player = [AVPlayer playerWithPlayerItem:self.currentItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer.frame = self.bounds;
        [self.layer insertSublayer:self.playerLayer atIndex:0];
    }
    
    if (self.player.currentItem != self.currentItem) {
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
    }
    [self addPlayItemObserver];
    _videoURLStr = videoURLStr;
    self.player.muted = self.muted;
    if (self.shouldAutoplay) {
        [self play];
        self.playbackState = YLMoviePlaybackStatePlaying;
    }
}

- (void)originSet {
    self.videoControl.timeLabel.text = @"00:00";
    self.videoControl.progressSlider.progressSlider.value = 0;
}

- (void)moviePlayDidEnd:(NSNotification *)notification {
    __weak __typeof(self) weakSelf = self;
    NSLog(@"播放结束");
    self.playbackState = YLMoviePlaybackStateStopped;
    if (self.isRepeatPlay) {
        [self pause];
        [self setCurrentTime:0.0 completionHandler:^(BOOL finished) {
            [weakSelf play];
            weakSelf.playbackState  = YLMoviePlaybackStatePlaying;
            [weakSelf.videoControl.progressSlider.progressSlider setValue:0.0 animated:NO];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMediaPlayDidEndNotification object:nil userInfo:nil];
    }
}

#pragma mark - 播放item状态监测

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            NSLog(@"准备播放");
            if (CMTimeGetSeconds(self.player.currentItem.duration)) {
                self.videoControl.progressSlider.progressSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
            }
            self.videoControl.playOrPauseBtn.enabled = YES;
            self.playbackState = YLMoviePlaybackStatePlaying;
            [self.videoControl addGesture];
            [self startDurationTimer];
            [self.videoControl autoFadeOutControlBar];
            if (self.shouldAutoplay) {
                [self play];
            }
        } else if (status == AVPlayerItemStatusFailed){
            self.playbackState = YLMoviePlaybackStateFailed;
            [[NSNotificationCenter defaultCenter] postNotificationName:kMediaPlayFailNotification object:nil userInfo:nil];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.currentItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.videoControl.progressSlider.progressView setProgress:timeInterval / totalDuration animated:NO];
        
        // 如果缓冲和当前slider的差值超过0.1,自动播放，解决弱网情况下不会自动播放问题
//            BOOL delta = self.videoControl.progressSlider.progressView.progress - self.videoControl.progressSlider.progressSlider.value / self.videoControl.progressSlider.progressSlider.maximumValue > 0.05;
//            if (!self.isPauseByUser && !self.isDidEnterBackground && delta) {
//                if (self.shouldAutoplay) {
//                    [self play];
//                }
//            }

    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        // 当缓冲是空的时候
        if (self.currentItem.playbackBufferEmpty) {
            self.playbackState = YLMoviePlaybackStateBuffering;
            [self bufferingSomeSecond];
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        // 当缓冲好的时候
        if (self.currentItem.playbackLikelyToKeepUp && self.playbackState == YLMoviePlaybackStateBuffering){
            self.playbackState = YLMoviePlaybackStatePlaying;
        }
    }
}

#pragma mark - 计算缓冲进度

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.playbackState = YLMoviePlaybackStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
//    [self pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
//        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}

#pragma mark - Update Duration

//实时更新播放剩余时间
- (void)monitorVideoPlayback {
    if (self.playbackState == YLMoviePlaybackStateStart || self.playbackState == YLMoviePlaybackStatePlaying) {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoControl.progressSlider.progressSlider.minimumValue = 0.0;
            });
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)){
            double time = CMTimeGetSeconds([self.player currentTime]);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoControl.timeLabel.text = [[NSString alloc] initWithFormat:@"-%@", [self convertTime:duration - time]];
                self.videoControl.progressSlider.progressSlider.value = time;

            });
        }
    }
}

- (double)duration {
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    } else {
        return 0.f;
    }
}

- (double)currentTime {
    return CMTimeGetSeconds([[self player] currentTime]);
}

- (void)setCurrentTime:(double)time {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, 1)];

}

- (void)setCurrentTime:(double)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [self.player seekToTime:CMTimeMakeWithSeconds(time, 1)  completionHandler:completionHandler];
}

- (CMTime)playerItemDuration {
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return kCMTimeInvalid;
}

- (NSString *)convertTime:(NSInteger)second{
    NSInteger minutesRemaining = second / 60;
    NSInteger secondsRemaining = second % 60;
    NSString *timeString = [NSString stringWithFormat:@"%02zd:%02zd", minutesRemaining, secondsRemaining];
    return timeString;
}

// 快进/快退更新播放时间显示
- (void)setTimeLabelValues:(NSInteger)currentTime totalTime:(NSInteger)totalTime {
    NSInteger minutesElapsed = currentTime / 60;
    NSInteger secondsElapsed = currentTime % 60;
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02zd:%02zd", minutesElapsed, secondsElapsed];
    
    NSInteger minutesRemaining = totalTime / 60;
    NSInteger secondsRemaining = totalTime % 60;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02zd:%02zd", minutesRemaining, secondsRemaining];
    self.videoControl.timeIndicatorView.labelText = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

#pragma mark - 耳机事件
//耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉
            // 拔掉耳机继续播放
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}


#pragma mark - 音量、屏幕亮度、进度调节

- (BOOL)availableVideoPlayerControlViewDidTapped {
    return YES;
}

- (void)videoPlayerControlViewDidDoubleTapped {
    [self playOrPause:self.videoControl.playOrPauseBtn];
}

- (void)videoPlayerControlViewPanGesture:(UIPanGestureRecognizer *)pan {
    CGPoint locationPoint = [pan locationInView:self.videoControl];
    CGPoint veloctyPoint = [pan velocityInView:self.videoControl];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: { // 开始移动
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                if (!self.shouldGestureChangeHorizontal) {
                    self.panDirection = YLPanDirectionNone;
                } else {                    
                    self.panDirection = YLPanDirectionHorizontal;
                    self.sumTime = [self currentTime];
                    [self pause];
                    self.videoControl.playOrPauseBtn.selected = YES;
                    [self stopDurationTimer];

                }
            } else if (x < y) { // 垂直移动
                if (!self.shouldGestureChangeVertical) {
                    self.panDirection = YLPanDirectionNone;
                } else {
                    self.panDirection = YLPanDirectionVertical;
                    if (locationPoint.x > self.bounds.size.width / 2) {
                        // 音量调节
                        self.isVolumeAdjust = YES;
                    } else {
                        // 亮度调节
                        self.isVolumeAdjust = NO;
                    }
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged: { // 正在移动
            switch (self.panDirection) {
                case YLPanDirectionHorizontal: {
                    [self horizontalMoved:veloctyPoint.x];
                }
                    break;
                case YLPanDirectionVertical: {
                    [self verticalMoved:veloctyPoint.y];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateEnded: { // 移动停止
            switch (self.panDirection) {
                case YLPanDirectionHorizontal: {
                    [self setCurrentTime:self.sumTime];
                    [self play];
                    self.videoControl.playOrPauseBtn.selected = NO;
                    [self startDurationTimer];
                }
                    break;
                case YLPanDirectionVertical: {
                    if (!self.isVolumeAdjust) {
                        __weak __typeof(self) weakSelf = self;
                        [self.lightView dismissLightViewAnimation:^(BOOL finished) {
                            [weakSelf.lightView removeFromSuperview];
                            weakSelf.lightView = nil;
                        }];
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

// pan水平移动
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动叠加时间
    self.sumTime += value / kPanHorizontalControlScaleFactor;
    // 容错处理
    if (self.sumTime > self.duration) {
        self.sumTime = self.duration;
    } else if (self.sumTime < 0) {
        self.sumTime = 0;
    }
    // 时间更新
    double currentTime = self.sumTime;
    double totalTime = self.duration;
    [self setTimeLabelValues:currentTime totalTime:totalTime];

    // 播放进度更新
    self.videoControl.progressSlider.progressSlider.value = self.sumTime;
    
    // 快进or后退 状态调整
    YLVideoPlaybackState playState = YLVideoPlaybackStateBackward;
    
    if (value < 0) {
        playState = YLVideoPlaybackStateBackward;
    } else if (value > 0) {
        playState = YLVideoPlaybackStateBackward;
    }
    
    if (self.videoControl.timeIndicatorView.playState != playState) {
        if (value < 0) {
            self.videoControl.timeIndicatorView.playState = YLVideoPlaybackStateBackward;
            [self.videoControl.timeIndicatorView setNeedsLayout];
        } else if (value > 0) {
            self.videoControl.timeIndicatorView.playState = YLVideoPlaybackStateBackward;
            [self.videoControl.timeIndicatorView setNeedsLayout];
        }
    }
}

// pan垂直移动
- (void)verticalMoved:(CGFloat)value {
    if (self.isVolumeAdjust) {
        if (!_lightView) {
            [self.myWindow addSubview:self.lightView];
            [self.lightView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.lightView.superview);
                make.size.mas_equalTo(CGSizeMake(155, 155));
            }];
        }
        // 调节系统音量
        self.currentVolume -= value / kPanVerticalControlScaleFactor;
        [self updateSystemVolume];
    }else {
        // 亮度
        [self.myWindow bringSubviewToFront:self.lightView];
        [UIScreen mainScreen].brightness -= value / kPanVerticalControlScaleFactor;
        [self.lightView changeLightViewWithValue:[UIScreen mainScreen].brightness];
    }
}

#pragma mark - 屏幕旋转

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (currentOrientation == orientation) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOrientationDidChangeNotification object:nil];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self removeFromSuperview];
        [self.contrainerView addSubview:self];
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = [self getOrientation:orientation];
            self.frame = self.originRect;
            self.videoControl.frame = self.bounds;
            self.playerLayer.frame = self.bounds;
        }];

    } else {
        [self removeFromSuperview];
        [self.myWindow addSubview:self];
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = [self getOrientation:orientation];
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
                 self.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
            } else {
                self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }
            self.lightView.transform = [self getOrientation:orientation];
            self.videoControl.frame = self.bounds;
            self.playerLayer.frame = self.bounds;
        }];
    }
}

- (CGAffineTransform)getOrientation:(UIInterfaceOrientation)orientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGAffineTransformIdentity;
    }
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        [self toPortraitUpdate];
        return CGAffineTransformIdentity;
    } else if (currentOrientation == UIInterfaceOrientationLandscapeLeft) {
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
        [self toLandscapeUpdate];
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

- (void)toPortraitUpdate {
    self.isFullscreen = NO;
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.videoControl.fullScreenBtn setImage:[UIImage imageNamed:@"player_fullscreen"] forState:UIControlStateNormal];
     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)toLandscapeUpdate {
    self.isFullscreen = YES;
    [self.videoControl.fullScreenBtn setImage:[UIImage imageNamed:@"player_shrinkscreen"] forState:UIControlStateNormal];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (!self.videoControl.isBarShowing && (currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)) {
         [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } else {
         [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

/// 设备旋转方向改变
- (void)onDeviceOrientationDidChange {
    if (!self.shouldAutoOrientation) {
        return;
    }
    UIDeviceOrientation orientation = self.getDeviceOrientation;
        switch (orientation) {
            case UIDeviceOrientationPortrait: {
                NSLog(@"home键在 下");
                [self toOrientation:UIInterfaceOrientationPortrait];
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown: {
                NSLog(@"home键在 上");
            }
                break;
            case UIDeviceOrientationLandscapeLeft: {
                NSLog(@"home键在 右");
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            }
                break;
            case UIDeviceOrientationLandscapeRight: {
                NSLog(@"home键在 左");
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
                break;
                
            default:
                break;
        }
}

- (UIDeviceOrientation)getDeviceOrientation {
    return [UIDevice currentDevice].orientation;
}

#pragma mark - Release 

- (void)releasePlayer {
    [self removeSystemObserver];
    [self removePlayItemObserver];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    [self pause];
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    [self.videoControl cancelAutoFadeOutControlBar];
    [self removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    self.currentItem = nil;
    self.playerLayer = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

}


#pragma mark - Getter

- (YLVideoPlayerControlView *)videoControl {
    if (!_videoControl) {
        _videoControl = [[YLVideoPlayerControlView alloc] init];
        _videoControl.backgroundColor = [UIColor clearColor];
        _videoControl.delegate = self;
    }
    return _videoControl;
}

- (YLPlayerBrightnessView *)lightView {
    if (!_lightView) {
        _lightView = [[YLPlayerBrightnessView alloc] init];
    }
    return _lightView;
}

@end
