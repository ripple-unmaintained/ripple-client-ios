//
//  RippleJSManager+SendTransaction.h
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager.h"

@interface RippleJSManager (SendTransaction)

-(void)wrapperFindPathWithAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSArray * paths, NSError* error))block;
-(void)wrapperSendTransactionAmount:(NSNumber*)amount fromCurrency:(NSString*)from_currency toRecipient:(NSString*)recipient toCurrency:(NSString*)to_currency withBlock:(void(^)(NSError* error))block;
-(void)wrapperIsValidAccount:(NSString*)account withBlock:(void(^)(NSError* error))block;

@end
