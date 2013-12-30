//
//  PushNotificationManager.m
//  Ripple
//
//  Created by Kevin Johnson on 12/16/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "PushNotificationManager.h"
#import "RPGlobals.h"
#import "../../Pods/AFNetworking/AFNetworking/AFNetworking.h"

#import "RippleJSManager.h"

@interface PushNotificationManager () {
    NSString * _deviceToken;
}

@end

@implementation PushNotificationManager

-(BOOL)isNotificationsEnabled
{
    
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    return types & UIRemoteNotificationTypeAlert;
}


- (id)init
{
    self = [super init];
    if (self) {
        _deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"push_device"];
    }
    return self;
}

-(void)registerPushNotifications:(BOOL)enabled
{
    // TODO: finish
#if !TARGET_IPHONE_SIMULATOR
    
    if (enabled) {
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    else {
        // Disable
        // Tell server to stop notifications
        
    }
    
#endif
}

-(void)receivedDeviceToken:(NSData*)deviceToken
{
    if (deviceToken && deviceToken.description && [deviceToken.description isKindOfClass:[NSString class]]) {
        _deviceToken = [deviceToken description];
        
        // Remove formatting
        _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
        _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
        _deviceToken = [_deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken.description forKey:@"push_device"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"My token is: %@", _deviceToken);
        
        [self uploadDeviceToken];
    }
}

-(void)receivedRemoteNotification:(NSDictionary*)userInfo
{
#if !TARGET_IPHONE_SIMULATOR
    NSDictionary * aps = [userInfo objectForKey:@"aps"];
    if (!aps) {
        return;
    }
    
    NSString * message = [userInfo objectForKey:@"msg"];
    
    //NSString * title = [aps objectForKey:@"alert"];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: message
                          message: nil
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
    
    //    NSLog(@"remote notification: %@",[userInfo description]);
    //    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    //
    //    NSString *alert = [apsInfo objectForKey:@"alert"];
    //    NSLog(@"Received Push Alert: %@", alert);
    //
    //    NSString *sound = [apsInfo objectForKey:@"sound"];
    //    NSLog(@"Received Push Sound: %@", sound);
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //
    //    NSString *badge = [apsInfo objectForKey:@"badge"];
    //    NSLog(@"Received Push Badge: %@", badge);
    //    application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
#endif
}

-(void)uploadDeviceToken
{
    [self enablePushNotifications:YES];
}

-(void)enablePushNotifications:(BOOL)enable
{
    NSString * wallet = [[RippleJSManager shared] rippleWalletAddress];
    if (_deviceToken && wallet) {
        NSDictionary *parameters = @{
                                     @"udid": _deviceToken,
                                     @"ripple_address": wallet
                                     };
        
        NSString * url;
        if (enable) {
            url = GLOBAL_PUSH_NOTIFICATION_ENABLE;
        }
        else {
            url = GLOBAL_PUSH_NOTIFICATION_DISABLE;
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else {
        NSLog(@"%@: No device token, wallet address or push notification set",self);
    }
}

@end
