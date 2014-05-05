//
//  AppDelegate.m
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "RPGlobals.h"
#import "PushNotificationManager.h"
#import "RippleJSManager.h"

//#define MIXPANEL_TOKEN @"27f807b416137d59b1802c7ebe6059b0"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
    //[Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // Later, you can get your instance with
    // Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        
//        [application setStatusBarStyle: UIStatusBarStyleLightContent];
//        
//        self.window.clipsToBounds =YES;
//        
//        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
//    }
    
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//        }
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:kNotificationUserLoggedIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:) name:kNotificationUserLoggedOut object:nil];
    
    self.pushNotificationManager = [PushNotificationManager new];
    //[self.pushNotificationManager registerPushNotifications];
    
    //[[UILabel appearance] setFont:[UIFont fontWithName:GLOBAL_FONT_NAME size:17.0]];
    //[[UIButton appearance] setFont:[UIFont fontWithName:GLOBAL_FONT_NAME size:17.0]];
    [[UITextField appearance] setFont:[UIFont fontWithName:GLOBAL_FONT_NAME size:17.0]];
    
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
    
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    self.startTime = [NSDate date];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%@ will resign active", self);
    //NSNumber *seconds = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime]];
    //[[Mixpanel sharedInstance] track:@"Session" properties:[NSDictionary dictionaryWithObject:seconds forKey:@"Length"]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)userLoggedIn
{
    NSString * wallet = [[RippleJSManager shared] rippleWalletAddress];
    [self.pushNotificationManager registerPushNotifications:YES withWallet:wallet];
}

-(void)userLoggedOut:(NSNotification *)notification
{
    NSString * wallet = (NSString*)[notification userInfo];
    [self.pushNotificationManager registerPushNotifications:NO withWallet:wallet];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [self.pushNotificationManager receivedDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self.pushNotificationManager receivedRemoteNotification:userInfo];
}

@end
