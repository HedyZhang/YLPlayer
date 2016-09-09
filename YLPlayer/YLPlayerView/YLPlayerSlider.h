//
//  GQPlayerSlider.h
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/25.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YLPlayerSlider;
@protocol YLPlayerSliderDelegate <NSObject>

- (void)sliderValueChangeDidBegin:(YLPlayerSlider *)slider;
- (void)sliderValueChanged:(YLPlayerSlider *)slider;
- (void)sliderValueChangeDidEnd:(YLPlayerSlider *)slider;

@end

@interface YLPlayerSlider : UIControl

@property (nonatomic, weak) id <YLPlayerSliderDelegate> delegate;

@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *progressView;

@end
