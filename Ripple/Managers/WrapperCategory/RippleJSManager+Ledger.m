//
//  RippleJSManager+Ledger.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+Ledger.h"

@implementation RippleJSManager (Ledger)

-(void)registerBridgeHandlers
{
    //    // Testing purposes
    //    [_bridge registerHandler:@"ledger_closed" handler:^(id data, WVJBResponseCallback responseCallback) {
    //        NSLog(@"ledger_closed called: %@", data);
    //        [self log:data];
    //
    //        RPLedgerClosed * obj = [RPLedgerClosed new];
    //        [obj setDictionary:data];
    //        // Validate?
    //
    //        //responseCallback(@"Response from testObjcCallback");
    //    }];
}

@end
