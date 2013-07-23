//
//  WebViewBridgeManager.m
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager.h"
#import "WebViewJavascriptBridge.h"
#import "NSObject+KJSerializer.h"
#import "RPAccountData.h"
#import "RPLedgerClosed.h"
#import "RPError.h"
#import "RPAccountLine.h"
#import "RPVaultClient.h"
#import "NSString+Hashes.h"
#import "Base64.h"
#import "AESCrypt.h"
#import "SSKeychain.h"
#import "RPBlobData.h"
#import "RPContact.h"
#import "RPTransaction.h"
#import "RPTransactionSubscription.h"

#define HTML_BEGIN @"<!DOCTYPE html>\
<html lang=\"en\">\
<head>\
<meta charset=\"utf-8\">\
<title>Ripple Lib Demo</title>"

#define HTML_END @"</head>\
<body>\
<h1>Ripple Lib Demo</h1>\
</body>\
</html>"

@interface RippleJSManager () <UIWebViewDelegate> {
    UIWebView * _webView;
    WebViewJavascriptBridge *_bridge;
    
    UITextView * _log;
    
    
    BOOL isConnected;
    BOOL isLoggedIn;
    
    RPBlobData * blobData;
    RPAccountData * accountData;
    NSMutableArray * accountLines;
    
    NSMutableArray * _contacts;
}

@end

@implementation RippleJSManager

-(NSString*)rippleWalletAddress
{
    return blobData.account_id;
}

-(NSString*)rippleHTML
{
    NSMutableString * html = [NSMutableString stringWithString:HTML_BEGIN];
    
    NSString *path;
    NSString *contents;
    
    path = [[NSBundle mainBundle] pathForResource:@"ripple" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
    path = nil;
    contents = nil;
    
    path = [[NSBundle mainBundle] pathForResource:@"sjcl" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
    path = nil;
    contents = nil;
    
    path = [[NSBundle mainBundle] pathForResource:@"ripple-lib-wrapper" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
    path = nil;
    contents = nil;
    
    [html appendString:HTML_END];
    
    //NSLog(@"%@: Ripple HTML:\n%@", self.class.description, html);
    
    
    return html;
}

-(void)log:(id)data
{
    _log.text = [NSString stringWithFormat:@"%@\n%@",data,_log.text];
}

-(void)updateNetworkStatus
{
    if (isConnected) {
        if (self.delegate_network_status && [self.delegate_network_status respondsToSelector:@selector(RippleJSManagerConnected)]) {
            [self.delegate_network_status RippleJSManagerConnected];
        }
    }
    else {
        if (self.delegate_network_status && [self.delegate_network_status respondsToSelector:@selector(RippleJSManagerDisconnected)]) {
            [self.delegate_network_status RippleJSManagerDisconnected];
        }
    }
}

-(void)setupJavascriptBridge
{
    //[WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
//#warning Testing purposes only
        raise(1);
    }];
    
    // Connected to Ripple network
    [_bridge registerHandler:@"connected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"connected called: %@", data);
        isConnected = YES;
        [self log:@"Connected"];
        
        [self updateNetworkStatus];
        
        [self afterConnectedSubscribe];
    }];
    
    // Disconnected from Ripple network
    [_bridge registerHandler:@"disconnected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"disconnected called: %@", data);
        isConnected = NO;
        [self log:@"Disconnected"];
        
        // Try to connect again
        //[self connect];
        
        [self updateNetworkStatus];
    }];
    
    
    // Testing purposes
    [_bridge registerHandler:@"ledger_closed" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ledger_closed called: %@", data);
        [self log:data];
        
        RPLedgerClosed * obj = [RPLedgerClosed new];
        [obj setDictionary:data];
        // Validate?
        
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    

    [_bridge registerHandler:@"transaction_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"transaction_callback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
        
        // Process transaction
        //RPTransactionSubscription * obj = [RPTransactionSubscription new];
        //[obj setValuesForKeysWithDictionary:data];
        
        [self loggedIn];
        
    }];
    
    
    // Subscribe
