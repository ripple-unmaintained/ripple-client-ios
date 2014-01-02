//
//  WebViewBridgeManager.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebViewJavascriptBridge.h"
#import "NSObject+KJSerializer.h"
#import "RPError.h"
#import "RPAccountData.h"
#import "RPBlobData.h"
#import "RPAccountLine.h"
#import "RPContact.h"
#import "RPAccountData.h"
#import "RPLedgerClosed.h"
#import "RPError.h"
#import "RPAccountLine.h"
#import "RPBlobData.h"
#import "RPContact.h"
#import "RPTransaction.h"
#import "RPTransactionSubscription.h"
#import "RPTxHistory.h"
#import "RPAmount.h"

#import "AccountBalanceManager.h"
#import "AccountHistoryManager.h"

#import "../../../Pods/AFNetworking/AFNetworking/AFNetworking.h"

#define MAX_TRANSACTIONS 12


// Notifications
#define kNotificationRippleConnected     @"RippleNetworkConnected"
#define kNotificationRippleDisconnected  @"RippleNetworkDisconnected"
#define kNotificationUpdatedContacts     @"RippleUpdatedContacts"
#define kNotificationUpdatedBalance      @"RippleUpdatedBalance"
#define kNotificationUpdatedAccountTx    @"RippleUpdatedAccountTx"
#define kNotificationUserLoggedIn        @"RippleUserLoggedIn"
#define kNotificationUserLoggedOut       @"RippleUserLoggedOut"


#define kNotificationAccountChanged      @"RippleAccountChanged"
#define kNotificationRefreshTx           @"RippleRefreshTx"


@class WebViewJavascriptBridge, RPBlobData,RPAccountData;

@interface RippleJSManager : NSObject {
    UIWebView               * _webView;
    WebViewJavascriptBridge * _bridge;
    
    BOOL _isConnected;
    BOOL _isLoggedIn;
    BOOL _isAttemptingLogin;
    
    RPBlobData       * _blobData;
    NSMutableArray   * _contacts;
    
    AccountBalanceManager * _accountBalance;
    AccountHistoryManager * _accountHistory;
    
    AFHTTPRequestOperationManager * _operationManager;
    NSTimer * _networkTimeout;
}

+(RippleJSManager*)shared;

-(BOOL)isConnected;
-(NSString*)rippleWalletAddress;
-(NSArray*)rippleContacts;
-(NSDictionary*)rippleBalances;
-(NSArray*)rippleTxHistory;

@end
