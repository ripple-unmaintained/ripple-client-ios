//
//  UserAccountInformation.m
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "AccountBalanceManager.h"

#import "NSObject+KJSerializer.h"
#import "RippleJSManager.h"

#import "RPBlobData.h"
#import "RPContact.h"
#import "RPAccountData.h"
#import "RPAccountLine.h"
#import "RPError.h"

@interface AccountBalanceManager () {
    
}

@end

@implementation AccountBalanceManager

-(RPError*)checkForError:(NSDictionary*)response
{
    RPError * error;
    if ([response isKindOfClass:[NSDictionary class]] && [response objectForKey:@"error"]) {
        error = [RPError new];
        [error setDictionary:response];
    }
    return error;
}

-(void)processAccountInfo:(NSDictionary*)responseData
{
    RPError * error = [self checkForError:responseData];
    if (!error) {
        NSDictionary * accountDataDic = [responseData objectForKey:@"account_data"];
        if (accountDataDic) {
            RPAccountData * obj = [RPAccountData new];
            [obj setDictionary:accountDataDic];
            
            // Check for valid?
            _accountData = obj;
            
            //[self log:[NSString stringWithFormat:@"Balance XRP: %@", accountData.Balance]];
            
            //[self processBalances];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
        }
        else {
            // Unknown object
            raise(1);
        }
    }
    else {
        // Error
        //NSString * error_message = [error.remote objectForKey:@"error_message"];
        //[self log:error_message];
        //raise(1);
        NSLog(@"AccountInfor error: %@", error.error_message);
    }
}

-(void)processAccountLines:(NSDictionary*)responseData
{
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        NSArray * lines = [responseData objectForKey:@"lines"];
        if (lines && [lines isKindOfClass:[NSArray class]]) {
            _accountLines = [NSMutableArray arrayWithCapacity:lines.count];
            for (NSDictionary * line in lines) {
                RPAccountLine * obj = [RPAccountLine new];
                [obj setDictionary:line];
                [_accountLines addObject:obj];
                
                //[self log:[NSString stringWithFormat:@"Balance %@: %@", obj.currency, obj.balance]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
        }
    }
    else {
        // TODO handle error?
        raise(1);
    }
}

-(void)processTransactionCallback:(NSDictionary*)responseData
{
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        NSDictionary * mmeta = [responseData objectForKey:@"mmeta"];
        NSArray * nodes = [mmeta objectForKey:@"nodes"];
        for (NSDictionary * node in nodes) {
            NSString * entryType = [node objectForKey:@"entryType"];
            if ([entryType isEqualToString:@"AccountRoot"]) {
                // XRP
                NSDictionary * fields = [node objectForKey:@"fields"];
                NSString * Account = [fields objectForKey:@"Account"];
                if ([Account isEqualToString:_account]) {
                    // Balance is your account
                    RPAccountData * accountData = [RPAccountData new];
                    [accountData setDictionary:fields];
                    
                    // Validate?
                    if (accountData.Account && accountData.Balance) {
                        _accountData = accountData;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
                    }
                }
            }
            else {
                // IOU
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountChanged object:nil userInfo:nil];
            }
        }
    }
}

-(void)clearBalances
{
    _accountData = nil;
    _accountLines = nil;
}

-(NSDictionary*)rippleBalances
{
    NSMutableDictionary * balances = [NSMutableDictionary dictionary];
    if (_accountData) {
        NSNumber * balance = [NSNumber numberWithUnsignedLongLong:(_accountData.Balance.unsignedLongLongValue / XRP_FACTOR)];
        [balances setObject:balance forKey:@"XRP"];
    }
    for (RPAccountLine * line in _accountLines) {
        NSNumber * balance = [balances objectForKey:line.currency];
        if (balance) {
            balance = [NSNumber numberWithDouble:(balance.doubleValue + line.balance.doubleValue)];
        }
        else {
            balance = line.balance;
        }
        
        [balances setObject:balance forKey:line.currency];
    }
    return balances;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)initWithAccount:(NSString*)account
{
    _account = account;
    return [self init];
}

//+(UserAccountInformation*)shared
//{
//    static UserAccountInformation * obj;
//    if (!obj) {
//        obj = [UserAccountInformation new];
//    }
//    return obj;
//}

@end
