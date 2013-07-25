//
//  WebViewBridgeManager.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RippleJSManager : NSObject

+(RippleJSManager*)shared;

-(void)setLog:(UITextView*)textView;


-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block;
-(void)logout;

-(void)connect;

-(void)rippleFindPath:(NSDictionary*)params;
-(void)rippleSendTransactionAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSError* error))block;

-(BOOL)isLoggedIn;
-(BOOL)isConnected;

-(NSString*)rippleWalletAddress;
-(NSArray*)rippleContacts;
-(NSDictionary*)rippleBalances;

@end
