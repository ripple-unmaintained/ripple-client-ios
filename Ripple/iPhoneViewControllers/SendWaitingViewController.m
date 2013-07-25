//
//  SendWaitingViewController.m
//  Ripple
//
//  Created by Kevin Johnson on 7/24/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "SendWaitingViewController.h"
#import "AppDelegate.h"

@interface SendWaitingViewController ()


@property (weak, nonatomic) IBOutlet UILabel     * labelConfirm;
@property (weak, nonatomic) IBOutlet UILabel     * labelStatus;

@end

@implementation SendWaitingViewController

-(IBAction)buttonBack:(id)sender
{
    AppDelegate * appdelegate =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    [self.navigationController popToViewController:appdelegate.viewControllerBalance animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
