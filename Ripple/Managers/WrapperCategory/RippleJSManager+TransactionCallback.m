//
//  RippleJSManager+TransactionCallback.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+TransactionCallback.h"

@implementation RippleJSManager (TransactionCallback)

-(void)wrapperRegisterHandlerTransactionCallback
{
    /*
     // Only use nmeta data
     
    {
        "engine_result" = tesSUCCESS;
        "engine_result_code" = 0;
        "engine_result_message" = "The transaction was applied.";
        "ledger_hash" = 25844FC8BFA0BDD4B9F901FAD803EDCBE57D35AD1373330F9F691D5857F65C8C;
        "ledger_index" = 1408938;
        meta =     {
            AffectedNodes =         (
                                     {
                                         ModifiedNode =                 {
                                             FinalFields =                     {
                                                 Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                 Balance = 173315610;
                                                 Flags = 0;
                                                 OwnerCount = 1;
                                                 Sequence = 40;
                                             };
                                             LedgerEntryType = AccountRoot;
                                             LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                             PreviousFields =                     {
                                                 Balance = 123315610;
                                             };
                                             PreviousTxnID = ED43BF5E2305261C12641F75E8EED5A973FBF943CC85E3582C1844AA760F4F9B;
                                             PreviousTxnLgrSeq = 1408362;
                                         };
                                     },
                                     {
                                         ModifiedNode =                 {
                                             FinalFields =                     {
                                                 Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                                 Balance = 151499970;
                                                 Flags = 0;
                                                 OwnerCount = 1;
                                                 Sequence = 4;
                                             };
                                             LedgerEntryType = AccountRoot;
                                             LedgerIndex = C42FD18190EEBAFA83EDCBF6556A1F25045E06DB37D725857D09A8B3B3EEBCA1;
                                             PreviousFields =                     {
                                                 Balance = 201499980;
                                                 Sequence = 3;
                                             };
                                             PreviousTxnID = ED43BF5E2305261C12641F75E8EED5A973FBF943CC85E3582C1844AA760F4F9B;
                                             PreviousTxnLgrSeq = 1408362;
                                         };
                                     }
                                     );
            TransactionIndex = 0;
            TransactionResult = tesSUCCESS;
        };
        mmeta =     {
            nodes =         (
                             {
                                 diffType = ModifiedNode;
                                 entryType = AccountRoot;
                                 fields =                 {
                                     Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                     Balance = 173315610;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 40;
                                 };
                                 fieldsFinal =                 {
                                     Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                     Balance = 173315610;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 40;
                                 };
                                 fieldsNew =                 {
                                 };
                                 fieldsPrev =                 {
                                     Balance = 123315610;
                                 };
                                 ledgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                             },
                             {
                                 diffType = ModifiedNode;
                                 entryType = AccountRoot;
                                 fields =                 {
                                     Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                     Balance = 151499970;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 4;
                                 };
                                 fieldsFinal =                 {
                                     Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                     Balance = 151499970;
                                     Flags = 0;
                                     OwnerCount = 1;
                                     Sequence = 4;
                                 };
                                 fieldsNew =                 {
                                 };
                                 fieldsPrev =                 {
                                     Balance = 201499980;
                                     Sequence = 3;
                                 };
                                 ledgerIndex = C42FD18190EEBAFA83EDCBF6556A1F25045E06DB37D725857D09A8B3B3EEBCA1;
                             }
                             );
        };
        status = closed;
        transaction =     {
            Account = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
            Amount = 50000000;
            Destination = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
            Fee = 10;
            Flags = 0;
            Sequence = 3;
            SigningPubKey = 02AD591A74E2DCDB3AEEE8AF8A7FACD70719FEA9F3DCD275E5CDAD01813A185AEA;
            TransactionType = Payment;
            TxnSignature = 3045022100B3AAB65B0B4FA90F3586F28A072F3596F8C7A6503DDF2FB409DDBA9A33A45BA4022059C5AB7ACF4837F25E390EE99FFFE57B31DF169865037AC69DDBC40D8FBF84E0;
            date = 427868340;
            hash = 489E970A6FD4AC584FB321FDC0ACFB2CAA20717503D1007038DA4093A1E687ED;
        };
        type = transaction;
        validated = 1;
    }
    
    
    
     Future callback for USD transaction:
     {
         "engine_result" = tesSUCCESS;
         "engine_result_code" = 0;
         "engine_result_message" = "The transaction was applied.";
         "ledger_hash" = 130581EA0A6EBF8299D085024410F0C447CCEFC8DA7EF80695CC110708534C31;
         "ledger_index" = 1409785;
         meta =     {
             AffectedNodes =         (
                                      {
                                          ModifiedNode =                 {
                                              FinalFields =                     {
                                                  Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                  Balance = 163315510;
                                                  Flags = 0;
                                                  OwnerCount = 1;
                                                  Sequence = 50;
                                              };
                                              LedgerEntryType = AccountRoot;
                                              LedgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                                              PreviousFields =                     {
                                                  Balance = 163315520;
                                                  Sequence = 49;
                                              };
                                              PreviousTxnID = 3BD8E7295078F38117D726A62839CC77AEDD999F85A7CADEB12108B56A5F6BF8;
                                              PreviousTxnLgrSeq = 1409777;
                                          };
                                      },
                                      {
                                          ModifiedNode =                 {
                                              FinalFields =                     {
                                                  Balance =                         {
                                                      currency = USD;
                                                      issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                      value = "0.3";
                                                  };
                                                  Flags = 65536;
                                                  HighLimit =                         {
                                                      currency = USD;
                                                      issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                                      value = 0;
                                                  };
                                                  HighNode = 0000000000000000;
                                                  LowLimit =                         {
                                                      currency = USD;
                                                      issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                                      value = 1;
                                                  };
                                                  LowNode = 0000000000000000;
                                              };
                                              LedgerEntryType = RippleState;
                                              LedgerIndex = 1EB4457CEE28C02EDD3C1A247F18852822CEBC8A8FDCC5589D8CB3F39406C3A8;
                                              PreviousFields =                     {
                                                  Balance =                         {
                                                      currency = USD;
                                                      issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                                      value = "0.2";
                                                  };
                                              };
                                              PreviousTxnID = C33EEC55F460809A11B7FBBD7359EA9C11E57DD0A5E201A66B87A884D89A4433;
                                              PreviousTxnLgrSeq = 1406212;
                                          };
                                      }
                                      );
             TransactionIndex = 0;
             TransactionResult = tesSUCCESS;
         };
         mmeta =     {
             nodes =         (
                              {
                                  diffType = ModifiedNode;
                                  entryType = AccountRoot;
                                  fields =                 {
                                      Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                      Balance = 163315510;
                                      Flags = 0;
                                      OwnerCount = 1;
                                      Sequence = 50;
                                  };
                                  fieldsFinal =                 {
                                      Account = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                      Balance = 163315510;
                                      Flags = 0;
                                      OwnerCount = 1;
                                      Sequence = 50;
                                  };
                                  fieldsNew =                 {
                                  };
                                  fieldsPrev =                 {
                                      Balance = 163315520;
                                      Sequence = 49;
                                  };
                                  ledgerIndex = 1866E369D94B8144C2A7596E1610D560D3A4A50F835812A55A6EEB53D92663B1;
                              },
                              {
                                  diffType = ModifiedNode;
                                  entryType = RippleState;
                                  fields =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.3";
                                      };
                                      Flags = 65536;
                                      HighLimit =                     {
                                          currency = USD;
                                          issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                          value = 0;
                                      };
                                      HighNode = 0000000000000000;
                                      LowLimit =                     {
                                          currency = USD;
                                          issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                          value = 1;
                                      };
                                      LowNode = 0000000000000000;
                                  };
                                  fieldsFinal =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.3";
                                      };
                                      Flags = 65536;
                                      HighLimit =                     {
                                          currency = USD;
                                          issuer = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                                          value = 0;
                                      };
                                      HighNode = 0000000000000000;
                                      LowLimit =                     {
                                          currency = USD;
                                          issuer = rhxwHhfMhySyYB5Wrq7ohSNBqBfAYanAAx;
                                          value = 1;
                                      };
                                      LowNode = 0000000000000000;
                                  };
                                  fieldsNew =                 {
                                  };
                                  fieldsPrev =                 {
                                      Balance =                     {
                                          currency = USD;
                                          issuer = rrrrrrrrrrrrrrrrrrrrBZbvji;
                                          value = "0.2";
                                      };
                                  };
                                  ledgerIndex = 1EB4457CEE28C02EDD3C1A247F18852822CEBC8A8FDCC5589D8CB3F39406C3A8;
                              }
                              );
         };
         status = closed;
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
         type = transaction;
         validated = 1;
     }
    */
    
    [_bridge registerHandler:@"transaction_callback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"transaction_callback called: %@", data);
        
        // Process transaction
        //RPTransactionSubscription * obj = [RPTransactionSubscription new];
        //[obj setValuesForKeysWithDictionary:data];
        
        
        // Testing purposes
        //[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"transaction"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
#warning Update balances according to transaction
        _receivedLines = NO;
        _receivedAccount = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountChanged object:nil userInfo:nil];
    }];
}

-(void)wrapperSubscribeTransactions
{
    NSDictionary * params = @{@"account": _blobData.account_id};
    [_bridge callHandler:@"subscribe_transactions" data:params responseCallback:^(id responseData) {
        NSLog(@"subscribe_transactions response: %@", responseData);
    }];
}

@end
