//
//  RippleJSManager+NetworkStatus.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+NetworkStatus.h"

@implementation RippleJSManager (NetworkStatus)

-(void)wrapperRegisterBridgeHandlersNetworkStatus
{
    // Connected to Ripple network
    [_bridge registerHandler:@"connected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"connected called: %@", data);
        _isConnected = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRippleConnected object:nil userInfo:nil];
    }];
    
    // Disconnected from Ripple network
    [_bridge registerHandler:@"disconnected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"disconnected called: %@", data);
        _isConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRippleDisconnected object:nil userInfo:nil];
    }];
}

@end
