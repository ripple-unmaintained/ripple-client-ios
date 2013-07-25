//
//  RippleJSManager+Initializer.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+Initializer.h"

@implementation RippleJSManager (Initializer)

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

-(NSString*)rippleHTML
{
    NSMutableString * html = [NSMutableString stringWithString:HTML_BEGIN];
    
    NSString *path;
    NSString *contents;
    
    path = [[NSBundle mainBundle] pathForResource:@"ripple-0.7.17-min" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [html appendFormat:@"<script>%@</script>", contents];
    path = nil;
    contents = nil;
    
    path = [[NSBundle mainBundle] pathForResource:@"jsonrewriter" ofType:@"js"];
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //[html appendFormat:@"<script>%@</script>", contents];
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

-(void)setupJavascriptBridge
{
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
        //#warning Testing purposes only
        raise(1);
    }];
}

-(void)wrapperInitialize
{
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    NSString * html = [self rippleHTML];
    [_webView loadHTMLString:html baseURL:[NSBundle mainBundle].bundleURL];
    [self setupJavascriptBridge];
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



@end
