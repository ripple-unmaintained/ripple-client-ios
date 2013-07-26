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
#import "RippleJSManager+AccountTx.h"


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

-(NSArray*)rippleTxHistory
{
    return [_accountHistory rippleTxHistory];
}

-(BOOL)isConnected
{
    return _isConnected;
}

-(void)updateAccountInformation
{
    if (_isLoggedIn) {
        [self wrapperSubscribeTransactions];  // Subscribe to users transactions
        [self wrapperAccountLines];           // Get IOU balances
        [self wrapperAccountInfo];            // Get Ripple balance
        [self wrapperAccountTx];              // Get Last transactions
    }
}

-(NSDictionary*)rippleBalances
{
    return [_accountBalance rippleBalances];
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
    [self updateAccountInformation];
}

-(void)rippleNetworkDisconnected
{
    
}

-(void)userLoggedIn
{
    _accountBalance = [[AccountBalanceManager alloc] initWithAccount:[self rippleWalletAddress]];
    _accountHistory = [[AccountHistoryManager alloc] initWithAccount:[self rippleWalletAddress]];
    [self updateAccountInformation];
}


-(void)userLoggedOut
{
    _accountBalance = nil;
    _accountHistory = nil;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rippleNetworkConnected) name:kNotificationRippleConnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rippleNetworkDisconnected) name:kNotificationRippleDisconnected object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:kNotificationUserLoggedIn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut) name:kNotificationUserLoggedOut object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAccountInformation) name:kNotificationAccountChanged object:nil];
        
        [self wrapperInitialize];
        [self wrapperRegisterBridgeHandlersNetworkStatus];
        [self wrapperRegisterHandlerTransactionCallback];
        
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