//    [_bridge registerHandler:@"subscribe_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"rippleRemoteGenericCallback called: %@", data);
//        //responseCallback(@"Response from testObjcCallback");
//    }];
//    
//    [_bridge registerHandler:@"subscribe_error_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"rippleRemoteGenericErrorCallback called: %@", data);
//        //responseCallback(@"Response from testObjcCallback");
//    }];
    
    
    
    
    
    
    
    [_bridge registerHandler:@"generic_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"generic_callback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
//
//    [_bridge registerHandler:@"rippleRemoteGenericErrorCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"rippleRemoteGenericErrorCallback called: %@", data);
//        //responseCallback(@"Response from testObjcCallback");
//    }];
    
    
    
    //[_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
    //    NSLog(@"objc got response! %@", responseData);
    //}];
    
    //[_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
    
    //[_bridge send:@"A string sent from ObjC after Webview has loaded."];
    
    //[_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
    //    NSLog(@"sendMessage got response: %@", response);
    //}];
}

-(RPError*)checkForError:(NSDictionary*)response
{
    RPError * error;
    if ([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"error"]) {
        error = [RPError new];
        [error setDictionary:response];
    }
    return error;
}

#define SSKEYCHAIN_SERVICE @"ripple"

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block
{
    // Normalize
    username = [username lowercaseString];
    
    [SSKeychain setPassword:password forService:SSKEYCHAIN_SERVICE account:username];
    
    NSString * beforeHash = [NSString stringWithFormat:@"%@%@",username,password];
    NSString * afterHash = [beforeHash sha256];
    
    NSString * path = [NSString stringWithFormat:@"/%@", afterHash];
    
    [[RPVaultClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && ![responseObject isKindOfClass:[NSNull class]]) {
            // Login correct
            NSString * response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString * decodedResponse = [response base64DecodedString];
            NSLog(@"%@: login success", self.class.description);
            
            NSString * key = [NSString stringWithFormat:@"%d|%@%@",username.length, username,password];
            //NSLog(@"%@: key: %@", self.class.description, key);
            
            // Decrypt
            [_bridge callHandler:@"sjcl_decrypt" data:@{@"key": key,@"decrypt": decodedResponse} responseCallback:^(id responseData) {
                if (responseData && ![responseData isKindOfClass:[NSNull class]]) {
                    // Success
                    NSLog(@"New Blob: %@", responseData);
                    RPBlobData * blob = [RPBlobData new];
                    [blob setDictionary:responseData];
                    blobData = blob;
                    
                    // Collect contacts
                    NSArray * contacts = [responseData objectForKey:@"contacts"];
                    contacts = [NSMutableArray arrayWithCapacity:contacts.count];
                    for (NSDictionary * contactDic in contacts) {
                        RPContact * contact = [RPContact new];
                        [contact setDictionary:contactDic];
                        [_contacts  addObject:contact];
                    }
                    
                    block(nil);
                    
                    [self loggedIn];
                    
                    /*
                     Example blob
                    {
                        "account_id" = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                        contacts =     (
                        );
                        "master_seed" = snShK2SuSqw7VjAzGKzT5xc1Qyp4K;
                        "preferred_issuer" =     {
                        };
                        "preferred_second_issuer" =     {
                        };
                    }
                    */
                }
                else {
                    // Failed
                    NSLog(@"decrypt_blob failed response: %@", responseData);
                    NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
                    [self logout];
                    block(error);
                }
            }];
        }
        else {
            // Login blobvault failed
            NSLog(@"%@: login failed. Invalid username or password", self.class.description);
            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
            [self logout];
            block(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: login failed: %@",self.class.description, error.localizedDescription);
        [self logout];
        block(error);
    }];
}

-(void)checkForLogin
{
    NSArray * accounts = [SSKeychain allAccounts];
    if (accounts.count > 0) {
        NSDictionary * account = [accounts objectAtIndex:0];
        NSString * username = [account objectForKey:@"acct"];
        NSString * password = [SSKeychain passwordForService:SSKEYCHAIN_SERVICE account:username];
        if (username && password && username.length > 0 && password.length > 0) {
            [self login:username andPassword:password withBlock:^(NSError *error) {
                
            }];
        }
    }
}

-(BOOL)isLoggedIn
{
    NSArray * accounts = [SSKeychain allAccounts];
    if (accounts.count > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)logout
{
    isLoggedIn = NO;
    blobData = nil;
    accountLines = nil;
    accountData = nil;
    
    NSArray * accounts = [SSKeychain allAccounts];
    for (NSDictionary * dic in accounts) {
        NSString * username = [dic objectForKey:@"acct"];
        [SSKeychain deletePasswordForService:SSKEYCHAIN_SERVICE account:username];
    }
}


-(void)afterConnectedSubscribe
{
    NSDictionary * params = @{@"account": blobData.account_id};
    
    [self subscribe:params];
}

#define MAX_TRANSACTIONS 10

-(void)loggedIn
{
    // Received Blob. Request account information from network
    // TODO: Check for connected?
    
    isLoggedIn = YES;
    NSDictionary * params = @{@"account": blobData.account_id,
                              @"secret": blobData.master_seed,
                              
                              // accountTx
                              @"params": @{@"account": blobData.account_id,
                                          @"ledger_index_min": [NSNumber numberWithInt:-1],
                                          @"descending": @YES,
                                          @"limit": [NSNumber numberWithInt:MAX_TRANSACTIONS],
                                          @"count": @YES}
                              };
    
    [self accountLines:params]; // IOU balances
    [self accountInfo:params];  // Ripple balance
    //[self accountTx:params];    // Last transactions
    //[self subscribeLedger:params];
    
    
}


//-(void)requestWalletAccounts
//{
//    [_bridge callHandler:@"request_wallet_accounts" data:[NSDictionary dictionaryWithObject:@"snShK2SuSqw7VjAzGKzT5xc1Qyp4K" forKey:@"seed"] responseCallback:^(id responseData) {
//        NSLog(@"request_wallet_accounts response: %@", responseData);
//    }];
//}

//-(void)subscribeWalletAddress
//{
//    [_bridge callHandler:@"subscribe_ripple_address" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
//        NSLog(@"subscribe_ripple_address response: %@", responseData);
//    }];
//}


-(void)subscribeLedger:(NSDictionary*)params
{
    [_bridge callHandler:@"subscribe_ledger" data:params responseCallback:^(id responseData) {
        NSLog(@"subscribe_ledger response: %@", responseData);
    }];
}

-(void)subscribe:(NSDictionary*)params
{
    /*
     Future callback example for XRP:
     
    {
        "engine_result" = tesSUCCESS;
        "engine_result_code" = 0;
        "engine_result_message" = "The transaction was applied.";
        "ledger_hash" = 25844FC8BFA0BDD4B9F901FAD803EDCBE57D35AD1373330F9F691D5857F65C8C;
        "ledger_index" = 1408938;
        meta =     {
            AffectedNodes =         (
                                     {
                                         ModifiedNode =                 {
                                             FinalFields =                     {
                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                 Balance = 173315610;
                                                 Flags = 0;
                                                 OwnerCount = 1;
                                                 Sequence = 40;
                                             };
                                             LedgerEntryType = AccountRoot;
                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                             PreviousFields =                     {
                                                 Balance = 123315610;
                                             };
                                             PreviousTxnID = ED43BF5E2305261C12641F75E8EED5A973FBF943CC85E3582C1844AA760F4F9B;
                                             PreviousTxnLgrSeq = 1408362;
                                         };
                                     },
                                     {
                                         ModifiedNode =                 {
                                             FinalFields =                     {
                                                 Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                                 Balance = 151499970;
                                                 Flags = 0;
                                                 OwnerCount = 1;
                                                 Sequence = 4;
                                             };
                                             LedgerEntryType = AccountRoot;
                                             LedgerIndex = C42FD18190EEBAFA83EDCBF6556A1F25045E06DB37D725857D09A8B3B3EEBCA1;
                                             PreviousFields =                     {
                                                 Balance = 201499980;
                                                 Sequence = 3;
                                             };
                                             PreviousTxnID = ED43BF5E2305261C12641F75E8EED5A973FBF943CC85E3582C1844AA760F4F9B;
                                             PreviousTxnLgrSeq = 1408362;
                                         };
                                     }
                                     );
            TransactionIndex = 0;
            TransactionResult = tesSUCCESS;
        };
        mmeta =     {
            nodes =         (
                             {
                                 diffType = ModifiedNode;
                                 entryType = AccountRoot;
                                 fields =                 {
                                     Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                     Balance = 173315610;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 40;
                                 };
                                 fieldsFinal =                 {
                                     Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                     Balance = 173315610;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 40;
                                 };
                                 fieldsNew =                 {
                                 };
                                 fieldsPrev =                 {
                                     Balance = 123315610;
                                 };
                                 ledgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                             },
                             {
                                 diffType = ModifiedNode;
                                 entryType = AccountRoot;
                                 fields =                 {
                                     Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                     Balance = 151499970;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 4;
                                 };
                                 fieldsFinal =                 {
                                     Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                     Balance = 151499970;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 4;
                                 };
                                 fieldsNew =                 {
                                 };
                                 fieldsPrev =                 {
                                     Balance = 201499980;
                                     Sequence = 3;
                                 };
                                 ledgerIndex = C42FD18190EEBAFA83EDCBF6556A1F25045E06DB37D725857D09A8B3B3EEBCA1;
                             }
                             );
        };
        status = closed;
        transaction =     {
            Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Amount = 50000000;
            Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Fee = 10;
            Flags = 0;
            Sequence = 3;
            SigningPubKey = 02AD591A74E2DCDB3AEEE8AF8A7FACD70719FEA9F3DCD275E5CDAD01813A185AEA;
            TransactionType = Payment;
            TxnSignature = 3045022100B3AAB65B0B4FA90F3586F28A072F3596F8C7A6503DDF2FB409DDBA9A33A45BA4022059C5AB7ACF4837F25E390EE99FFFE57B31DF169865037AC69DDBC40D8FBF84E0;
            date = 427868340;
            hash = 489E970A6FD4AC584FB321FDC0ACFB2CAA20717503D1007038DA4093A1E687ED;
        };
        type = transaction;
        validated = 1;
    }
    */
    
    
    /*
     Future callback for USD transaction:
     
     
     {
         "engine_result" = tesSUCCESS;
         "engine_result_code" = 0;
         "engine_result_message" = "The transaction was applied.";
         "ledger_hash" = 130581EA0A6EBF8299D085024410F0C447CCEFC8DA7EF80695CC110708534C31;
         "ledger_index" = 1409785;
         meta =     {
             AffectedNodes =         (
                                      {
                                          ModifiedNode =                 {
                                              FinalFields =                     {
                                                  Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                  Balance = 163315510;
                                                  Flags = 0;
                                                  OwnerCount = 1;
                                                  Sequence = 50;
                                              };
                                              LedgerEntryType = AccountRoot;
                                              LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                              PreviousFields =                     {
                                                  Balance = 163315520;
                                                  Sequence = 49;
                                              };
                                              PreviousTxnID = 3BD8E7295078F38117D726A62839CC77AEDD999F85A7CADEB12108B56A5F6BF8;
                                              PreviousTxnLgrSeq = 1409777;
                                          };
                                      },
                                      {
                                          ModifiedNode =                 {
                                              FinalFields =                     {
                                                  Balance =                         {
                                                      currency = USD;
                                                      issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                      value = "0.3";
                                                  };
                                                  Flags = 65536;
                                                  HighLimit =                         {
                                                      currency = USD;
                                                      issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                      value = 0;
                                                  };
                                                  HighNode = 0000000000000000;
                                                  LowLimit =                         {
                                                      currency = USD;
                                                      issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                                      value = 1;
                                                  };
                                                  LowNode = 0000000000000000;
                                              };
                                              LedgerEntryType = RippleState;
                                              LedgerIndex = 1EB4457CEE28C02EDD3C1A247F18852822CEBC8A8FDCC5589D8CB3F39406C3A8;
                                              PreviousFields =                     {
                                                  Balance =                         {
                                                      currency = USD;
                                                      issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                      value = "0.2";
                                                  };
                                              };
                                              PreviousTxnID = C33EEC55F460809A11B7FBBD7359EA9C11E57DD0A5E201A66B87A884D89A4433;
                                              PreviousTxnLgrSeq = 1406212;
                                          };
                                      }
                                      );
             TransactionIndex = 0;
             TransactionResult = tesSUCCESS;
         };
         mmeta =     {
             nodes =         (
                              {
                                  diffType = ModifiedNode;
                                  entryType = AccountRoot;
                                  fields =                 {
                                      Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                      Balance = 163315510;
                                      Flags = 0;
                                      OwnerCount = 1;
                                      Sequence = 50;
                                  };
                                  fieldsFinal =                 {
                                      Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                      Balance = 163315510;
                                      Flags = 0;
                                      OwnerCount = 1;
                                      Sequence = 50;
                                  };
                                  fieldsNew =                 {
                                  };
                                  fieldsPrev =                 {
                                      Balance = 163315520;
                                      Sequence = 49;
                                  };
                                  ledgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                              },
                              {
                                  diffType = ModifiedNode;
                                  entryType = RippleState;
                                  fields =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.3";
                                      };
                                      Flags = 65536;
                                      HighLimit =                     {
                                          currency = USD;
                                          issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                          value = 0;
                                      };
                                      HighNode = 0000000000000000;
                                      LowLimit =                     {
                                          currency = USD;
                                          issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                          value = 1;
                                      };
                                      LowNode = 0000000000000000;
                                  };
                                  fieldsFinal =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.3";
                                      };
                                      Flags = 65536;
                                      HighLimit =                     {
                                          currency = USD;
                                          issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                          value = 0;
                                      };
                                      HighNode = 0000000000000000;
                                      LowLimit =                     {
                                          currency = USD;
                                          issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                          value = 1;
                                      };
                                      LowNode = 0000000000000000;
                                  };
                                  fieldsNew =                 {
                                  };
                                  fieldsPrev =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.2";
                                      };
                                  };
                                  ledgerIndex = 1EB4457CEE28C02EDD3C1A247F18852822CEBC8A8FDCC5589D8CB3F39406C3A8;
                              }
                              );
         };
         status = closed;
         transaction =     {
             Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
             Amount =         {
                 currency = USD;
                 issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                 value = "0.1";
             };
             Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
             Fee = 10;
             Flags = 0;
             SendMax =         {
                 currency = USD;
                 issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                 value = "0.101";
             };
             Sequence = 49;
             SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
             TransactionType = Payment;
             TxnSignature = 3045022100B53B8812B9C0AA770D6CC308F12042862A52631CF15D00BA96511BEEB798D11D02203F889F523402540EA15E37A8D7303B57DA58C194881E1EE522AFF864A3F86BB0;
             date = 427872630;
             hash = 84C4432B247C1E27F55180236993E86686361729A803C4AD998C5334B5898287;
         };
         type = transaction;
         validated = 1;
     }
    */
     
    
    
    [_bridge callHandler:@"subscribe_transactions" data:params responseCallback:^(id responseData) {
        NSLog(@"subscribe_transactions response: %@", responseData);
    }];
}



#define XRP_FACTOR 1000000

-(void)processBalances
{
    NSMutableDictionary * balances = [NSMutableDictionary dictionary];
    if (accountData) {
        NSNumber * balance = [NSNumber numberWithUnsignedLongLong:(accountData.Balance.unsignedLongLongValue / XRP_FACTOR)];
        [balances setObject:balance forKey:@"XRP"];
    }
    for (RPAccountLine * line in accountLines) {
        NSNumber * balance = [balances objectForKey:line.currency];
        if (balance) {
            balance = [NSNumber numberWithDouble:(balance.doubleValue + line.balance.doubleValue)];
        }
        else {
            balance = line.balance;
        }
        
        [balances setObject:balance forKey:line.currency];
    }
    
    if (self.delegate_balances && [self.delegate_balances respondsToSelector:@selector(RippleJSManagerBalances:)]) {
        [self.delegate_balances RippleJSManagerBalances:balances];
    }
}

-(void)setDelegate_balances:(id<RippleJSManagerBalanceDelegate>)delegate_balances
{
    _delegate_balances = delegate_balances;
    [self processBalances];
}

-(void)setDelegate_network_status:(id<RippleJSManagerNetworkStatus>)delegate_network_status
{
    _delegate_network_status = delegate_network_status;
    [self updateNetworkStatus];
}

-(void)accountInfo:(NSDictionary*)params
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
    
    [_bridge callHandler:@"account_info" data:params responseCallback:^(id responseData) {
        NSLog(@"accountInformation response: %@", responseData);
        
        RPError * error = [self checkForError:responseData];
        if (!error) {
            NSDictionary * accountDataDic = [responseData objectForKey:@"account_data"];
            if (accountDataDic) {
                RPAccountData * obj = [RPAccountData new];
                [obj setDictionary:accountDataDic];
                
                // Check for valid?
                accountData = obj;
                
                
                [self log:[NSString stringWithFormat:@"Balance XRP: %@", accountData.Balance]];
                
                [self processBalances];
            }
            else {
                // Unknown object
                raise(1);
            }
        }
        else {
            // Error
            NSString * error_message = [error.remote objectForKey:@"error_message"];
            [self log:error_message];
        }
    }];
}

-(void)accountLines:(NSDictionary*)params
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
    
    
    [_bridge callHandler:@"account_lines" data:params responseCallback:^(id responseData) {
        NSLog(@"accountLines response: %@", responseData);
        if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
            NSArray * lines = [responseData objectForKey:@"lines"];
            if (lines && [lines isKindOfClass:[NSArray class]]) {
                accountLines = [NSMutableArray arrayWithCapacity:lines.count];
                for (NSDictionary * line in lines) {
                    RPAccountLine * obj = [RPAccountLine new];
                    [obj setDictionary:line];
                    [accountLines addObject:obj];
                    
                    [self log:[NSString stringWithFormat:@"Balance %@: %@", obj.currency, obj.balance]];
                }
                [self processBalances];
            }
        }
        // TODO: Handle errors
    }];
}

