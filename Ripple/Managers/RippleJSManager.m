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

#import "RippleJSManager+Initializer.h"
#import "RippleJSManager+AccountInfo.h"
#import "RippleJSManager+AccountLines.h"
#import "RippleJSManager+TransactionCallback.h"
#import "RippleJSManager+FindPath.h"


@interface RippleJSManager ()

@end

@implementation RippleJSManager

#define USERDEFAULTS_RIPPLE_KEY @"RippleKey"

-(NSString*)rippleWalletAddress
{
    NSString *address = blobData.account_id;
    if (!address) {
        address = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_RIPPLE_KEY];
    }

    return address;
}

-(NSArray*)rippleContacts
{
    return _contacts;
}


-(void)log:(id)data
{
    _log.text = [NSString stringWithFormat:@"%@\n%@",data,_log.text];
}

-(void)notifyNetworkStatus
{
    
    
    if (isConnected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRippleConnected object:nil userInfo:nil];
//        if (self.delegate_network_status && [self.delegate_network_status respondsToSelector:@selector(RippleJSManagerConnected)]) {
//            [self.delegate_network_status RippleJSManagerConnected];
//        }
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRippleDisconnected object:nil userInfo:nil];
//        if (self.delegate_network_status && [self.delegate_network_status respondsToSelector:@selector(RippleJSManagerDisconnected)]) {
//            [self.delegate_network_status RippleJSManagerDisconnected];
//        }
    }
}

-(void)registerBridgeHandlers
{
    // Connected to Ripple network
    [_bridge registerHandler:@"connected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"connected called: %@", data);
        isConnected = YES;
        //[self log:@"Connected"];
        
        [self notifyNetworkStatus];
        [self afterConnectedSubscribe];
        [self gatherAccountInfo];
    }];
    
    // Disconnected from Ripple network
    [_bridge registerHandler:@"disconnected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"disconnected called: %@", data);
        isConnected = NO;
        [self log:@"Disconnected"];
        
        // Try to connect again
        //[self connect];
        
        [self notifyNetworkStatus];
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
    
    
    [self wrapperRegisterHandlerTransactionCallback];
    
    
    
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
                    _contacts = [NSMutableArray arrayWithCapacity:contacts.count];
                    for (NSDictionary * contactDic in contacts) {
                        RPContact * contact = [RPContact new];
                        [contact setDictionary:contactDic];
                        [_contacts  addObject:contact];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedContacts object:nil userInfo:nil];
                    
                    // Save ripple address
                    [[NSUserDefaults standardUserDefaults] setObject:blobData.account_id forKey:USERDEFAULTS_RIPPLE_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    [self wrapperSetAccount:blobData.account_id];
                    
                    isLoggedIn = YES;
                    
                    block(nil);
                    
                    [self gatherAccountInfo];
                    
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

-(void)wrapperSetAccount:(NSString*)account
{
    // Set account in wrapper
    NSDictionary * data = @{@"account": account};
    [_bridge callHandler:@"set_account" data:data responseCallback:^(id responseData) {
        NSLog(@"set_account response: %@", responseData);
        
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
            
            NSString *account_id = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_RIPPLE_KEY];
            if (account_id) {
                [self wrapperSetAccount:account_id];
            }
            
            
            [self login:username andPassword:password withBlock:^(NSError *error) {
                
            }];
            
            
        }
    }
}

-(BOOL)isConnected
{
    return isConnected;
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
    
    receivedLines = NO;
    receivedAccount = NO;
    
    NSArray * accounts = [SSKeychain allAccounts];
    for (NSDictionary * dic in accounts) {
        NSString * username = [dic objectForKey:@"acct"];
        NSError * error;
        [SSKeychain deletePasswordForService:SSKEYCHAIN_SERVICE account:username error:&error];
        
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_RIPPLE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)afterConnectedSubscribe
{
    //NSDictionary * params = @{@"account": blobData.account_id};
    
    
    //[self subscribe:params];
    //[self subscribeLedger:params];
}

-(void)gatherAccountInfo
{
    if (isLoggedIn) {
        if (!receivedLines) {
            [self wrapperAccountLines]; // IOU balances
        }
        if (!receivedAccount) {
            [self wrapperAccountInfo];  // Get Ripple balance
        }

        
        //[self accountTx:params];    // Last transactions
    }
}



#define XRP_FACTOR 1000000

-(NSDictionary*)rippleBalances
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
    return balances;
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




-(void)rippleSendTransactionAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSError* error))block
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
                              @"currency": currency,
                              @"amount": amount.stringValue,
                              @"secret": blobData.master_seed
                              };
    
    [_bridge callHandler:@"send_transaction" data:params responseCallback:^(id responseData) {
        NSLog(@"send_transaction response: %@", responseData);
        NSError * error;
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
        
        block(error);
    }];
}


-(void)setLog:(UITextView*)textView
{
    _log = textView;
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
        
        receivedAccount = NO;
        receivedLines = NO;
        
        [self wrapperInitialize];
        [self registerBridgeHandlers];
        
        [self connect];
        
        
        // Check if loggedin
        [self checkForLogin];
        
        
//#warning Testing purposes
//        NSDictionary * params = [[NSUserDefaults standardUserDefaults] objectForKey:@"transaction"];
//        [_bridge callHandler:@"test_transaction" data:params responseCallback:^(id responseData) {
//            NSLog(@"test_transaction response: %@", responseData);
//            
//        }];
    }
    return self;
}




@end
