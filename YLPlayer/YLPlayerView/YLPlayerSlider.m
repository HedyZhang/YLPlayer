//
//  GQPlayerSlider.m
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/25.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import "YLPlayerSlider.h"

@interface YLPlayerSlider ()

//@property(nonatomic) float value;
//@property(nonatomic) float minimumValue;
//@property(nonatomic) float maximumValue;
//
////缓存值
//@property(nonatomic) float bufferValue;
//
//@property (nonatomic, strong) UIColor *thumbTintColor;
//
//@property (nonatomic, strong) UIColor *minimumTrackTintColor;
//
//@property (nonatomic, strong) UIColor *middleTrackTintColor;
//
//@property (nonatomic, strong) UIColor *maximumTrackTintColor;
//
//@property (nonatomic, strong) UIImage *thumbImage;
//
//@property (nonatomic, strong) UIImage *minimumTrackImage;
//
//@property (nonatomic, strong) UIImage *middleTrackImage;
//
//@property (nonatomic, strong) UIImage *maximumTrackImage;


@end

@implementation YLPlayerSlider


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.progressSlider];
        [self.progressSlider addSubview:self.progressView];
        [self.progressSlider sendSubviewToBack:self.progressView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.progressSlider.frame = self.bounds;
    if ([self.progressSlider minimumTrackImageForState:UIControlStateNormal]) {
        UIImage * minimumValueImage = [self.progressSlider minimumTrackImageForState:UIControlStateNormal];
        self.progressView.frame = CGRectMake(2, 0, self.progressSlider.bounds.size.width - 4, minimumValueImage.size.height);
        self.progressView.center = CGPointMake(self.progressSlider.bounds.size.width / 2.f, self.progressSlider.bounds.size.height / 2.f);
    } else {
       self.progressView.frame = self.progressSlider.bounds;
    }
}

#pragma mark - Setter
//
//- (void)setValue:(float)value {
//    _value = value;
//    if (_value > self.progressSlider.maximumValue) {
//        self.progressSlider.value = self.progressSlider.maximumValue;
//    } else {
//        self.progressSlider.value = _value;
//    }
//}
//
//- (void)setMinimumValue:(float)minimumValue {
//    _minimumValue = minimumValue;
//    if (_minimumValue < 0) {
//        _minimumValue = 0;
//    }
//    self.progressSlider.minimumValue = _minimumValue;
//}
//
//- (void)setMaximumValue:(float)maximumValue {
//    _maximumValue = maximumValue;
//    self.progressSlider.maximumValue = _maximumValue;
//}
//
//- (void)setBufferValue:(float)bufferValue {
//    _bufferValue = bufferValue;
//    if (_bufferValue > 1) {
//        self.progressView.progress = 1;
//    } else {
//        self.progressView.progress = _bufferValue;
//    }
//}
//
//- (void)setThumbTintColor:(UIColor *)thumbTintColor {
//    _thumbTintColor = thumbTintColor;
//    self.progressSlider.thumbTintColor = thumbTintColor;
//}
//
//- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
//    _minimumTrackTintColor = minimumTrackTintColor;
//    self.progressSlider.minimumTrackTintColor = minimumTrackTintColor;
//}
//
//- (void)setMiddleTrackTintColor:(UIColor *)middleTrackTintColor {
//    _middleTrackTintColor = middleTrackTintColor;
//    self.progressView.progressTintColor = middleTrackTintColor;
//}
//
//- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
//    _maximumTrackTintColor = maximumTrackTintColor;
//    self.progressSlider.maximumTrackTintColor = maximumTrackTintColor;
//}
//
//- (void)setThumbImage:(UIImage *)thumbImage {
//    _thumbImage = thumbImage;
//    [self.progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
//}
//
//- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
//    _minimumTrackImage = minimumTrackImage;
//    [self.progressSlider setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
//}
//
//- (void)setMiddleTrackImage:(UIImage *)middleTrackImage {
//    _middleTrackImage = middleTrackImage;
//    self.progressView.progressImage = _middleTrackImage;
//}
//
//- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
//    _maximumTrackImage = maximumTrackImage;
//    [self.progressSlider setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
//}

#pragma mark - Action

- (void)sliderValueChangeDidBegin {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChangeDidBegin:)]) {
        [self.delegate sliderValueChangeDidBegin:self];
    }
}

- (void)sliderValueChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:self];
    }
}

- (void)sliderValueChangeDidEnd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChangeDidEnd:)]) {
        [self.delegate sliderValueChangeDidEnd:self];
    }
}


#pragma mark - Getter 

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_progressSlider addTarget:self action:@selector(sliderValueChangeDidBegin) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(sliderValueChangeDidEnd) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(sliderValueChangeDidEnd) forControlEvents:UIControlEventTouchCancel];
        [_progressSlider addTarget:self action:@selector(sliderValueChangeDidEnd) forControlEvents:UIControlEventTouchUpOutside];
    }
    return _progressSlider;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressView.userInteractionEnabled = false;
    }
    return _progressView;
}

@end
