//
//  SendGenericViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendGenericViewController.h"
#import "RippleJSManager.h"
#import "RPContact.h"
#import "SendAmountViewController.h"
#import "RPTransaction.h"

@interface SendGenericViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSArray * contacts;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation SendGenericViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        SendAmountViewController * view = [segue destinationViewController];
        RPContact * contact = sender;
        
        RPTransaction * transaction = [RPTransaction new];
        //transaction.Destination = contact.
        //view.currency = sender;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    
    
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contacts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    RPContact * contact = [contacts objectAtIndex:indexPath.row];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.address;
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    contacts = [[RippleJSManager shared] rippleContacts];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
