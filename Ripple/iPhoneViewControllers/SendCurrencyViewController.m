//
//  SendCurrencyViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/29/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendCurrencyViewController.h"
#import "AppDelegate.h"
#import "SendAmountViewController.h"
#import "RPNewTransaction.h"

#import "RippleJSManager.h"
#import "RippleJSManager+SendTransaction.h"

@interface SendCurrencyViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSDictionary * balances;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation SendCurrencyViewController

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.text.length > 0) {
        self.transaction.Currency = textField.text;
        [self performSegueWithIdentifier:@"Next" sender:nil];
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        SendAmountViewController * view = [segue destinationViewController];
        view.transaction = self.transaction;
    }
}

-(IBAction)buttonBack:(id)sender
{
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return balances.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.row == 0) {
        // Custom cell
        cell = [tableView dequeueReusableCellWithIdentifier:@"custom"];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        // Currencies
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row - 1];
        //NSNumber * amount = [balances objectForKey:key];
        
        //NSNumberFormatter *formatter = [NSNumberFormatter new];
        //[formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
        //[formatter setMaximumFractionDigits:2]; // Set this if you need 2 digits
        
        cell.textLabel.text = key;// [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        // Custom cell
    }
    else {
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row - 1];
        self.transaction.Currency = key;
        [self performSegueWithIdentifier:@"Next" sender:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    balances = [[RippleJSManager shared] rippleBalances];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
