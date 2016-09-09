//
//  ViewController.m
//  YLPlayer
//
//  Created by zhanghaidi on 16/9/7.
//  Copyright © 2016年 yanshu. All rights reserved.
//

#import "ViewController.h"
#import "YLPlayerView.h"
@interface ViewController ()
{
    BOOL isSmallScreen;
    NSString *videoURLStr;
}
@property (nonatomic, strong) YLPlayerView *playerView;
@end

@implementation ViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.view.backgroundColor = [UIColor whiteColor];
    videoURLStr = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    [self startPlayVideoWithURL:videoURLStr];
}


-(void)startPlayVideoWithURL:(NSString *)videoUrlStr{
    self.playerView = [[YLPlayerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width * 9 / 16.f) videoURLStr:videoUrlStr];
    self.playerView.isRepeatPlay = YES;
    self.playerView.contrainerView = self.view;
    [self.view addSubview:self.playerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
