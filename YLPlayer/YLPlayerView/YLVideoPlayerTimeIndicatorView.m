//
//  GQPlayerView.h
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/22.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import "YLVideoPlayerTimeIndicatorView.h"
#import "YLVideoPlayerControlView.h"

static const CGFloat kTimeIndicatorAutoFadeOutTimeInterval = 1.0;

@interface YLVideoPlayerTimeIndicatorView ()

@property (nonatomic, strong, readwrite) UIImageView *arrowImageView;
@property (nonatomic, strong, readwrite) UILabel     *timeLabel;

@end

@implementation YLVideoPlayerTimeIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        [self addSubview:self.arrowImageView];
        [self addSubview:self.timeLabel];
        [self configConstrints];
    }
    return self;
}

- (void)configConstrints {
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).offset(5);
        make.centerX.equalTo(self);
    }];
}

- (void)setLabelText:(NSString *)labelText {
    self.hidden = NO;
    self.timeLabel.text = labelText;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kTimeIndicatorAutoFadeOutTimeInterval];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.playState == YLVideoPlaybackStateBackward) {
        self.arrowImageView.image = [UIImage imageNamed:@"rewind"];
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"fastforward"];
    }
}

- (void)animateHide {
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.alpha = 1;
        self.superview.accessibilityIdentifier = nil;
    }];
}

#pragma mark - Getter 

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.backgroundColor = [UIColor clearColor];
    }
    return _arrowImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}


@end
