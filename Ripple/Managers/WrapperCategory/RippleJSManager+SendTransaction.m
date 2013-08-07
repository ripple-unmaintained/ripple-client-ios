//
//  RippleJSManager+SendTransaction.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+SendTransaction.h"

@implementation RippleJSManager (SendTransaction)

-(NSError *)checkForErrorResponse:(NSDictionary*)responseData
{
    NSError * error;
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        // Check for ripple-lib error
        NSNumber * returnCode = [responseData objectForKey:@"engine_result_code"];
        if (returnCode.integerValue != 0) {
            // Could not send transaction
            NSString * errorMessage = [responseData objectForKey:@"engine_result_message"];
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        
        
        // Check for wrapper error
        NSString * errorMessage = [responseData objectForKey:@"error"];
        if (errorMessage) {
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
    }
    return error;
}

-(void)wrapperSendTransactionAmount:(NSNumber*)amount fromCurrency:(NSString*)currency toRecipient:(NSString*)recipient toCurrency:(NSString*)to_currency withBlock:(void(^)(NSError* error))block
{
    /*
    {
        "engine_result" = "tecUNFUNDED_PAYMENT";
        "engine_result_code" = 104;
        "engine_result_message" = "Insufficient XRP balance to send.";
        "tx_blob" = 1200002200000000240000000861400000E8D4A5100068400000000000000A73210376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD574473045022100D95DA3C853A9C0E048290E142887163B24263ED4A2538F24DC44852E45273D1F0220551C62788BA3A5E35356B8377821916989C3A34AC4E120069EC2F7DC0655B6338114B4037480188FA0DD8DC61DC57791C94A940CF1F083142B56FFC66587C6ECF125506A599C0BD9D376430D;
        "tx_json" =     {
            Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Amount = 1000000000000;
            Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Fee = 10;
            Flags = 0;
            Sequence = 8;
            SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
            TransactionType = Payment;
            TxnSignature = 3045022100D95DA3C853A9C0E048290E142887163B24263ED4A2538F24DC44852E45273D1F0220551C62788BA3A5E35356B8377821916989C3A34AC4E120069EC2F7DC0655B633;
            hash = 42C46F9F0F95E70ABB3AE0B47A7B83F02C07B5F58385F7FE17400A3CE655E780;
        };
    }
    
    
    {
        "engine_result" = tesSUCCESS;
        "engine_result_code" = 0;
        "engine_result_message" = "The transaction was applied.";
        "tx_blob" = 120000220000000024000000096140000000000F424068400000000000000A73210376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5744730450221009AA1970167D0E241DFE58EBC34214F70FCE3E76B98C42FA0575C635AB823D1B6022004C7D8195895F5EBE3BB71D39AE9E26517376FC1F7413E0B2BD3CD794A71B2AB8114B4037480188FA0DD8DC61DC57791C94A940CF1F083142B56FFC66587C6ECF125506A599C0BD9D376430D;
        "tx_json" =     {
            Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Amount = 1000000;
            Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Fee = 10;
            Flags = 0;
            Sequence = 9;
            SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
            TransactionType = Payment;
            TxnSignature = 30450221009AA1970167D0E241DFE58EBC34214F70FCE3E76B98C42FA0575C635AB823D1B6022004C7D8195895F5EBE3BB71D39AE9E26517376FC1F7413E0B2BD3CD794A71B2AB;
            hash = 0A86E4DD55686ECBB000B2699D9A8D8C0FF0FD1C6DCB7246C18FD03538D79E72;
        };
    }
    
     */
    
    if (!amount || !recipient || !_blobData) {
        NSError * error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid amount"}];
        block(error);
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:
                               @{@"account": _blobData.account_id,
                              @"recipient_address": recipient,
                              @"currency": currency,
                              @"amount": amount.stringValue,
                              @"secret": _blobData.master_seed
                               }];
    
    if (to_currency) {
        // Add destination currency
        [params setObject:to_currency forKey:@"path"];
    }
    
    [_bridge callHandler:@"send_transaction" data:params responseCallback:^(id responseData) {
        NSLog(@"send_transaction response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        block(error);
    }];
}


-(void)wrapperFindPathWithAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSArray * paths, NSError* error))block
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
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"recipient_address": recipient,
                              @"currency": currency,
                              @"amount": amount.stringValue,
                              @"secret": _blobData.master_seed
                              };
    
    [_bridge callHandler:@"find_path_currencies" data:params responseCallback:^(id responseData) {
        NSLog(@"find_path_currencies response: %@", responseData);
        NSError * error = [self checkForErrorResponse:responseData];
        NSMutableArray * paths;
        if (!error) {
            paths = [NSMutableArray array];
            for (NSDictionary * path in responseData) {
                RPAvailablePath * obj = [RPAvailablePath new];
                [obj setDictionary:path];
                [paths addObject:obj];
            }
            
            if ([currency isEqualToString:GLOBAL_XRP_STRING]) {
                RPAvailablePath * obj = [RPAvailablePath new];
                obj.currency = GLOBAL_XRP_STRING;
                obj.value = amount;
                [paths addObject:obj];
            }
        }
        block(paths, error);
    }];
}

-(void)wrapperIsValidAccount:(NSString*)account withBlock:(void(^)(NSError* error))block
{
    [_bridge callHandler:@"is_valid_account" data:@{@"account": account} responseCallback:^(id responseData) {
        NSLog(@"is_valid_account response: %@", responseData);
        NSError * error;
        NSString * errorMessage = [responseData objectForKey:@"error"];
        if (errorMessage) {
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        block(error);
    }];
}

@end
