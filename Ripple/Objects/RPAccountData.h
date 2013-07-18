//
//  RPAccountData.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAccountData : NSObject

@property (strong, nonatomic) NSString * Account;
@property (strong, nonatomic) NSNumber * Balance;
@property (strong, nonatomic) NSString * LedgerEntryType;
@property (strong, nonatomic) NSString * PreviousTxnID;
@property (strong, nonatomic) NSString * PreviousTxnLgrSeq;
@property (strong, nonatomic) NSString * index;
@property (strong, nonatomic) NSNumber * Flags;
@property (strong, nonatomic) NSNumber * OwnerCount;
@property (strong, nonatomic) NSNumber * Sequence;

@end
