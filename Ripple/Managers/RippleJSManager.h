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

@class WebViewJavascriptBridge, RPBlobData,RPAccountData;

@interface RippleJSManager : NSObject {
    UIWebView * _webView;
    WebViewJavascriptBridge *_bridge;
    
    UITextView * _log;
    
    
    BOOL isConnected;
    BOOL isLoggedIn;
    
    
    BOOL receivedLines;
    BOOL receivedAccount;
    
    
    RPBlobData * blobData;
    RPAccountData * accountData;
    NSMutableArray * accountLines;
    
    NSMutableArray * _contacts;
}

+(RippleJSManager*)shared;

-(void)setLog:(UITextView*)textView;


-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block;
-(void)logout;

-(void)connect;

-(void)rippleFindPath:(NSDictionary*)params;
-(void)rippleSendTransactionAmount:(NSNumber*)amount currency:(NSString*)currency toRecipient:(NSString*)recipient withBlock:(void(^)(NSError* error))block;

-(BOOL)isLoggedIn;
-(BOOL)isConnected;

-(NSString*)rippleWalletAddress;
-(NSArray*)rippleContacts;
-(NSDictionary*)rippleBalances;

@end
