//
//  RPLedgerClosed.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPLedgerClosed : NSObject

@property (strong, nonatomic) NSString *ledger_hash;
@property (strong, nonatomic) NSString *validated_ledgers;
@property (strong, nonatomic) NSString *type;

@property (strong, nonatomic) NSNumber *fee_base;
@property (strong, nonatomic) NSNumber *fee_ref;
@property (strong, nonatomic) NSNumber *ledger_index;
@property (strong, nonatomic) NSNumber *ledger_time;
@property (strong, nonatomic) NSNumber *reserve_base;
@property (strong, nonatomic) NSNumber *reserve_inc;
@property (strong, nonatomic) NSNumber *txn_count;

@end
