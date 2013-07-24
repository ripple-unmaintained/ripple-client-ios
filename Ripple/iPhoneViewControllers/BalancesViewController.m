//
//  BalancesViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/22/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "BalancesViewController.h"
#import "RippleJSManager.h"
#import "SendTransactionViewController.h"

@interface BalancesViewController () <UITableViewDataSource, UITableViewDelegate, RippleJSManagerBalanceDelegate> {
    NSDictionary * balances;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIButton    * navLogout;

@end

@implementation BalancesViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Send"]) {
        SendTransactionViewController * view = [segue destinationViewController];
        view.currency = sender;
    }
}

-(void)RippleJSManagerConnected
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)RippleJSManagerDisconnected
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 20.0f;
        self.view.frame = f;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)checkNetworkStatus
{
    if ([[RippleJSManager shared] isConnected]) {
        [self RippleJSManagerConnected];
    }
    else {
        [self RippleJSManagerDisconnected];
    }
}

-(IBAction)buttonLogout:(id)sender
{
    [[RippleJSManager shared] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)RippleJSManagerBalances:(NSDictionary*)_balances
{
    if (balances.count != _balances.count) {
        balances = _balances;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        balances = _balances;
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return balances.count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    if (indexPath.row == 0) {
        // Receive cell
        
        NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
        cell.textLabel.text = @"Receive";
        cell.detailTextLabel.text = address;
    }
    else {
        // Currencies
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row - 1];
        NSNumber * amount = [balances objectForKey:key];
        
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
        [formatter setMaximumFractionDigits:2]; // Set this if you need 2 digits
        
        //        if ([key isEqualToString:@"XRP"]) {
        //            NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        //            cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
        //            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //            cell.detailTextLabel.text = address;
        //        }
        //        else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        //        }
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        if (address) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:address];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Copied to clipboard"
                                  message: address
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        NSString * key = [[balances allKeys] objectAtIndex:indexPath.row - 1];
        [self performSegueWithIdentifier:@"Send" sender:key];
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

-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(checkNetworkStatus) withObject:nil afterDelay:0.1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Refresh stories every time app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name: UIApplicationDidBecomeActiveNotification object:nil];
    
    // Close any stories when entering background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    // Subscribe to ripple network state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RippleJSManagerConnected) name:kNotificationRippleConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RippleJSManagerDisconnected) name:kNotificationRippleDisconnected object:nil];
    
    [RippleJSManager shared].delegate_balances = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
