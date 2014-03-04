//
//  RPTxHistory.h
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTxHistory : NSObject

@property (strong, nonatomic) NSString * ToAccount;
@property (strong, nonatomic) NSString * FromAccount;
@property (strong, nonatomic) NSDecimalNumber * Amount;
@property (strong, nonatomic) NSString * Currency;

-(BOOL)isValid;

@end
