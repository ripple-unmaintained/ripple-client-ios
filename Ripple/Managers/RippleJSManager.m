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
#import "RPVaultClient.h"
#import "NSString+Hashes.h"
#import "Base64.h"
#import "AESCrypt.h"

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
    
    RPAccountData * accountData;
    BOOL isConnected;
}

@end

@implementation RippleJSManager

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

-(void)setupJavascriptBridge
{
    [WebViewJavascriptBridge enableLogging];
    
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
    }];
    
    // Disconnected from Ripple network
    [_bridge registerHandler:@"disconnected" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"disconnected called: %@", data);
        isConnected = NO;
        [self log:@"Disconnected"];
        
        // Try to connect again
        //[self connect];
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
    
    
    
    
    
    // Subscribe
    [_bridge registerHandler:@"subscribe_ledger" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge registerHandler:@"subscribe_ledger_error" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericErrorCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge registerHandler:@"subscribe_server" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge registerHandler:@"subscribe_server_error" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericErrorCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    
    
    
    
    
    
    [_bridge registerHandler:@"rippleRemoteGenericCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge registerHandler:@"rippleRemoteGenericErrorCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericErrorCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    
    
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

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block
{
    // Normalize
    username = [username lowercaseString];
    
    NSString * beforeHash = [NSString stringWithFormat:@"%@%@",username,password];
    NSString * afterHash = [beforeHash sha256];
    
    NSString * path = [NSString stringWithFormat:@"/%@", afterHash];
    
    [[RPVaultClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && ![responseObject isKindOfClass:[NSNull class]]) {
            // Login correct
            NSString * response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString * decodedResponse = [response base64DecodedString];
            NSLog(@"%@: login success: %@", self.class.description, decodedResponse);
            
            NSString * key = [NSString stringWithFormat:@"%d|%@%@",username.length, username,password];
            //NSLog(@"%@: key: %@", self.class.description, key);
            
            // Decrypt
            [_bridge callHandler:@"sjcl_decrypt" data:@{@"key": key,@"decrypt": decodedResponse} responseCallback:^(id responseData) {
                NSLog(@"decrypt_blob response: %@", responseData);
                if (responseData && ![responseData isKindOfClass:[NSNull class]]) {
                    // Success
                    block(nil);
                }
                else {
                    // Failed
                    NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
                    block(error);
                }
            }];
        }
        else {
            // Login blobvault failed
            NSLog(@"%@: login failed. Invalid username or password", self.class.description);
            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
            block(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: login failed: %@",self.class.description, error.localizedDescription);
        block(error);
    }];
    
    //[self requestWalletAccounts];
    //[self subscribeWalletAddress];
    //[self accountInfo];
    //[self accountLines];
    //[self accountOffers];
    //[self accountTx];
}


-(void)decryptBlob:(NSString*)blobg withUsername:(NSString*)username andPassword:(NSString*)password
{
    
}

-(void)requestWalletAccounts
{
    [_bridge callHandler:@"request_wallet_accounts" data:[NSDictionary dictionaryWithObject:@"snShK2SuSqw7VjAzGKzT5xc1Qyp4K" forKey:@"seed"] responseCallback:^(id responseData) {
        NSLog(@"request_wallet_accounts response: %@", responseData);
    }];
}

-(void)subscribeWalletAddress
{
    [_bridge callHandler:@"subscribe_ripple_address" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"subscribe_ripple_address response: %@", responseData);
    }];
}


-(void)accountInfo
{
    [_bridge callHandler:@"account_info" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"accountInformation response: %@", responseData);
        
        RPError * error = [self checkForError:responseData];
        if (!error) {
            NSDictionary * accountDataDic = [responseData objectForKey:@"account_data"];
            if (accountDataDic) {
                RPAccountData * obj = [RPAccountData new];
                [obj setDictionary:accountDataDic];
                
                // Check for valid?
                accountData = obj;
                
                
                [self log:[NSString stringWithFormat:@"Balance: %@", accountData.Balance]];
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

-(void)accountLines
{
    [_bridge callHandler:@"account_lines" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"accountLines response: %@", responseData);
    }];
}


-(void)accountTx
{
    [_bridge callHandler:@"account_tx" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"accountTx response: %@", responseData);
    }];
}

-(void)accountOffers
{
    [_bridge callHandler:@"account_offers" data:[NSDictionary dictionaryWithObject:@"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"accountOffers response: %@", responseData);
    }];
}


-(void)connect
{
    [_bridge callHandler:@"connect" data:@"" responseCallback:^(id responseData) {
    }];
}

//-(void)setWebView:(UIWebView*)webView
//{
//    _webView = webView;
//    [self setupJavascriptBridge];
//}

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
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.delegate = self;
        NSString * html = [self rippleHTML];
        [_webView loadHTMLString:html baseURL:[NSBundle mainBundle].bundleURL];
        [self setupJavascriptBridge];
        
        [self connect];
    }
    return self;
}




@end
