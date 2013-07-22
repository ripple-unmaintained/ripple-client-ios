//
//  WebViewBridgeManager.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RippleJSManagerBalanceDelegate <NSObject>

@required
-(void)RippleJSManagerBalances:(NSDictionary*)balances;

@end

@interface RippleJSManager : NSObject

@property (weak ,nonatomic) id<RippleJSManagerBalanceDelegate> delegate_balances;

+(RippleJSManager*)shared;

-(void)setLog:(UITextView*)textView;


-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block;
-(void)logout;

-(void)rippleFindPath:(NSDictionary*)params;
-(void)rippleSendTransactionAmount:(NSNumber*)amount toRecipient:(NSString*)recipient withBlock:(void(^)(NSError* error))block;

-(BOOL)isLoggedIn;

@end
