//
//  ViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "ViewController.h"
#import "RippleJSManager.h"

@interface ViewController ()

//@property (weak, nonatomic) IBOutlet UIWebView * webView;
@property (weak, nonatomic) IBOutlet UITextView * textViewLog;

@end

@implementation ViewController

-(IBAction)buttonPressed:(id)sender
{
    [[RippleJSManager shared] accountInfo];
}

-(IBAction)buttonLogin:(id)sender
{
    [[RippleJSManager shared] login:@"ripplelibtest" andPassword:@"TbEz3Rg6qKkNr72r" withBlock:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Could not login"
                                  message: error.localizedDescription
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSString * html = [[RippleJSManager shared] rippleHTML];
//    [self.webView loadHTMLString:html baseURL:nil];
//    
//    [[RippleJSManager shared] setWebView:self.webView];
    [[RippleJSManager shared] setLog:self.textViewLog];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
