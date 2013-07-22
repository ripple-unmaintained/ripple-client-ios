//
//  SendTransactionViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendTransactionViewController.h"
#import "SVProgressHUD.h"
#import "RippleJSManager.h"

@interface SendTransactionViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField * textFieldRecipient;
@property (weak, nonatomic) IBOutlet UITextField * textFieldAmount;

@end

@implementation SendTransactionViewController

-(void)done
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.textFieldRecipient) {
        [self.textFieldAmount becomeFirstResponder];
    }
    else if (textField == self.textFieldAmount) {
        
    }
    return YES;
}

-(IBAction)buttonSend:(id)sender
{
    [SVProgressHUD showWithStatus:@"Sending..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * number = [f numberFromString:self.textFieldAmount.text];
    [[RippleJSManager shared] rippleSendTransactionAmount:number toRecipient:self.textFieldRecipient.text withBlock:^(NSError *error) {
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
            [self done];
        }
    }];
    
}
-(IBAction)buttonCancel:(id)sender
{
    [self done];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.textFieldRecipient becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
