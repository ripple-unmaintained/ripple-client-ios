//
//  RPAvailablePath.h
//  Ripple
//
//  Created by Kevin Johnson on 8/5/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPAvailablePath : NSObject

@property (strong, nonatomic) NSString * currency;
@property (strong, nonatomic) NSString * issuer;
@property (strong, nonatomic) NSNumber * value;

@end
