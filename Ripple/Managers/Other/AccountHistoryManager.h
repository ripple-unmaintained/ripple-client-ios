//
//  AccountHistoryManager.h
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountHistoryManager : NSObject {
    NSString         * _account;
    
    NSMutableArray   * _tx_history;
}

-(id)initWithAccount:(NSString*)account;

-(NSArray*)rippleTxHistory;
-(void)processAccountTx:(NSDictionary*)responseData;

@end
