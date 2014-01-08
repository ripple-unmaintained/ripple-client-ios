//
//  PushNotificationManager.h
//  Ripple
//
//  Created by Kevin Johnson on 12/16/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationManager : NSObject

-(BOOL)isNotificationsEnabled;
-(void)registerPushNotifications:(BOOL)enabled withWallet:(NSString*)wallet;
-(void)receivedDeviceToken:(NSData*)deviceToken;
-(void)receivedRemoteNotification:(NSDictionary*)userInfo;

@end
