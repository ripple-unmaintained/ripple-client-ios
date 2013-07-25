//
//  RippleJSManager+FindPath.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+FindPath.h"

@implementation RippleJSManager (FindPath)

-(void)wrapperFindPath:(NSDictionary*)params
{
    /*
    {
        alternatives =     (
                            {
                                "paths_canonical" =             (
                                );
                                "paths_computed" =             (
                                                                (
                                                                 {
                                                                     account = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                     currency = USD;
                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                     type = 49;
                                                                     "type_hex" = 0000000000000031;
                                                                 },
                                                                 {
                                                                     currency = XRP;
                                                                     type = 16;
                                                                     "type_hex" = 0000000000000010;
                                                                 }
                                                                 )
                                                                );
                                "source_amount" =             {
                                    currency = USD;
                                    issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    value = "0.03408163265306123";
                                };
                            }
                            );
        "destination_account" = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
        "destination_currencies" =     (
                                        XRP
                                        );
        "ledger_current_index" = 1365182;
    }
     */
    
    [_bridge callHandler:@"request_ripple_find_path" data:params responseCallback:^(id responseData) {
        NSLog(@"request_ripple_find_path response: %@", responseData);
    }];
}

@end
