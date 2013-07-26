//
//  RippleJSManager+AccountLines.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+AccountLines.h"

@implementation RippleJSManager (AccountLines)

-(void)wrapperAccountLines
{
    /*
    {
        account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
        lines =     (
                     {
                         account = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                         balance = "0.2";
                         currency = USD;
                         limit = 0;
                         "limit_peer" = 0;
                         "quality_in" = 0;
                         "quality_out" = 0;
                     }
                     );
    }
    */
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"secret": _blobData.master_seed};
    
    [_bridge callHandler:@"account_lines" data:params responseCallback:^(id responseData) {
        NSLog(@"accountLines response: %@", responseData);
        
        [_accountBalance processAccountLines:responseData];
    }];
}

@end
