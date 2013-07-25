//
//  RippleJSManager+AccountInfo.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+AccountInfo.h"

@implementation RippleJSManager (AccountInfo)


-(RPError*)checkForError:(NSDictionary*)response
{
    RPError * error;
    if ([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"error"]) {
        error = [RPError new];
        [error setDictionary:response];
    }
    return error;
}

-(void)wrapperAccountInfo
{
    /*
     {
     "account_data" =     {
     Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
     Balance = 170215990;
     Flags = 0;
     LedgerEntryType = AccountRoot;
     OwnerCount = 1;
     PreviousTxnID = C77D333A3F9341F3116C8E191505DC17C204E4384EDAEEB1D6998440A991EDAD;
     PreviousTxnLgrSeq = 1364528;
     Sequence = 2;
     index = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
     };
     "ledger_current_index" = 1364948;
     }
     */
    
    NSDictionary * params = @{@"account": blobData.account_id,
                              @"secret": blobData.master_seed
                              };
    
    [_bridge callHandler:@"account_info" data:params responseCallback:^(id responseData) {
        NSLog(@"account_info response: %@", responseData);
        
        RPError * error = [self checkForError:responseData];
        if (!error) {
            NSDictionary * accountDataDic = [responseData objectForKey:@"account_data"];
            if (accountDataDic) {
                RPAccountData * obj = [RPAccountData new];
                [obj setDictionary:accountDataDic];
                
                // Check for valid?
                accountData = obj;
                
                //[self log:[NSString stringWithFormat:@"Balance XRP: %@", accountData.Balance]];
                
                receivedAccount = YES;
                
                //[self processBalances];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
            }
            else {
                // Unknown object
                raise(1);
            }
        }
        else {
            // Error
            //NSString * error_message = [error.remote objectForKey:@"error_message"];
            //[self log:error_message];
            raise(1);
        }
    }];
}

@end
