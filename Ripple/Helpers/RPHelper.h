//
//  RPHelper.h
//  Ripple
//
//  Created by Kevin Johnson on 7/31/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPHelper : NSObject

+(NSNumber*)safeNumberFromDictionary:(NSDictionary*)dic withKey:(NSString*)key;
+(NSNumber*)dropsToRipples:(NSNumber*)drops;
+(NSNumber*)ripplesToDrops:(NSNumber*)ripples;

@end
