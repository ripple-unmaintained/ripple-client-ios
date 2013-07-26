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

@interface SendWaitingViewController ()


@property (weak, nonatomic) IBOutlet UILabel     * labelConfirm;
@property (weak, nonatomic) IBOutlet UILabel     * labelStatus;

@end

@implementation SendWaitingViewController

-(void)send
{
    self.labelStatus.text = @"Sending...";
    
    [[RippleJSManager shared] wrapperSendTransactionAmount:self.transaction.Amount currency:self.transaction.Currency toRecipient:self.transaction.Destination withBlock:^(NSError *error) {
        if (error) {
            self.labelStatus.text = @"Could not send";
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Could not send"
                                  message: error.localizedDescription
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            // Success
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
    
    [self send];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
