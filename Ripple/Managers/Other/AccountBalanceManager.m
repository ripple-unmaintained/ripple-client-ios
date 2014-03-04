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

#import "RPHelper.h"

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
            //raise(1);
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
        //raise(1);
        NSLog(@"processAccountLines error");
    }
}

-(void)processTransactionCallback:(NSDictionary*)responseData
{
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        NSDictionary * mmeta = [responseData objectForKey:@"mmeta"];
        NSArray * nodes = [mmeta objectForKey:@"nodes"];
        
        BOOL updatedXRP = NO;
        BOOL updatedIOU = NO;
        
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
                        updatedXRP = YES;
                    }
                }
            }
            else {
                // IOU
                updatedIOU = YES;
            }
        }
        
        
        
        // Parse transaction
        /*
        transaction =     {
            Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Amount =         {
                currency = USD;
                issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                value = "0.1";
            };
            Destination = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Fee = 10;
            Flags = 0;
            SendMax =         {
                currency = USD;
                issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                value = "0.101";
            };
            Sequence = 49;
            SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
            TransactionType = Payment;
            TxnSignature = 3045022100B53B8812B9C0AA770D6CC308F12042862A52631CF15D00BA96511BEEB798D11D02203F889F523402540EA15E37A8D7303B57DA58C194881E1EE522AFF864A3F86BB0;
            date = 427872630;
            hash = 84C4432B247C1E27F55180236993E86686361729A803C4AD998C5334B5898287;
        };
        */
        
        NSDictionary * transaction = [responseData objectForKey:@"transaction"];
        NSString * toAccount = [transaction objectForKey:@"Destination"];
        NSString * fromAccount = [transaction objectForKey:@"Account"];
        NSString * currency;
        NSNumber * value;
        if ([toAccount isEqualToString:_account]) {
            // Received transaction
            id tmp = [transaction objectForKey:@"Amount"];
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                NSDictionary * amount = (NSDictionary*)tmp;
                // Received IOU
                currency = [amount objectForKey:@"currency"];
                value = [RPHelper safeNumberFromDictionary:amount withKey:@"value"];
            }
            else {
                // Received XRP
                NSDecimalNumber * drop = [RPHelper safeDecimalNumberFromDictionary:transaction withKey:@"Amount"];
                value = [RPHelper dropsToRipples:drop];
                
                currency = GLOBAL_XRP_STRING;
            }
            
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
            [formatter setMaximumFractionDigits:20];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: [NSString stringWithFormat:@"Received %@ %@ from", [formatter stringFromNumber:value],currency]
                                  message:fromAccount
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        
        
        
        
        
        if (updatedXRP) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedBalance object:nil userInfo:nil];
        }
        if (updatedIOU) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountChanged object:nil userInfo:nil];
        }
        
        // Refresh Tx
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshTx object:nil userInfo:nil];
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
        NSDecimalNumber * balance = [RPHelper dropsToRipples:_accountData.Balance];
        [balances setObject:balance forKey:GLOBAL_XRP_STRING];
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
