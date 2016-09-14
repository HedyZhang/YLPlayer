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
    videoURLStr = @"http://downmp413.ffxia.com/mp413/%E5%85%B3%E8%AF%97%E6%95%8F-%E9%A3%8E%E4%B9%8B%E6%81%8B[68mtv.com].mp4";
    
    [self startPlayVideoWithURL:videoURLStr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeMedia)
                                                 name:kCloseMediaNotification
                                               object:nil];
}

-(void)startPlayVideoWithURL:(NSString *)videoUrlStr{
    self.playerView = [[YLPlayerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width * 9 / 16.f) videoURLStr:videoUrlStr];
    self.playerView.isRepeatPlay = YES;
    self.playerView.contrainerView = self.view;
    self.playerView.shouldAutoplay = YES;
    [self.view addSubview:self.playerView];
}

- (void)closeMedia {
    [self.playerView releasePlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
