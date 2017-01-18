//
//  GQPlayerView.m
//  GQPlayer
//
//  Created by zhanghaidi on 16/8/25.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLPlayerBrightnessView : UIView

- (void)changeLightViewWithValue:(CGFloat)lightValue;

- (void)dismissLightViewAnimation:(void (^)(BOOL finished))completion;

@end
