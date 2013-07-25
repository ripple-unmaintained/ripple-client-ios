//
//  SendAmountViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendAmountViewController.h"
#import "RPNewTransaction.h"
#import "RippleJSManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface SendAmountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField * textFieldAmount;
@property (weak, nonatomic) IBOutlet UILabel     * labelRecipient;

@end

@implementation SendAmountViewController

-(void)sendConfirm
{
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * number = [f numberFromString:self.textFieldAmount.text];
    self.transaction.Amount = number;
    
    [[RippleJSManager shared] rippleSendTransactionAmount:self.transaction.Amount currency:self.transaction.Currency toRecipient:self.transaction.Destination withBlock:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
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
    
    //[self performSegueWithIdentifier:@"Next" sender:nil];
}

-(IBAction)buttonNext:(id)sender
{
    [self sendConfirm];
}

-(IBAction)buttonBack:(id)sender
{
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.textFieldAmount becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.transaction.Destination_name) {
        self.labelRecipient.text = [NSString stringWithFormat:@"To %@", self.transaction.Destination_name];
    }
    else if (self.transaction.Destination) {
        self.labelRecipient.text = [NSString stringWithFormat:@"To Address: %@", self.transaction.Destination];
    }
    else {
        self.labelRecipient.text = @"Unkown destination";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
