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

//#import "RippleJSManager.h"

@interface PushNotificationManager () {
    NSString * _deviceToken;
    NSString * _wallet;
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

-(void)registerPushNotifications:(BOOL)enabled withWallet:(NSString*)wallet
{
    
#if !TARGET_IPHONE_SIMULATOR
    
    if (enabled) {
        _wallet = wallet;
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    else {
        // Disable
        _wallet = nil;
        // Tell server to stop notifications
        [self pushNotificationEnable:NO withWallet:wallet];
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
        
        [[NSUserDefaults standardUserDefaults] setObject:_deviceToken forKey:@"push_device"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"My token is: %@", _deviceToken);
        
        [self pushNotificationEnable:YES withWallet:_wallet];
    }
}

-(void)receivedRemoteNotification:(NSDictionary*)userInfo
{
#if !TARGET_IPHONE_SIMULATOR
    NSDictionary * aps = [userInfo objectForKey:@"aps"];
    if (!aps) {
        return;
    }
    
    //NSLog(@"%@", userInfo);
    
    NSString * message = [aps objectForKey:@"alert"];
    
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

-(void)pushNotificationEnable:(BOOL)enable withWallet:(NSString*)wallet
{
    if (_deviceToken && wallet) {
        NSDictionary *parameters = @{
                                     @"udid": _deviceToken,
                                     @"ripple_address": wallet
                                     };
        
        NSString * url;
        
#if defined(DEBUG)
        url = enable ? GLOBAL_PUSH_NOTIFICATION_DEV_ENABLE: GLOBAL_PUSH_NOTIFICATION_DEV_DISABLE;
#else
        url = enable ? GLOBAL_PUSH_NOTIFICATION_PROD_ENABLE: GLOBAL_PUSH_NOTIFICATION_PROD_DISABLE;
#endif
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            //NSLog(@"Response: %@", operation.responseData);
        }];
    }
    else {
        NSLog(@"%@: No device token, wallet address or push notification set",self);
    }
}

@end
