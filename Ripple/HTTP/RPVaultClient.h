//
//  RPVaultClient.h
//  Ripple
//
//  Created by Kevin Johnson on 7/18/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface RPVaultClient  : AFHTTPClient

+(RPVaultClient *)sharedClient;


@end
