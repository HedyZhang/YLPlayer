//
//  GQPlayerViewController.m
//  GuangQuan
//
//  Created by zhanghaidi on 16/8/1.
//  Copyright © 2016年 Fermion. All rights reserved.
//

#import "YLPlayerViewController.h"
#import "YLPlayerView.h"

@interface YLPlayerViewController ()

@property (nonatomic, strong) NSURL *playURL;
@property (nonatomic, strong) YLPlayerView *playerView;

@end

@implementation YLPlayerViewController

- (instancetype)initWithContentURL:(NSURL *)contentURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.playURL = [contentURL copy];
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [self.playerView releasePlayer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.view.backgroundColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMedia) name:kCloseMediaNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMedia) name:kMediaPlayFailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMedia) name:kMediaPlayDidEndNotification object:nil];
    [self initPlayer];
}

- (void)closeMedia {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initPlayer {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.playerView = [[YLPlayerView alloc] initWithFrame:self.view.bounds videoURLStr:self.playURL.absoluteString];
    self.playerView.contrainerView = self.view;
    self.playerView.videoControl.isFullScreen = YES;
    self.playerView.videoControl.isUpdateTopViewLayout = YES;
    [self.view addSubview:self.playerView];
}

@end
