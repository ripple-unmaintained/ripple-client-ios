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

/*
{
    account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
    count = 55;
    "ledger_index_max" = 1450364;
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
                                                                             Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                             Balance = 188257074;
                                                                             Flags = 0;
                                                                             OwnerCount = 1;
                                                                             Sequence = 94;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                         PreviousFields =                             {
                                                                             Balance = 187257074;
                                                                         };
                                                                         PreviousTxnID = 41BF0E100050AD7F3D829620852AFC7196B3303D30BE3CD0D86F2296F536EDD8;
                                                                         PreviousTxnLgrSeq = 1450028;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 76997947;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 34;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 77997964;
                                                                             Sequence = 33;
                                                                         };
                                                                         PreviousTxnID = EFF9CB88516994819EC6472BD61EA6AC7E2C1C9F3599232D175BD49640E7CC4E;
                                                                         PreviousTxnLgrSeq = 1450335;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1000000;
                                Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                Fee = 17;
                                Flags = 0;
                                Sequence = 33;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 304502201BD66C53989AAD449EC039071EE5460437346F9B586821AFF041CDB630DAAA2702210095396D00327A55BE1BECCB4AECE39C90AE759730069A563334BB28898A484CBF;
                                date = 428200870;
                                hash = 4DAD85BB35F1D5C5E8E5C6532CF15FC372BA103E4C2C34712CB2B42BB28EEE90;
                                inLedger = 1450364;
                                "ledger_index" = 1450364;
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
                                                                             Balance = 77997964;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 33;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 77997979;
                                                                             Sequence = 32;
                                                                         };
                                                                         PreviousTxnID = 9C77C7A41EA1D97DC15CF517E8531797038CC271EE13D82A1D55226B674341B8;
                                                                         PreviousTxnLgrSeq = 1450334;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 1;
                                TransactionResult = "tecUNFUNDED_PAYMENT";
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1264656655000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 32;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 30450220685011EF7175C65234E3CEF983E8FCB2A9B9E9D366CC1CEC38A0CDB6D1F7941E02210086C890C90A4BEAC337B5E8B9C3B9579C930ABCA4BEBDE8D173EA9C2AD1273647;
                                date = 428200680;
                                hash = EFF9CB88516994819EC6472BD61EA6AC7E2C1C9F3599232D175BD49640E7CC4E;
                                inLedger = 1450335;
                                "ledger_index" = 1450335;
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
                                                                             Balance = 77997979;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 32;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 77997994;
                                                                             Sequence = 31;
                                                                         };
                                                                         PreviousTxnID = C5EF094A6ED09EA15223AD03A83F0917F93478877D3A6021AA546E346A3A147F;
                                                                         PreviousTxnLgrSeq = 1450272;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 1;
                                TransactionResult = "tecUNFUNDED_PAYMENT";
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1264656655000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 31;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 3045022100AAACE284FAB22F835219C6D1AF79D08B0D1C5E1C0CD751E7226BDDC7A65F015502202ABB629B298BECC198C9771AD82E5CDF41BF1819ECE566D772E8BBFBE5848B40;
                                date = 428200680;
                                hash = 9C77C7A41EA1D97DC15CF517E8531797038CC271EE13D82A1D55226B674341B8;
                                inLedger = 1450334;
                                "ledger_index" = 1450334;
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
                                                                             Balance = 77997994;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 31;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 78998009;
                                                                             Sequence = 30;
                                                                         };
                                                                         PreviousTxnID = E108631893ED196DF549248FBEB108D7D7D46C9E8F501F600E32B57906D3CBE8;
                                                                         PreviousTxnLgrSeq = 1450209;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 109999970;
                                                                             Flags = 0;
                                                                             OwnerCount = 0;
                                                                             Sequence = 3;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         PreviousFields =                             {
                                                                             Balance = 108999970;
                                                                         };
                                                                         PreviousTxnID = 28A8DB4B3DA137E82E5E3C747F09646058CC5680182E8AF2DC8F7E7BB858815C;
                                                                         PreviousTxnLgrSeq = 1450082;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 30;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 3045022100D26135F0E6ED387A163152C954B304F74241DAC880ADC6D2FB51A342067E12010220579F7E7A8C0A30536AC010C4C687F6335B81547205ABE15568E5719EA75DF161;
                                date = 428200240;
                                hash = C5EF094A6ED09EA15223AD03A83F0917F93478877D3A6021AA546E346A3A147F;
                                inLedger = 1450272;
                                "ledger_index" = 1450272;
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
                                                                             Balance = 78998009;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 30;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 77998009;
                                                                         };
                                                                         PreviousTxnID = 769CA3A01697B045B69A3FE1BC189F221737B09C86577A85C87AAA41CA71E9AB;
                                                                         PreviousTxnLgrSeq = 1450185;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r3PDtZSa5LiYp1Ysn1vMuMzB59RzV3W9QH;
                                                                             Balance = 162023579050;
                                                                             Flags = 0;
                                                                             OwnerCount = 20;
                                                                             Sequence = 237;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = E0D7BDE68B468FF0B8D948FD865576517DA987569833A05374ADB9A72E870A06;
                                                                         PreviousFields =                             {
                                                                             Balance = 162024579065;
                                                                             Sequence = 236;
                                                                         };
                                                                         PreviousTxnID = 769CA3A01697B045B69A3FE1BC189F221737B09C86577A85C87AAA41CA71E9AB;
                                                                         PreviousTxnLgrSeq = 1450185;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r3PDtZSa5LiYp1Ysn1vMuMzB59RzV3W9QH;
                                Amount = 1000000;
                                Destination = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 236;
                                SigningPubKey = 02EAE5DAB54DD8E1C49641D848D5B97D1B29149106174322EDF98A1B2CCE5D7F8E;
                                TransactionType = Payment;
                                TxnSignature = 3045022100917131F06B58714497078E31E5795581DE0900C8CB628DEA64767B9314E4540C02206C8046EB2121B340E83FACF69C6B7CE0BF02286985150E9BE6579A6CCDF46961;
                                date = 428199770;
                                hash = E108631893ED196DF549248FBEB108D7D7D46C9E8F501F600E32B57906D3CBE8;
                                inLedger = 1450209;
                                "ledger_index" = 1450209;
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
                                                                             Balance = 77998009;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 30;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 76998009;
                                                                         };
                                                                         PreviousTxnID = 28A8DB4B3DA137E82E5E3C747F09646058CC5680182E8AF2DC8F7E7BB858815C;
                                                                         PreviousTxnLgrSeq = 1450082;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r3PDtZSa5LiYp1Ysn1vMuMzB59RzV3W9QH;
                                                                             Balance = 162024579065;
                                                                             Flags = 0;
                                                                             OwnerCount = 20;
                                                                             Sequence = 236;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = E0D7BDE68B468FF0B8D948FD865576517DA987569833A05374ADB9A72E870A06;
                                                                         PreviousFields =                             {
                                                                             Balance = 162025579080;
                                                                             Sequence = 235;
                                                                         };
                                                                         PreviousTxnID = B5D33857D80605A9CD64C292358F142578AB9A4FA8EA72E4B376BAD07E79B902;
                                                                         PreviousTxnLgrSeq = 1449048;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 1;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r3PDtZSa5LiYp1Ysn1vMuMzB59RzV3W9QH;
                                Amount = 1000000;
                                Destination = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 235;
                                SigningPubKey = 02EAE5DAB54DD8E1C49641D848D5B97D1B29149106174322EDF98A1B2CCE5D7F8E;
                                TransactionType = Payment;
                                TxnSignature = 3044022016253D8C02952802D5C4C3AB521E2C892277EA9D6F3F65FBBD75F604068EB727022004532D25436DB728F078543A167DC568BE42D3FDBBEADA76E74679A14E699EDB;
                                date = 428199661;
                                hash = 769CA3A01697B045B69A3FE1BC189F221737B09C86577A85C87AAA41CA71E9AB;
                                inLedger = 1450185;
                                "ledger_index" = 1450185;
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
                                                                             Balance = 76998009;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 30;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 79998024;
                                                                             Sequence = 29;
                                                                         };
                                                                         PreviousTxnID = F2D04AFF3CDE119BAA893D9E24853F5AFAF24E345D8E63B29C66212296D02DB1;
                                                                         PreviousTxnLgrSeq = 1450078;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 108999970;
                                                                             Flags = 0;
                                                                             OwnerCount = 0;
                                                                             Sequence = 3;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         PreviousFields =                             {
                                                                             Balance = 105999970;
                                                                         };
                                                                         PreviousTxnID = F2D04AFF3CDE119BAA893D9E24853F5AFAF24E345D8E63B29C66212296D02DB1;
                                                                         PreviousTxnLgrSeq = 1450078;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 3000000;
                                Destination = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 29;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 3046022100F2A47101D97281E9D2C862E964F76EA11686B329616A07499634A58144C37AF4022100801BBF951AE87CDAB4C5CE00CA374250C36507720885664CE163E6C2140C80ED;
                                date = 428198840;
                                hash = 28A8DB4B3DA137E82E5E3C747F09646058CC5680182E8AF2DC8F7E7BB858815C;
                                inLedger = 1450082;
                                "ledger_index" = 1450082;
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
                                                                             Balance = 79998024;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 29;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 77998024;
                                                                         };
                                                                         PreviousTxnID = 41BF0E100050AD7F3D829620852AFC7196B3303D30BE3CD0D86F2296F536EDD8;
                                                                         PreviousTxnLgrSeq = 1450028;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                                                             Balance = 105999970;
                                                                             Flags = 0;
                                                                             OwnerCount = 0;
                                                                             Sequence = 3;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = C33591B9509A2907B7B0688215F67495DD7F34B2E5900E43BC5E164ACD945CBF;
                                                                         PreviousFields =                             {
                                                                             Balance = 107999985;
                                                                             Sequence = 2;
                                                                         };
                                                                         PreviousTxnID = 7731F598E296CFDE4A48716EDC30B62FEAFBB25B9624D2A823C7006134AFBAEE;
                                                                         PreviousTxnLgrSeq = 1449955;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = rfGKu3tSxwMFZ5mQ6bUcxWrxahACxABqKc;
                                Amount = 2000000;
                                Destination = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 2;
                                SigningPubKey = 027EE6793386CDF5A421BD3E5C8547715CE387DC806995143DCB76E5200BA0B95B;
                                TransactionType = Payment;
                                TxnSignature = 3045022100DE383FBACD2934A8615C8CA8E782ED63C4447970CA0DC15A94C2B943131CF4530220439FE9573926649FAE52F777D6AF9AC7EA5E61F90761F4872ED4783CB7C9F84D;
                                date = 428198810;
                                hash = F2D04AFF3CDE119BAA893D9E24853F5AFAF24E345D8E63B29C66212296D02DB1;
                                inLedger = 1450078;
                                "ledger_index" = 1450078;
                            };
                            validated = 1;
                        },
                        {
                            meta =             {
                                AffectedNodes =                 (
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                             Balance = 187257074;
                                                                             Flags = 0;
                                                                             OwnerCount = 1;
                                                                             Sequence = 94;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                         PreviousFields =                             {
                                                                             Balance = 186257074;
                                                                         };
                                                                         PreviousTxnID = 0C7A768E27E0D063369A50E0983CAA0C2A47AF800C349C7476BD8EAEAE68D12F;
                                                                         PreviousTxnLgrSeq = 1449986;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 77998024;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 29;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 78998039;
                                                                             Sequence = 28;
                                                                         };
                                                                         PreviousTxnID = 0C7A768E27E0D063369A50E0983CAA0C2A47AF800C349C7476BD8EAEAE68D12F;
                                                                         PreviousTxnLgrSeq = 1449986;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1000000;
                                Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 28;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 3046022100A4F7BE66F63F1D8133F74C2285DB2BB765C79D8619EFE28913325384EF3D4147022100CDC66CDA75E6BC05FC832F90906DB1C14F5E8F24C5FF196A2D4057EE998A5183;
                                date = 428198350;
                                hash = 41BF0E100050AD7F3D829620852AFC7196B3303D30BE3CD0D86F2296F536EDD8;
                                inLedger = 1450028;
                                "ledger_index" = 1450028;
                            };
                            validated = 1;
                        },
                        {
                            meta =             {
                                AffectedNodes =                 (
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                             Balance = 186257074;
                                                                             Flags = 0;
                                                                             OwnerCount = 1;
                                                                             Sequence = 94;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                         PreviousFields =                             {
                                                                             Balance = 185257074;
                                                                         };
                                                                         PreviousTxnID = 2F45F8410E00FD9BCFB4EE93AC549ADF661A9DBEBB95E45B68824044C8D2FDC7;
                                                                         PreviousTxnLgrSeq = 1449665;
                                                                     };
                                                                 },
                                                                 {
                                                                     ModifiedNode =                         {
                                                                         FinalFields =                             {
                                                                             Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                                                             Balance = 78998039;
                                                                             Flags = 0;
                                                                             OwnerCount = 2;
                                                                             Sequence = 28;
                                                                         };
                                                                         LedgerEntryType = AccountRoot;
                                                                         LedgerIndex = 43A29F8B474DF86654B1BF9811BDA71AA8050124DD2567CC10F5D904838C15F7;
                                                                         PreviousFields =                             {
                                                                             Balance = 79998054;
                                                                             Sequence = 27;
                                                                         };
                                                                         PreviousTxnID = 7731F598E296CFDE4A48716EDC30B62FEAFBB25B9624D2A823C7006134AFBAEE;
                                                                         PreviousTxnLgrSeq = 1449955;
                                                                     };
                                                                 }
                                                                 );
                                TransactionIndex = 0;
                                TransactionResult = tesSUCCESS;
                            };
                            tx =             {
                                Account = r4LADqzmqQUMhgSyBLTtPMG4pAzrMDx7Yj;
                                Amount = 1000000;
                                Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                Fee = 15;
                                Flags = 0;
                                Sequence = 27;
                                SigningPubKey = 03AF2FB2EC38B072B50EC56360820D35C022D387BFE22D080D689D5DB5AF2C5095;
                                TransactionType = Payment;
                                TxnSignature = 304402206AC0D7A1012053409E5312EA07CAC819B4DE59D7B88C443D73A56889EF6C073F0220323495E532BBD6A1A829B782490E51D9BD0DB21E587A6DD66BA64BA45B1C1AAF;
                                date = 428197970;
                                hash = 0C7A768E27E0D063369A50E0983CAA0C2A47AF800C349C7476BD8EAEAE68D12F;
                                inLedger = 1449986;
                                "ledger_index" = 1449986;
                            };
                            validated = 1;
                        }
                        );
    validated = 1;
}
*/

@end
