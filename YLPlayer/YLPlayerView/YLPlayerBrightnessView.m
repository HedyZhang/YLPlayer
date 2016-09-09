//
//  GQPlayerView.m
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/25.
//  Copyright © 2016年 yanshu. All rights reserved.
//
#import "YLPlayerBrightnessView.h"

@interface YLPlayerBrightnessView ()

@property (nonatomic, strong) UIImageView *lightImageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIView      *lightBackView;
@property (nonatomic, strong) NSMutableArray *tipArray;

@end

@implementation YLPlayerBrightnessView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 155, 155);
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.alpha = 0;
        
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
            effectView.frame = self.bounds;
            [self addSubview:effectView];
        } else {
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
            [self addSubview:toolbar];
        }
        
        [self addSubview:self.lightBackView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lightImageView];
        [self createTips];
    }
    return self;
}


// 创建 Tips
- (void)createTips {
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.lightBackView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.lightBackView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];
}


- (void)changeLightViewWithValue:(CGFloat)lightValue {
    self.alpha = 1.0;
    [self updateLongView:lightValue];
}

- (void)dismissLightViewAnimation:(void (^)(BOOL finished))completion {
    [UIView animateKeyframesWithDuration:1.f delay:1.f options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}


#pragma mark - 

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        _titleLabel.textColor = [UIColor colorWithRed:101 / 255.f green:102 / 255.f blue:105 / 255.f alpha:1.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.text = @"亮度";
    }
    return _titleLabel;
}


- (UIView *)lightBackView {
    if (!_lightBackView) {
        _lightBackView = [[UIView alloc] initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        _lightBackView.backgroundColor = [UIColor colorWithRed:101 / 255.f green:102 / 255.f blue:105 / 255.f alpha:1.0f];
    }
    return _lightBackView;
}

- (UIImageView *)lightImageView {
    if (!_lightImageView) {
        _lightImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _lightImageView.image = [UIImage imageNamed:@"player_brightness_bg"];
    }
    return _lightImageView;
}
@end