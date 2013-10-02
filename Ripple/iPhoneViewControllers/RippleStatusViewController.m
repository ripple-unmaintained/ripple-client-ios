//
//  RippleStatusViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/24/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleStatusViewController.h"
#import "RippleJSManager.h"

@interface RippleStatusViewController () {
    UILabel * labelStatus;
    
    BOOL  showingDisconnected;
}

@end

@implementation RippleStatusViewController

-(void)RippleJSManagerConnected
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)RippleJSManagerDisconnected
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 20.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//-(void)connectedNoAnimation
//{
//    CGRect f = self.view.frame;
//    f.origin.y = 0.0f;
//    self.view.frame = f;
//}
//
//-(void)disconnectedNoAnimation
//{
//    CGRect f = self.view.frame;
//    f.origin.y = 20.0f;
//    self.view.frame = f;
//}

-(void)checkNetworkStatus
{
    if ([[RippleJSManager shared] isConnected]) {
        [self RippleJSManagerConnected];
    }
    else {
        [self RippleJSManagerDisconnected];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Subscribe to ripple network state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RippleJSManagerConnected) name:kNotificationRippleConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RippleJSManagerDisconnected) name:kNotificationRippleDisconnected object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus) name: UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self performSelector:@selector(checkNetworkStatus) withObject:nil afterDelay:0.1];
    [self checkNetworkStatus];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Unsubscribe to ripple network state
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRippleConnected object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRippleDisconnected object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    CGRect f = CGRectMake(0, -20, 320, 20);
    labelStatus = [[UILabel alloc] initWithFrame:f];
    labelStatus.text = @"Reconnecting...";
    [labelStatus setTextAlignment:NSTextAlignmentCenter];
    labelStatus.textColor = [UIColor whiteColor];
    labelStatus.backgroundColor = [UIColor blackColor];
    
    self.view.clipsToBounds = NO;
    [self.view addSubview:labelStatus];
    
    if (![[RippleJSManager shared] isConnected]) {
        CGRect f = self.view.frame;
        f.origin.y = 20.0f;
        self.view.frame = f;
        
        showingDisconnected = YES;
    }
    else {
        showingDisconnected = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
