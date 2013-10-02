//
//  BalancesViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "BalancesViewController.h"
#import "RippleJSManager.h"
#import "RippleJSManager+Authentication.h"
#import "SendTransactionViewController.h"
#import "SendGenericViewController.h"
#import "RPNewTransaction.h"
#import "AppDelegate.h"

@interface BalancesViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary * balances;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIButton    * navLogout;

@end

@implementation BalancesViewController

-(IBAction)sendButton:(id)sender
{
    [self performSegueWithIdentifier:@"Send" sender:nil];
}

-(IBAction)receiveButton:(id)sender
{
    [self performSegueWithIdentifier:@"Receive" sender:nil];
}

-(IBAction)historyButton:(id)sender
{
    [self performSegueWithIdentifier:@"Tx" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Send"]) {
        SendGenericViewController * view = [segue destinationViewController];
        
        RPNewTransaction * t = [RPNewTransaction new];
        t.Date = [NSDate date];
        t.Currency = sender;
        
        view.transaction = t;
    }
}


-(IBAction)buttonLogout:(id)sender
{
    [[RippleJSManager shared] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)updateBalances
{
    balances = [[RippleJSManager shared] rippleBalances];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Balances";
//}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
    label.text = @"Balances";
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    v.backgroundColor = self.view.backgroundColor;
    [v addSubview:label];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return balances.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.section == 999999) {
        // SHOULDN"T HAPPEN
        if (indexPath.row == 0) {
            // Receive cell
            //NSString *address = [[RippleJSManager shared] rippleWalletAddress];
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"Send";
        }
        else if (indexPath.row == 1) {
            // Receive cell
            //NSString *address = [[RippleJSManager shared] rippleWalletAddress];
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"Receive";
        }
        else {
            // Transaction History
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"History";
        }
        
    }
    else {
        // Currencies
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
        NSNumber * amount = [balances objectForKey:key];
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
        [formatter setMaximumFractionDigits:2];
        
        //        if ([key isEqualToString:@"XRP"]) {
        //            NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        //            cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
        //            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //            cell.detailTextLabel.text = address;
        //        }
        //        else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        //NSLog(@"%@",amount.stringValue);
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //        }
    }
    
    
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 9999) {
        if (indexPath.row == 0) {
            // Receive
            [self performSegueWithIdentifier:@"Send" sender:nil];
        }
        else if (indexPath.row == 1) {
            // Receive
            [self performSegueWithIdentifier:@"Receive" sender:nil];
        }
        else {
            // Transaction History
            [self performSegueWithIdentifier:@"Tx" sender:nil];
            
            
//            NSString *address = [[RippleJSManager shared] rippleWalletAddress];
//            if (address) {
//                UIPasteboard *pb = [UIPasteboard generalPasteboard];
//                [pb setString:address];
//                
//                UIAlertView *alert = [[UIAlertView alloc]
//                                      initWithTitle: @"Copied to clipboard"
//                                      message: address
//                                      delegate: nil
//                                      cancelButtonTitle:@"OK"
//                                      otherButtonTitles:nil];
//                [alert show];
//            }
        }
    }
    else {
        //NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
        //[self performSegueWithIdentifier:@"Send" sender:key];
//        if ([key isEqualToString:@"XRP"]) {
//            // Send XRP only
//            [self performSegueWithIdentifier:@"Send" sender:key];
//        }
    }
}

-(void)appEnteredForeground
{
    //[[RippleJSManager shared] connect];
}

-(void)appEnteredBackground
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Refresh stories every time app becomes active
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name: UIApplicationDidBecomeActiveNotification object:nil];
    
    // Close any stories when entering background
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    appdelegate.viewControllerBalance = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBalances) name:kNotificationUpdatedBalance object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
