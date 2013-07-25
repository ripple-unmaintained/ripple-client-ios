//
//  SendAmountViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendAmountViewController.h"
#import "RPNewTransaction.h"

@interface SendAmountViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField * textFieldAmount;
@property (weak, nonatomic) IBOutlet UILabel     * labelRecipient;

@end

@implementation SendAmountViewController

-(IBAction)buttonNext:(id)sender
{
    [self performSegueWithIdentifier:@"Next" sender:nil];
}

-(IBAction)buttonBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
