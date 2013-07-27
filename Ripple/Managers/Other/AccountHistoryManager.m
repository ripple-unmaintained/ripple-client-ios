//
//  AccountHistoryManager.m
//  Ripple
//
//  Created by Kevin Johnson on 7/26/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "AccountHistoryManager.h"

#import "RPTransaction.h"
#import "NSObject+KJSerializer.h"
#import "RippleJSManager.h"

@implementation AccountHistoryManager

-(NSArray*)rippleTxHistory
{
    return _tx_history;
}

-(void)processAccountTx:(NSDictionary*)responseData
{
    if (responseData && [responseData isKindOfClass:[NSDictionary class]]) {
        NSArray * transactions = [responseData objectForKey:@"transactions"];
        
        _tx_history = [NSMutableArray array];
        for (NSDictionary * transaction in transactions) {
            NSDictionary * tx = [transaction objectForKey:@"tx"];
            
            
            
            RPTxHistory * t = [RPTxHistory new];
            t.FromAccount = [tx objectForKey:@"Account"];
            t.ToAccount = [tx objectForKey:@"Destination"];
            
            NSDictionary * ammount = [tx objectForKey:@"Amount"];
            if (ammount && [ammount isKindOfClass:[NSDictionary class]]) {
                // Non XRP
                t.Currency = [ammount objectForKey:@"currency"];
                
                NSString * ammountString = [ammount objectForKey:@"value"];
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                t.Amount = [f numberFromString:ammountString];
            }
            else {
                // XRP
                t.Currency = @"XRP";

                NSString * ammountString = [tx objectForKey:@"Amount"];
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * num = [f numberFromString:ammountString];
                t.Amount = [NSNumber numberWithUnsignedLongLong:(num.unsignedLongLongValue / XRP_FACTOR)];
            }
            
            //RPTransaction * transaction = [RPTransaction new];
            //[transaction setDictionary:tx];
            
            /*
            Amount =                 {
                currency = USD;
                issuer = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                value = "0.1";
            };
             */
            
            
            if ([t isValid]) {
                [_tx_history addObject:t];
            }
        }
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedAccountTx object:nil userInfo:nil];
    }
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

/*
 Tx result from new ripple account with a 100 XRP balance
 
{
    account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
    count = 1;
    "ledger_index_max" = 1449489;
    "ledger_index_min" = 32570;
    limit = 10;
    offset = 0;
    transactions =     (
                        {
                            meta =             {
                                AffectedNodes =                 (
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 97998084;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 25;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 197998099;
                                                                             Sequence = 24;
                                                                         };
                                                                         PreviousTxnID = F8B37D66A4638AE015885145AA6C746128F0CA10F9D13C7C89EB4528FB9ED3FD;
                                                                         PreviousTxnLgrSeq = 1449367;
                                                                     };
                                                                 },
                                                                 {
                                                                     CreatedNode =                         {
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         NewFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 100000000;
                                                                             Sequence = 1;
                                                                         };
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 100000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 24;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 30450220146C47BA517E229A560CCB68C60207D9BFF64FD34F696CF5C29D3261A4A31641022100DEAF02CF5F397302B9FFE56DA7669CAFB35A1A9E6C839582F984DD7F036C048A;
                                date = 428193440;
                                hash = 678A8EB1F00F95D28F18DB7185C18CF614E34591ECF283B2625632395FCFDF07;
                                inLedger = 1449487;
                                "ledger_index" = 1449487;
                            };
                            validated = 1;
                        }
                        );
    validated = 1;
}
 
 
 Same account with an additional 10 XRP transfered
 
{
    account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
    count = 2;
    "ledger_index_max" = 1449508;
    "ledger_index_min" = 32570;
    limit = 10;
    offset = 0;
    transactions =     (
                        {
                            meta =             {
                                AffectedNodes =                 (
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 87998069;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 26;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 97998084;
                                                                             Sequence = 25;
                                                                         };
                                                                         PreviousTxnID = 678A8EB1F00F95D28F18DB7185C18CF614E34591ECF283B2625632395FCFDF07;
                                                                         PreviousTxnLgrSeq = 1449487;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 110000000;
                                                                             Flags = 0;
                                                                             OwnerCount = 0;
                                                                             Sequence = 1;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         PreviousFields =                             {
                                                                             Balance = 100000000;
                                                                         };
                                                                         PreviousTxnID = 678A8EB1F00F95D28F18DB7185C18CF614E34591ECF283B2625632395FCFDF07;
                                                                         PreviousTxnLgrSeq = 1449487;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 10000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 25;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 304502203B60522FAA1BDEEBDF6E8D760DE4E94426445FBD58B66B52A7438D0BE8033A3E022100FD5AC0F2BE9BCF2B3B5BA74D3065ACCA4FAAFEBB92068B1C748C6FF12CF7F18B;
                                date = 428193690;
                                hash = 954E3E5BB154DA2BD38E6CA55AC513CB23466A5EECEC6067052EEFA80771377D;
                                inLedger = 1449508;
                                "ledger_index" = 1449508;
                            };
                            validated = 1;
                        },
                        {
                            meta =             {
                                AffectedNodes =                 (
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 97998084;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 25;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 197998099;
                                                                             Sequence = 24;
                                                                         };
                                                                         PreviousTxnID = F8B37D66A4638AE015885145AA6C746128F0CA10F9D13C7C89EB4528FB9ED3FD;
                                                                         PreviousTxnLgrSeq = 1449367;
                                                                     };
                                                                 },
                                                                 {
                                                                     CreatedNode =                         {
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         NewFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 100000000;
                                                                             Sequence = 1;
                                                                         };
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 100000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 24;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 30450220146C47BA517E229A560CCB68C60207D9BFF64FD34F696CF5C29D3261A4A31641022100DEAF02CF5F397302B9FFE56DA7669CAFB35A1A9E6C839582F984DD7F036C048A;
                                date = 428193440;
                                hash = 678A8EB1F00F95D28F18DB7185C18CF614E34591ECF283B2625632395FCFDF07;
                                inLedger = 1449487;
                                "ledger_index" = 1449487;
                            };
                            validated = 1;
                        }
                        );
    validated = 1;
}
*/

@end
