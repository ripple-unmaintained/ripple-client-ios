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
#import "ZBarSDK.h"
#import "RPNewTransaction.h"

@interface SendGenericViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ZBarReaderDelegate> {
    NSArray * contacts;
    RPNewTransaction * transaction;
}

@property (weak, nonatomic) IBOutlet UITableView * tableView;

@end

@implementation SendGenericViewController

-(void)startQRReader
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:^{
        
    }];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    NSString * address = symbol.data;
    
    [self performSegueWithIdentifier:@"Next" sender:address];
    
    // EXAMPLE: do something useful with the barcode data
    //resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    //resultImage.image =
    //[info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:^{
        
    }];
    //[reader dismissModalViewControllerAnimated: YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Next"]) {
        SendAmountViewController * view = [segue destinationViewController];
        view.transaction = transaction;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    transaction.Destination = textField.text;
    //transaction.Destination_name = @"Ripple Address";
    
    [self performSegueWithIdentifier:@"Next" sender:nil];
    
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else {
        return contacts.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            cell.textLabel.text = @"QR Code";
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        }
    }
    else {
        RPContact * contact = [contacts objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = contact.name;
        cell.detailTextLabel.text = contact.address;
    }
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // QR Code
            [self startQRReader];
        }
        else {
            // Custom address
        }
    }
    else {
        RPContact * contact = [contacts objectAtIndex:indexPath.row];
        transaction.Destination = contact.address;
        transaction.Destination_name = contact.name;
        [self performSegueWithIdentifier:@"Next" sender:nil];
    }
    
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
    
    transaction = [RPNewTransaction new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
