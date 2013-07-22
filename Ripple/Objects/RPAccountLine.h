//
//  RPAccountLine.h
//  Ripple
//
//  Created by Kevin Johnson on 7/19/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAccountLine : NSObject

@property (strong, nonatomic) NSString * account;
@property (strong, nonatomic) NSNumber * balance;
@property (strong, nonatomic) NSString * currency;
@property (strong, nonatomic) NSNumber * limit;
@property (strong, nonatomic) NSNumber * limit_peer;
@property (strong, nonatomic) NSNumber * quality_in;
@property (strong, nonatomic) NSNumber * quality_out;

@end
