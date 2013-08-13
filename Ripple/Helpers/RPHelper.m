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

+(NSNumber*)dropsToRipples:(NSNumber*)drops
{
    return [NSNumber numberWithUnsignedLongLong:(drops.unsignedLongLongValue / XRP_FACTOR)];
}

+(NSNumber*)ripplesToDrops:(NSNumber*)ripples
{
    return [NSNumber numberWithUnsignedLongLong:(ripples.unsignedLongLongValue * XRP_FACTOR)];
}

@end
