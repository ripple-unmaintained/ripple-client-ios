//
//  RPTxHistory.m
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RPTxHistory.h"

@implementation RPTxHistory

-(BOOL)isValid
{
    if (self.Amount && self.ToAccount && self.FromAccount && self.Currency) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
