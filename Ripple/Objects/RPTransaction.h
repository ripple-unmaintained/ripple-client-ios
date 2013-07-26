//
//  RPTransaction.h
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPTransaction : NSObject

@property (strong, nonatomic) NSString * Account;
@property (strong, nonatomic) NSNumber * Amount;
@property (strong, nonatomic) NSString * Destination;
@property (strong, nonatomic) NSNumber * Fee;
@property (strong, nonatomic) NSNumber * Flags;
@property (strong, nonatomic) NSNumber * Sequence;
@property (strong, nonatomic) NSString * SigningPubKey;
@property (strong, nonatomic) NSString * TransactionType;
@property (strong, nonatomic) NSString * TxnSignature;
@property (strong, nonatomic) NSString * date;
@property (strong, nonatomic) NSString * hash;
@property (strong, nonatomic) NSString * inLedger;
@property (strong, nonatomic) NSString * ledger_index;

@end
