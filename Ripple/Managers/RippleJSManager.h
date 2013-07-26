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

#import "UserAccountInformation.h"


// Notifications
#define kNotificationRippleConnected     @"RippleNetworkConnected"
#define kNotificationRippleDisconnected  @"RippleNetworkDisconnected"
#define kNotificationUpdatedContacts     @"RippleUpdatedContacts"
#define kNotificationUpdatedBalance      @"RippleUpdatedBalance"
#define kNotificationUserLoggedIn        @"RippleUserLoggedIn"

#warning This should eventually removed
#define kNotificationAccountChanged      @"RippleAccountChanged"


@class WebViewJavascriptBridge, RPBlobData,RPAccountData;

@interface RippleJSManager : NSObject {
    UIWebView               * _webView;
    WebViewJavascriptBridge *_bridge;
    
    BOOL _isConnected;
    BOOL _isLoggedIn;
    
    RPBlobData       * _blobData;
    NSMutableArray   * _contacts;
    
    UserAccountInformation * _userAccountInformation;
}

+(RippleJSManager*)shared;

-(BOOL)isConnected;
-(NSString*)rippleWalletAddress;
-(NSArray*)rippleContacts;
-(NSDictionary*)rippleBalances;

@end
