//
//  TxViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "TxViewController.h"

#import "RippleJSManager.h"
#import "RPTxHistory.h"

@interface TxViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray * tx;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation TxViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tx.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
    
    RPTxHistory * obj = [tx objectAtIndex:indexPath.row];
    
    NSString * account = [[RippleJSManager shared] rippleWalletAddress];
    
    if ([obj.FromAccount isEqualToString:account]) {
        // Sent
        cell.textLabel.text = [NSString stringWithFormat:@"Sent %@ %@", obj.Amount, obj.Currency];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"To: %@", obj.ToAccount];
    }
    else if ([obj.ToAccount isEqualToString:account]) {
        // Received
        cell.textLabel.text = [NSString stringWithFormat:@"Received %@ %@", obj.Amount, obj.Currency];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"From: %@", obj.FromAccount];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)buttonBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateTx
{
    tx = [[RippleJSManager shared] rippleTxHistory];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self updateTx];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTx) name:kNotificationUpdatedAccountTx object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
