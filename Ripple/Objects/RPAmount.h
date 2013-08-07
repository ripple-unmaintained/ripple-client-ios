//
//  RPAmount.h
//  Ripple
//
//  Created by Kevin Johnson on 8/7/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAmount : NSObject

@property (strong, nonatomic) NSString * currency;
@property (strong, nonatomic) NSString * issuer;
@property (strong, nonatomic) NSNumber * value;

//-(NSDictionary*)toDictionary;
-(id)initWithObject:(id)object;

@end
