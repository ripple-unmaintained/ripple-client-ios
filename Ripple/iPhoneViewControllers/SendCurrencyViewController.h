//
//  SendCurrencyViewController.h
//  Ripple
//
//  Created by Kevin Johnson on 7/29/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPNewTransaction;

@interface SendCurrencyViewController : UIViewController

@property (strong, nonatomic) RPNewTransaction * transaction;

@end
