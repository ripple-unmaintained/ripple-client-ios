//
//  RPError.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPError : NSObject

@property (strong, nonatomic) NSString *error;
@property (strong, nonatomic) NSString *error_message;
@property (strong, nonatomic) NSDictionary *remote;

@end
