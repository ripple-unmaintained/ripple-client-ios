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
    NSLog(@"RPAmount: %@", object);
    
    //NSLog(@"RPAmount: %@", object);
    NSDictionary * dic = (NSDictionary *)object;
    // IOU Amount
    id source_amount = [dic valueForKey:@"source_amount"];
    
    if ([source_amount isKindOfClass:[NSString class]]) {
        // XRP
        self.from_currency = GLOBAL_XRP_STRING;
        NSDecimalNumber * num = [NSDecimalNumber decimalNumberWithString:source_amount];
        self.from_amount = [RPHelper dropsToRipples:num];
    }
    else if ([source_amount isKindOfClass:[NSDictionary class]]) {
        // IOU
        self.from_currency = [source_amount valueForKey:@"currency"];
        self.from_amount = [RPHelper safeDecimalNumberFromDictionary:source_amount withKey:@"value"];
    }
    
    self.path = object;
    return self;
}

@end
