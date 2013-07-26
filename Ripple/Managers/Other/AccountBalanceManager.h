//
//  UserAccountInformation.h
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RPBlobData, RPAccountData;

@interface AccountBalanceManager : NSObject {
    RPAccountData    * _accountData;
    NSMutableArray   * _accountLines;
}

//+(UserAccountInformation*)shared;
-(NSDictionary*)rippleBalances;

-(void)processAccountInfo:(NSDictionary*)responseData;
-(void)processAccountLines:(NSDictionary*)responseData;
-(void)processTransactionCallback:(NSDictionary*)responseData;

-(void)clearBalances;

@end
