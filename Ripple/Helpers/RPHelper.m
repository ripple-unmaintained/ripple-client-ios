//
//  RPHelper.m
//  Ripple
//
//  Created by Kevin Johnson on 7/31/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RPHelper.h"

@implementation RPHelper

+(NSNumber*)safeNumberFromDictionary:(NSDictionary*)dic withKey:(NSString*)key
{
    id tmp = [dic objectForKey:key];
    if ([tmp isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)tmp;
        // Convert string to nsnumber
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        [f setMaximumFractionDigits:20];
        return [f numberFromString:str];
    }
    else {
        return tmp;
    }
}

+(NSDecimalNumber*)safeDecimalNumberFromDictionary:(NSDictionary*)dic withKey:(NSString*)key
{
    id tmp = [dic objectForKey:key];
    if ([tmp isKindOfClass:[NSString class]]) {
        NSString * str = (NSString*)tmp;
        return [NSDecimalNumber decimalNumberWithString:str];
    }
    else {
        return tmp;
    }
}

+(NSDecimalNumber*)dropsToRipples:(NSDecimalNumber*)drops
{
    NSDecimal decimal = [drops decimalValue];
    NSDecimalNumber * dec = [NSDecimalNumber decimalNumberWithDecimal:decimal];\
    NSDecimalNumber * xrpF = [NSDecimalNumber decimalNumberWithString:XRP_FACTOR];
    NSDecimalNumber * result = [dec decimalNumberByDividingBy:xrpF];
    return result;
}

+(NSDecimalNumber*)ripplesToDrops:(NSDecimalNumber*)ripples
{
    NSDecimal decimal = [ripples decimalValue];
    NSDecimalNumber * dec = [NSDecimalNumber decimalNumberWithDecimal:decimal];\
    NSDecimalNumber * xrpF = [NSDecimalNumber decimalNumberWithString:XRP_FACTOR];
    NSDecimalNumber * result = [dec decimalNumberByMultiplyingBy:xrpF];
    return result;
}

@end
