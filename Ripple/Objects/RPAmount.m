//
//  RPAmount.m
//  Ripple
//
//  Created by Kevin Johnson on 8/7/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RPAmount.h"
#import "RPHelper.h"
#import "NSObject+KJSerializer.h"

@implementation RPAmount

//-(NSDictionary*)toDictionary
//{
//    
//}
-(id)initWithObject:(id)object
{
    self = [self init];
    if ([object isKindOfClass:[NSDictionary class]]) {
        // IOU Amount
        [self setDictionary:object];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        // XRP Amount
        self.currency = GLOBAL_XRP_STRING;
        
        NSString * str = (NSString*)object;
        // Convert string to nsnumber
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        [f setMaximumFractionDigits:20];
        NSNumber * num = [f numberFromString:str];
        self.value = [RPHelper dropsToRipples:num];
    }
    return self;
}

@end
