//
//  WebViewBridgeManager.m
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager.h"

#import "RippleJSManager+Initializer.h"
#import "RippleJSManager+AccountInfo.h"
#import "RippleJSManager+AccountLines.h"
#import "RippleJSManager+TransactionCallback.h"
#import "RippleJSManager+NetworkStatus.h"
#import "RippleJSManager+Authentication.h"
#import "RippleJSManager+SendTransaction.h"
#import "RippleJSManager+AccountOffers.h"


@interface RippleJSManager ()

@end

@implementation RippleJSManager

-(NSString*)rippleWalletAddress
{
    return [self account_id];
}

-(NSArray*)rippleContacts
{
    return _contacts;
}

-(BOOL)isConnected
{
    return _isConnected;
}

-(void)registerBridgeHandlers
{
    [self wrapperRegisterBridgeHandlersNetworkStatus];
    [self wrapperRegisterHandlerTransactionCallback];
    
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


-(void)gatherAccountInfo
{
    if (_isLoggedIn && !_receivedLines) {
        [self wrapperAccountLines]; // IOU balances
    }
    if (_isLoggedIn && !_receivedAccount) {
        [self wrapperAccountInfo];  // Get Ripple balance
    }
    
    //[self accountTx:params];    // Last transactions
}



#define XRP_FACTOR 1000000

-(NSDictionary*)rippleBalances
{
    NSMutableDictionary * balances = [NSMutableDictionary dictionary];
    if (_accountData) {
        NSNumber * balance = [NSNumber numberWithUnsignedLongLong:(_accountData.Balance.unsignedLongLongValue / XRP_FACTOR)];
        [balances setObject:balance forKey:@"XRP"];
    }
    for (RPAccountLine * line in _accountLines) {
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

-(void)rippleNetworkConnected
{
    [self wrapperSubscribeTransactions];
    [self gatherAccountInfo];
}

-(void)rippleNetworkDisconnected
{
    
}

-(void)userLoggedIn
{
    [self gatherAccountInfo];
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
        _isConnected = NO;
        _isLoggedIn = NO;
        
        _receivedAccount = NO;
        _receivedLines = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rippleNetworkConnected) name:kNotificationRippleConnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rippleNetworkDisconnected) name:kNotificationRippleDisconnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:kNotificationUserLoggedIn object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gatherAccountInfo) name:kNotificationAccountChanged object:nil];
        
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
