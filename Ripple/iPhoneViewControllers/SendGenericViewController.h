//
//  SendGenericViewController.h
//  Ripple
//
//  Created by Kevin Johnson on 7/23/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPNewTransaction;

@interface SendGenericViewController : UIViewController

@property (strong, nonatomic) RPNewTransaction * transaction;

@end
