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
    
}

-(void)setupJavascriptBridge
{
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
        
#warning Testing purposes only
        raise(1);
    }];
    
    [_bridge registerHandler:@"rippleRemoteConnectedCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleConnectedCallback called: %@", data);
        
        NSDictionary * accountDataDic = [data objectForKey:@"account_data"];
        if (accountDataDic) {
            RPAccountData * obj = [RPAccountData new];
            [obj setDictionary:accountDataDic];
            
            // Check for valid?
            accountData = obj;
        }
        
        //responseCallback(@"Response from testObjcCallback");
        
        //[_log insertText:data];
        //_log.text = [NSString stringWithFormat:@"%@\n%@",data,_log.text];
    }];
    
    
    
    [_bridge registerHandler:@"rippleRemoteLedgerClosedCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteLedgerClosed called: %@", data);
        
        RPLedgerClosed * obj = [RPLedgerClosed new];
        [obj setDictionary:data];
        // Validate?
        
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    
    [_bridge registerHandler:@"account_information_success" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericCallback called: %@", data);
        //responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge registerHandler:@"account_information_error" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"rippleRemoteGenericCallback called: %@", data);
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

-(void)accountInformation
{
    [_bridge callHandler:@"account_information" data:[NSDictionary dictionaryWithObject:@"rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb" forKey:@"ripple_address"] responseCallback:^(id responseData) {
        NSLog(@"accountInformation response: %@", responseData);
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
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
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
    }
    return self;
}




@end
