//
//  RippleJSManager+Authentication.h
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager.h"

@interface RippleJSManager (Authentication)

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block;
-(void)logout;

-(BOOL)isLoggedIn;
-(void)checkForLogin;

-(NSString*)account_id;
-(NSString*)username;

@end
