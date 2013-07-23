//
//  RPTransactionSubscription.h
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTransactionSubscription : NSObject

@property (strong, nonatomic) NSString * engine_result;
@property (strong, nonatomic) NSString * engine_result_code;
@property (strong, nonatomic) NSString * engine_result_message;
@property (strong, nonatomic) NSString * ledger_hash;
@property (strong, nonatomic) NSString * ledger_index;
@property (strong, nonatomic) NSString * meta;
@property (strong, nonatomic) NSString * nmeta;
@property (strong, nonatomic) NSString * status;
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSString * validated;


@end
