//
//  PushNotificationManager.m
//  Ripple
//
//  Created by Kevin Johnson on 12/16/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "PushNotificationManager.h"
#import "../../Pods/AFNetworking/AFNetworking/AFNetworking.h"

@implementation PushNotificationManager

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)registerPushNotifications
{
    // TODO: finish
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"foo": @"bar"};
    [manager POST:@"http://example.com/resources.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
