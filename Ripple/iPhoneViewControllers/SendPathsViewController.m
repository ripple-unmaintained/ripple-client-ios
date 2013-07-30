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
    
    
    NSString * path = [_paths objectAtIndex:indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = path;
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"Next" sender:nil];
}

-(void)refreshTableView
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self refreshTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
