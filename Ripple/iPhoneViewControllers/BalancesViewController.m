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

@interface BalancesViewController () <UITableViewDataSource, UITableViewDelegate, RippleJSManagerBalanceDelegate, RippleJSManagerNetworkStatus> {
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
    return balances.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
    NSNumber * amount = [balances objectForKey:key];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    [formatter setMaximumFractionDigits:2]; // Set this if you need 2 digits
    
    UITableViewCell * cell;
    
    if ([key isEqualToString:@"XRP"]) {
        NSString *address = [[RippleJSManager shared] rippleWalletAddress];
        cell = [tableView dequeueReusableCellWithIdentifier:@"xrp"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
        cell.detailTextLabel.text = address;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:amount], key];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * key = [[balances allKeys] objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"XRP"]) {
        // Send XRP only
        [self performSegueWithIdentifier:@"Send" sender:key];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [RippleJSManager shared].delegate_balances = self;
    [RippleJSManager shared].delegate_network_status = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
