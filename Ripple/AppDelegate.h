//
//  AppDelegate.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BalancesViewController, PushNotificationManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UIViewController * viewControllerBalance;

@property (strong, nonatomic, retain) NSDate *startTime;
@property (strong, nonatomic) PushNotificationManager * pushNotificationManager;

@end
