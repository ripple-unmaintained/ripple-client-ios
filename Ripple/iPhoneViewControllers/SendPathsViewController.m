//
//  SendPathsViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/29/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendPathsViewController.h"
#import "AppDelegate.h"
#import "SendWaitingViewController.h"
#import "RPNewTransaction.h"
#import "RippleJSManager.h"
#import "RippleJSManager+SendTransaction.h"
#import "SVProgressHUD.h"

@interface SendPathsViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray * _paths;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UILabel     * labelFindingPaths;

@end

@implementation SendPathsViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        SendWaitingViewController * view = [segue destinationViewController];
        view.transaction = self.transaction;
    }
}

-(IBAction)buttonBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    //[self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paths.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    [formatter setMaximumFractionDigits:20];
    
    RPAmount * path = [_paths objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:path.value], path.currency];
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RPAmount * path = [_paths objectAtIndex:indexPath.row];
    
    if ([path.currency isEqualToString:GLOBAL_XRP_STRING]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:APPLE_MESSAGE_TITLE
                                                         message:APPLE_MESSAGE_MESG
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
    else {
        self.transaction.Currency = path.currency;
        [self performSegueWithIdentifier:@"Next" sender:nil];
    }
}

-(void)refreshTableView
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.hidden = YES;
    self.labelFindingPaths.text = @"Finding paths...";
    self.labelFindingPaths.hidden = NO;
    
    [[RippleJSManager shared] wrapperFindPathWithAmount:self.transaction.Amount currency:self.transaction.Destination_currency toRecipient:self.transaction.Destination withBlock:^(NSArray *paths, NSError *error) {
        if (!error) {
            self.tableView.hidden = NO;
            _paths = paths;
            self.labelFindingPaths.hidden = YES;
            [self refreshTableView];
        }
        else {
            self.labelFindingPaths.text = @"Could not find path";
        }
    }];
    
    
    [self refreshTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
