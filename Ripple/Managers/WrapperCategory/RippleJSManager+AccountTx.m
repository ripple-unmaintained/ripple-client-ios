//
//  RippleJSManager+AccountTx.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+AccountTx.h"

#define MAX_TRANSACTIONS 10

@implementation RippleJSManager (AccountTx)

// Last transactions
-(void)wrapperAccountTx
{
    /*
    {
        account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
        count = 3;˘
        "ledger_index_max" = 1364947;
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
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.4620233117875503";
                                                                                 };
                                                                                 Flags = 131072;
                                                                                 HighLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                     value = "0.01";
                                                                                 };
                                                                                 HighNode = 0000000000000000;
                                                                                 LowLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowNode = 000000000000009A;
                                                                             };
                                                                             LedgerEntryType = RippleState;
                                                                             LedgerIndex = 0AD2981C87449709BEA806EB6E597FB6ACAE3C01DF13A1A16B130870E19539BD;
                                                                             PreviousFields =                             {
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.6624233117875503";
                                                                                 };
                                                                             };
                                                                             PreviousTxnID = AE419B397AA1EAD0FE0DB8812F8E38A2582BD285336477D2989039B4AF1E35E8;
                                                                             PreviousTxnLgrSeq = 1364352;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Flags = 0;
                                                                                 Owner = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                 RootIndex = 7E1247F78EFC74FA9C0AE39F37AF433966615EB9B757D8397C068C2849A8F4A5;
                                                                             };
                                                                             LedgerEntryType = DirectoryNode;
                                                                             LedgerIndex = 102BCA4A7E3173D4F78F105A05571F5136171218F7BF0EA57DAC3FE3984F9E42;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 Balance = 170215990;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 1;
                                                                                 Sequence = 2;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             PreviousFields =                             {
                                                                                 Balance = 200000000;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 1;
                                                                             };
                                                                             PreviousTxnID = 58571356139F9EA164D1D3C3712C50DB9847CA8A839BB6FA27313C0AD67B3199;
                                                                             PreviousTxnLgrSeq = 1364516;
                                                                         };
                                                                     },
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = DirectoryNode;
                                                                             LedgerIndex = 25314706E5D3EBF756E867A020F476C36740E6B0A47037F682BB62A1E149B030;
                                                                             NewFields =                             {
                                                                                 Owner = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 RootIndex = 25314706E5D3EBF756E867A020F476C36740E6B0A47037F682BB62A1E149B030;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                 Balance = 663783910;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 6;
                                                                                 Sequence = 94;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 30E3D1D8D65EEABEF9878C8DE3BAC4BA474144EDF981CF8AEEC78EAC1CE67BEA;
                                                                             PreviousFields =                             {
                                                                                 Balance = 633999910;
                                                                             };
                                                                             PreviousTxnID = EC7F5A4B524E2C04FE8E655A6A3A48499CD5F5C5F468E6212E2D1B266CFCA99D;
                                                                             PreviousTxnLgrSeq = 1364517;
                                                                         };
                                                                     },
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = RippleState;
                                                                             LedgerIndex = 45BE39B8F9F8B55C9F978C76B99C57B1072EEA95B00DB222B1907BE24EDC3935;
                                                                             NewFields =                             {
                                                                                 Balance =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                                                     value = "-0.2";
                                                                                 };
                                                                                 Flags = 131072;
                                                                                 HighLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowLimit =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = 0;
                                                                                 };
                                                                                 LowNode = 00000000000000B7;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                 Balance = 574391821777;
                                                                                 Domain = 6269747374616D702E6E6574;
                                                                                 EmailHash = 5B33B93C7FFE384D53450FC666BB11FB;
                                                                                 Flags = 131072;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 305;
                                                                                 TransferRate = 1002000000;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = B7D526FDDF9E3B3F95C3DC97C353065B0482302500BBB8051A5C090B596C6133;
                                                                             PreviousTxnID = CCA38325077CD6B836506280B8A6C87B88AF650476E594840E4CAB7EAC4C290D;
                                                                             PreviousTxnLgrSeq = 1364203;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rDQokjxtFTymU6LwnRwcyyCoLXcxv1Ey5m;
                                                                                 BookDirectory = 4627DFFCFF8B5A265EDBD8AE8C14A52325DBFEDAF4F5C32E5D054A6B64FFE000;
                                                                                 BookNode = 0000000000000000;
                                                                                 Flags = 131072;
                                                                                 OwnerNode = 0000000000000000;
                                                                                 Sequence = 93;
                                                                                 TakerGets =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = "15.51";
                                                                                 };
                                                                                 TakerPays = 2309749200;
                                                                             };
                                                                             LedgerEntryType = Offer;
                                                                             LedgerIndex = CB036847C92A861D50E842E0825DDADBF41A1C320A85A8FB537422E7617857F3;
                                                                             PreviousFields =                             {
                                                                                 TakerGets =                                 {
                                                                                     currency = USD;
                                                                                     issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                                                                     value = "15.71";
                                                                                 };
                                                                                 TakerPays = 2339533200;
                                                                             };
                                                                             PreviousTxnID = EC7F5A4B524E2C04FE8E655A6A3A48499CD5F5C5F468E6212E2D1B266CFCA99D;
                                                                             PreviousTxnLgrSeq = 1364517;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 1;
                                    SigningPubKey = 0376BA4EAE729354BED97E26A03AEBA6FB9078BBBB1EAB590772734BCE42E82CD5;
                                    TakerGets = 30000000;
                                    TakerPays =                 {
                                        currency = USD;
                                        issuer = rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B;
                                        value = "0.2";
                                    };
                                    TransactionType = OfferCreate;
                                    TxnSignature = 3045022100F0E2743C791E30850620B0A405D7E62D03784A1ADAADA538FF4C6022AE967A9E022044997FE8C001E3AADA918E7F6D56DDE882C976A1BEBDBAF81D06F05B59BC23D6;
                                    date = 427593490;
                                    hash = C77D333A3F9341F3116C8E191505DC17C204E4384EDAEEB1D6998440A991EDAD;
                                    inLedger = 1364528;
                                    "ledger_index" = 1364528;
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
                                                                                 Balance = 200000000;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 0;
                                                                                 Sequence = 1;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             PreviousFields =                             {
                                                                                 Balance = 100000000;
                                                                             };
                                                                             PreviousTxnID = 1867B623EE6F5BA89E002C3F38C81851C624CB0C0E3328C362054357A78145B4;
                                                                             PreviousTxnLgrSeq = 1345588;
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                                                                 Balance = 379643512152;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 5;
                                                                                 Sequence = 29;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 444C5754601F7E943146CCF53492E3A97BE590FD347C17339FA52C5BF340C7C3;
                                                                             PreviousFields =                             {
                                                                                 Balance = 379743512162;
                                                                                 Sequence = 28;
                                                                             };
                                                                             PreviousTxnID = E68B5DC8650FFCC8DB67F6D2518B643EB1EE3589A1D83C5BDFC902647F71738B;
                                                                             PreviousTxnLgrSeq = 1364513;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                    Amount = 100000000;
                                    Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 28;
                                    SigningPubKey = 03420F50BABFCA24154986C459148E2FCBED8AB64F6C072AB3A209109669F50D6F;
                                    TransactionType = Payment;
                                    TxnSignature = 3046022100A3876F23B617E769CF43C9D537AA84075818AB1ACE2BFF4F34E11ABC049A72EB022100F29A6EEF831912DA01A4E63AEA2A37B7FE64285F36FE9CBFFDB3E229CE1EB0B8;
                                    date = 427593410;
                                    hash = 58571356139F9EA164D1D3C3712C50DB9847CA8A839BB6FA27313C0AD67B3199;
                                    inLedger = 1364516;
                                    "ledger_index" = 1364516;
                                };
                                validated = 1;
                            },
                            {
                                meta =             {
                                    AffectedNodes =                 (
                                                                     {
                                                                         CreatedNode =                         {
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                                                             NewFields =                             {
                                                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                                                 Balance = 100000000;
                                                                                 Sequence = 1;
                                                                             };
                                                                         };
                                                                     },
                                                                     {
                                                                         ModifiedNode =                         {
                                                                             FinalFields =                             {
                                                                                 Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                                                                 Balance = 479953512222;
                                                                                 Flags = 0;
                                                                                 OwnerCount = 5;
                                                                                 Sequence = 22;
                                                                             };
                                                                             LedgerEntryType = AccountRoot;
                                                                             LedgerIndex = 444C5754601F7E943146CCF53492E3A97BE590FD347C17339FA52C5BF340C7C3;
                                                                             PreviousFields =                             {
                                                                                 Balance = 480053512232;
                                                                                 Sequence = 21;
                                                                             };
                                                                             PreviousTxnID = 3A186BA897FD4854CCBB4DA06621F2F2FEC0192021E81799F391B13B16F930D4;
                                                                             PreviousTxnLgrSeq = 1344695;
                                                                         };
                                                                     }
                                                                     );
                                    TransactionIndex = 0;
                                    TransactionResult = tesSUCCESS;
                                };
                                tx =             {
                                    Account = rK2KG1KCL5Nidneu6mKd9tav3hBPQ8deVb;
                                    Amount = 100000000;
                                    Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                    Fee = 10;
                                    Flags = 0;
                                    Sequence = 21;
                                    SigningPubKey = 03420F50BABFCA24154986C459148E2FCBED8AB64F6C072AB3A209109669F50D6F;
                                    TransactionType = Payment;
                                    TxnSignature = 3044022060A23D59A1C2F60597995FFD76E08BCBC30E1359ADA52620442BD915CF180AC7022071E6FFAB15B42208B8D3ABAE1A44B7FC25549A6506A87DB70FB18ECA723FCE05;
                                    date = 427441910;
                                    hash = 1867B623EE6F5BA89E002C3F38C81851C624CB0C0E3328C362054357A78145B4;
                                    inLedger = 1345588;
                                    "ledger_index" = 1345588;
                                };
                                validated = 1;
                            }
                            );
        validated = 1;
    }
    */
    
    NSDictionary * params = @{@"account": _blobData.account_id,
                              @"secret": _blobData.master_seed,
    
                              // accountTx
                              @"params": @{@"account": _blobData.account_id,
                                           @"ledger_index_min": [NSNumber numberWithInt:-1],
                                           @"descending": @YES,
                                           @"limit": [NSNumber numberWithInt:MAX_TRANSACTIONS],
                                           @"count": @YES}
                              };

    [_bridge callHandler:@"account_tx" data:params responseCallback:^(id responseData) {
        NSLog(@"account_tx response: %@", responseData);
    }];
}

@end
