//
//  RPNewTransaction.h
//  Ripple
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPNewTransaction : NSObject

@property (strong, nonatomic) NSString * Account;
@property (strong, nonatomic) NSNumber * Amount;
@property (strong, nonatomic) NSString * Destination;
@property (strong, nonatomic) NSString * Destination_name;
@property (strong, nonatomic) NSString * Currency;
@property (strong, nonatomic) NSDate   * Date;

@end