// Last transactions
-(void)accountTx:(NSDictionary*)params
{
    /*
    {
        account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
        count = 3;
        "ledger_index_max" = 1364947;
        "ledger_index_min" = 32570;
        limit = 10;
        offset = 0;
        transactions =     (
                            {
                                meta =             {
                                    AffectedNodes =                 (
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.4620233117875503";
                                                                                 };
                                                                                 Flags = 131072;
                                                                                 HighLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                     value = "0.01";
                                                                                 };
                                                                                 HighNode = 0000000000000000;
                                                                                 LowLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowNode = 000000000000009A;
                                                                             };
                                                                             LedgerEntryType = RippleState;
                                                                             LedgerIndex = 0AD2981C87449709BEA806EB6E597FB6ACAE3C01DF13A1A16B130870E19539BD;
                                                                             PreviousFields =                             {
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.6624233117875503";
                                                                                 };
                                                                             };
                                                                             PreviousTxnID = AE419B397AA1EAD0FE0DB8812F8E38A2582BD285336477D2989039B4AF1E35E8;
                                                                             PreviousTxnLgrSeq = 1364352;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Flags = 0;
                                                                                 Owner = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                 RootIndex = 7E1247F78EFC74FA9C0AE39F37AF433966615EB9B757D8397C068C2849A8F4A5;
                                                                             };
                                                                             LedgerEntryType = DirectoryNode;
                                                                             LedgerIndex = 102BCA4A7E3173D4F78F105A05571F5136171218F7BF0EA57DAC3FE3984F9E42;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 Balance = 170215990;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 1;
                                                                                 Sequence = 2;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             PreviousFields =                             {
                                                                                 Balance = 200000000;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 1;
                                                                             };
                                                                             PreviousTxnID = 58571356139F9EA164D1D3C3712C50DB9847CA8A839BB6FA27313C0AD67B3199;
                                                                             PreviousTxnLgrSeq = 1364516;
                                                                         };
                                                                     },
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = DirectoryNode;
                                                                             LedgerIndex = 25314706E5D3EBF756E867A020F476C36740E6B0A47037F682BB62A1E149B030;
                                                                             NewFields =                             {
                                                                                 Owner = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 RootIndex = 25314706E5D3EBF756E867A020F476C36740E6B0A47037F682BB62A1E149B030;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                 Balance = 663783910;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 6;
                                                                                 Sequence = 94;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 30E3D1D8D65EEABEF9878C8DE3BAC4BA474144EDF981CF8AEEC78EAC1CE67BEA;
                                                                             PreviousFields =                             {
                                                                                 Balance = 633999910;
                                                                             };
                                                                             PreviousTxnID = EC7F5A4B524E2C04FE8E655A6A3A48499CD5F5C5F468E6212E2D1B266CFCA99D;
                                                                             PreviousTxnLgrSeq = 1364517;
                                                                         };
                                                                     },
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = RippleState;
                                                                             LedgerIndex = 45BE39B8F9F8B55C9F978C76B99C57B1072EEA95B00DB222B1907BE24EDC3935;
                                                                             NewFields =                             {
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.2";
                                                                                 };
                                                                                 Flags = 131072;
                                                                                 HighLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowNode = 00000000000000B7;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                 Balance = 574391821777;
                                                                                 Domain = 6269747374616D702E6E6574;
                                                                                 EmailHash = 5B33B93C7FFE384D53450FC666BB11FB;
                                                                                 Flags = 131072;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 305;
                                                                                 TransferRate = 1002000000;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = B7D526FDDF9E3B3F95C3DC97C353065B0482302500BBB8051A5C090B596C6133;
                                                                             PreviousTxnID = CCA38325077CD6B836506280B8A6C87B88AF650476E594840E4CAB7EAC4C290D;
                                                                             PreviousTxnLgrSeq = 1364203;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                 BookDirectory = 4627DFFCFF8B5A265EDBD8AE8C14A52325DBFEDAF4F5C32E5D054A6B64FFE000;
                                                                                 BookNode = 0000000000000000;
                                                                                 Flags = 131072;
                                                                                 OwnerNode = 0000000000000000;
                                                                                 Sequence = 93;
                                                                                 TakerGets =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = "15.51";
                                                                                 };
                                                                                 TakerPays = 2309749200;
                                                                             };
                                                                             LedgerEntryType = Offer;
                                                                             LedgerIndex = CB036847C92A861D50E842E0825DDADBF41A1C320A85A8FB537422E7617857F3;
                                                                             PreviousFields =                             {
                                                                                 TakerGets =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = "15.71";
                                                                                 };
                                                                                 TakerPays = 2339533200;
                                                                             };
                                                                             PreviousTxnID = EC7F5A4B524E2C04FE8E655A6A3A48499CD5F5C5F468E6212E2D1B266CFCA99D;
                                                                             PreviousTxnLgrSeq = 1364517;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 1;
                                    SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
                                    TakerGets = 30000000;
                                    TakerPays =                 {
                                        currency = USD;
                                        issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                        value = "0.2";
                                    };
                                    TransactionType = OfferCreate;
                                    TxnSignature = 3045022100F0E2743C791E30850620B0A405D7E62D03784A1ADAADA538FF4C6022AE967A9E022044997FE8C001E3AADA918E7F6D56DDE882C976A1BEBDBAF81D06F05B59BC23D6;
                                    date = 427593490;
                                    hash = C77D333A3F9341F3116C8E191505DC17C204E4384EDAEEB1D6998440A991EDAD;
                                    inLedger = 1364528;
                                    "ledger_index" = 1364528;
                                };
                                validated = 1;
                            },
                            {
                                meta =             {
                                    AffectedNodes =                 (
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 Balance = 200000000;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 1;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             PreviousFields =                             {
                                                                                 Balance = 100000000;
                                                                             };
                                                                             PreviousTxnID = 1867B623EE6F5BA89E002C3F38C81851C624CB0C0E3328C362054357A78145B4;
                                                                             PreviousTxnLgrSeq = 1345588;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                                                                 Balance = 379643512152;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 5;
                                                                                 Sequence = 29;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 444C5754601F7E943146CCF53492E3A97BE590FD347C17339FA52C5BF340C7C3;
                                                                             PreviousFields =                             {
                                                                                 Balance = 379743512162;
                                                                                 Sequence = 28;
                                                                             };
                                                                             PreviousTxnID = E68B5DC8650FFCC8DB67F6D2518B643EB1EE3589A1D83C5BDFC902647F71738B;
                                                                             PreviousTxnLgrSeq = 1364513;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                    Amount = 100000000;
                                    Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 28;
                                    SigningPubKey = 03420F50BABFCA24154986C459148E2FCBED8AB64F6C072AB3A209109669F50D6F;
                                    TransactionType = Payment;
                                    TxnSignature = 3046022100A3876F23B617E769CF43C9D537AA84075818AB1ACE2BFF4F34E11ABC049A72EB022100F29A6EEF831912DA01A4E63AEA2A37B7FE64285F36FE9CBFFDB3E229CE1EB0B8;
                                    date = 427593410;
                                    hash = 58571356139F9EA164D1D3C3712C50DB9847CA8A839BB6FA27313C0AD67B3199;
                                    inLedger = 1364516;
                                    "ledger_index" = 1364516;
                                };
                                validated = 1;
                            },
                            {
                                meta =             {
                                    AffectedNodes =                 (
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             NewFields =                             {
                                                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 Balance = 100000000;
                                                                                 Sequence = 1;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                                                                 Balance = 479953512222;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 5;
                                                                                 Sequence = 22;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 444C5754601F7E943146CCF53492E3A97BE590FD347C17339FA52C5BF340C7C3;
                                                                             PreviousFields =                             {
                                                                                 Balance = 480053512232;
                                                                                 Sequence = 21;
                                                                             };
                                                                             PreviousTxnID = 3A186BA897FD4854CCBB4DA06621F2F2FEC0192021E81799F391B13B16F930D4;
                                                                             PreviousTxnLgrSeq = 1344695;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                    Amount = 100000000;
                                    Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 21;
                                    SigningPubKey = 03420F50BABFCA24154986C459148E2FCBED8AB64F6C072AB3A209109669F50D6F;
                                    TransactionType = Payment;
                                    TxnSignature = 3044022060A23D59A1C2F60597995FFD76E08BCBC30E1359ADA52620442BD915CF180AC7022071E6FFAB15B42208B8D3ABAE1A44B7FC25549A6506A87DB70FB18ECA723FCE05;
                                    date = 427441910;
                                    hash = 1867B623EE6F5BA89E002C3F38C81851C624CB0C0E3328C362054357A78145B4;
                                    inLedger = 1345588;
                                    "ledger_index" = 1345588;
                                };
                                validated = 1;
                            }
                            );
        validated = 1;
    }
    */
    
    
    
    [_bridge callHandler:@"account_tx" data:params responseCallback:^(id responseData) {
        NSLog(@"account_tx response: %@", responseData);
    }];
}

