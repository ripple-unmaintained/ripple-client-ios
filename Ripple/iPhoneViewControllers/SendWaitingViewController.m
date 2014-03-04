//
//  SendWaitingViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/24/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendWaitingViewController.h"
#import "AppDelegate.h"
#import "RPNewTransaction.h"
#import "RippleJSManager.h"
#import "RippleJSManager+SendTransaction.h"
#import "SVProgressHUD.h"

@interface SendWaitingViewController ()

@property (weak, nonatomic) IBOutlet UILabel     * labelStatus;
@property (weak, nonatomic) IBOutlet UILabel     * labelErrorReason;
@property (weak, nonatomic) IBOutlet UIButton    * buttonRetry;
@end

@implementation SendWaitingViewController

-(IBAction)buttonRetry:(id)sender
{
    self.buttonRetry.hidden = YES;
    
    [self send];
}

-(void)send
{
    self.labelStatus.text = @"Sending...";
    self.labelErrorReason.text = @"";
    
    //[[RippleJSManager shared] wrapperSendTransactionAmount:self.transaction.Amount fromCurrency:self.transaction.Currency toRecipient:self.transaction.Destination toCurrency:self.transaction.Destination_currency withBlock:^(NSError *error) {
    
    [[RippleJSManager shared] wrapperSendTransactionAmount:self.transaction withBlock:^(NSError *error) {
        if (error) {
            //[SVProgressHUD showErrorWithStatus:@"Could not send"];
            
            self.labelStatus.text = @"Could not send";
            self.labelErrorReason.text = error.localizedDescription;
            
            self.buttonRetry.hidden = NO;
        }
        else {
            // Success
            [SVProgressHUD showSuccessWithStatus:@"Sent!"];
            
            // Pop to balance
            AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
            [self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
        }
    }];
}

-(IBAction)buttonBack:(id)sender
{
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.buttonRetry.hidden = YES;
    
    [self send];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
