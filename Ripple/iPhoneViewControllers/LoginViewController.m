//
//  LoginViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "RippleJSManager.h"
#import "RippleJSManager+Authentication.h"
#import "SVProgressHUD.h"

@interface LoginViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField * textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField * textFieldPassword;

@end

@implementation LoginViewController

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        // Cancel
    }
    else {
        // Retry
        [self login];
    }
}

-(IBAction)signupButton:(id)sender
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://ripple.com/client/#/register"]];
}

-(void)login
{
    [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeGradient];
    [[RippleJSManager shared] login:self.textFieldUsername.text andPassword:self.textFieldPassword.text withBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            self.textFieldUsername.text = @"";
            self.textFieldPassword.text = @"";
            
            [self performSegueWithIdentifier:@"Next" sender:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Could not login"
                                  message: error.localizedDescription
                                  delegate: self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:@"Retry", nil];
            [alert show];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.textFieldUsername) {
        [self.textFieldPassword becomeFirstResponder];
    }
    else if (textField == self.textFieldPassword) {
        [self login];
    }
    return YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[RippleJSManager shared] isLoggedIn]) {
        [self performSegueWithIdentifier:@"Next" sender:nil];
    }
    else {
        [self.textFieldUsername becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
