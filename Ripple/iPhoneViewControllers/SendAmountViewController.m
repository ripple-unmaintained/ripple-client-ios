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
#import "AppDelegate.h"
#import "SendPathsViewController.h"
#import "SVProgressHUD.h"
#import "RippleJSManager+SendTransaction.h"
#import "SendWaitingViewController.h"

@interface SendAmountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField * textFieldAmount;
@property (weak, nonatomic) IBOutlet UILabel     * labelRecipient;
@property (weak, nonatomic) IBOutlet UIButton    * buttonSend;

@end

@implementation SendAmountViewController

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * afterText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (afterText.length > 0 && ![afterText isEqualToString:@"."]) {
        self.buttonSend.hidden = NO;
    }
    else {
        self.buttonSend.hidden = YES;
    }
    
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSArray*)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        SendPathsViewController * view = [segue destinationViewController];
        view.transaction = self.transaction;
        view.paths = sender;
    }
    else if ([segue.identifier isEqualToString:@"Skip"]) {
        SendWaitingViewController * view = [segue destinationViewController];
        view.transaction = self.transaction;
    }
}

-(void)sendConfirm
{
    
}

-(IBAction)buttonNext:(id)sender
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * number = [f numberFromString:self.textFieldAmount.text];
    self.transaction.Amount = number;
    
    //[self performSegueWithIdentifier:@"Skip" sender:nil];
    
    [SVProgressHUD showWithStatus:@"Finding paths..." maskType:SVProgressHUDMaskTypeGradient];
    [[RippleJSManager shared] wrapperFindPathWithAmount:self.transaction.Amount currency:self.transaction.Currency toRecipient:self.transaction.Destination withBlock:^(NSArray *paths, NSError *error) {
        if (!error) {
            [SVProgressHUD dismiss];
            
            [self performSegueWithIdentifier:@"Next" sender:paths];
        }
        else {
            // Check if sending XRP
            if ([self.transaction.Currency isEqualToString:GLOBAL_XRP_STRING]) {
                [self performSegueWithIdentifier:@"Skip" sender:nil];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Could not find path"];
            }
        }
    }];
    
    
    // Finding paths
//    if ([self.transaction.Currency isEqualToString:GLOBAL_XRP_STRING]) {
//        [self performSegueWithIdentifier:@"Skip" sender:nil];
//    }
//    else {
//        [SVProgressHUD showWithStatus:@"Finding paths..." maskType:SVProgressHUDMaskTypeGradient];
//        [[RippleJSManager shared] wrapperFindPathWithAmount:self.transaction.Amount currency:self.transaction.Currency toRecipient:self.transaction.Destination withBlock:^(NSArray *paths, NSError *error) {
//            if (!error) {
//                [SVProgressHUD dismiss];
//                
//                [self performSegueWithIdentifier:@"Next" sender:paths];
//            }
//            else {
//                [SVProgressHUD showErrorWithStatus:@"Could not find path"];
//            }
//        }];
//    }
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
    
    self.buttonSend.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
