//
//  SendPathsViewController.h
//  Ripple
//
//  Created by Kevin Johnson on 7/29/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPNewTransaction;

@interface SendPathsViewController : RippleStatusViewController

@property (strong, nonatomic) RPNewTransaction * transaction;
@property (strong, nonatomic) NSArray * paths;

@end