// NOT YET NEEDED
//-(void)accountOffers:(NSDictionary*)params
//{
//    [_bridge callHandler:@"account_offers" data:params responseCallback:^(id responseData) {
//        NSLog(@"account_offers response: %@", responseData);
//    }];
//}


-(void)connect
{
    [_bridge callHandler:@"connect" data:@"" responseCallback:^(id responseData) {
    }];
}

-(void)disconnect
{
    // Disconnect from Ripple server
    [_bridge callHandler:@"disconnect" data:@"" responseCallback:^(id responseData) {
    }];
}



-(void)rippleFindPath:(NSDictionary*)params
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


-(void)rippleSendTransactionAmount:(NSNumber*)amount toRecipient:(NSString*)recipient withBlock:(void(^)(NSError* error))block
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
    */
    
    /*
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
    
    if (!amount || !recipient || !blobData) {
        NSError * error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid amount"}];
        block(error);
        return;
    }
    
    NSDictionary * params = @{@"account": blobData.account_id,
                              @"recipient_address": recipient,
                              @"currency": @"XRP",
                              @"amount": amount.stringValue,
                              @"secret": blobData.master_seed
                              };
    
    [_bridge callHandler:@"send_transaction" data:params responseCallback:^(id responseData) {
        NSLog(@"send_transaction response: %@", responseData);
        NSError * error;
        NSNumber * returnCode = [responseData objectForKey:@"engine_result_code"];
        if (returnCode.integerValue != 0) {
            // Could not send transaction
            NSString * errorMessage = [responseData objectForKey:@"engine_result_message"];
            error = [NSError errorWithDomain:@"send_transaction" code:1 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        block(error);
    }];
}


-(void)setLog:(UITextView*)textView
{
    _log = textView;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@: webView: shouldStartLoadWithRequest", self.class.description);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"%@: webViewDidStartLoad", self.class.description);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"%@: webViewDidStartLoad", self.class.description);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@: webView: didFailLoadWithError", self.class.description);
}


+(RippleJSManager*)shared
{
    static RippleJSManager * shared;
    if (!shared) {
        shared = [RippleJSManager new];
    }
    return shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        isConnected = NO;
        isLoggedIn = NO;
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        NSString * html = [self rippleHTML];
        [_webView loadHTMLString:html baseURL:[NSBundle mainBundle].bundleURL];
        [self setupJavascriptBridge];
        
        [self connect];
        
        
        // Check if loggedin
        [self checkForLogin];
    }
    return self;
}




@end
