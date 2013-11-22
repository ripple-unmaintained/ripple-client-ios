//
//  RippleJSManager+Authentication.m
//  Ripple
//
//  Created by Kevin Johnson on 7/25/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RippleJSManager+Authentication.h"
#import "NSString+Hashes.h"
#import "SSKeychain.h"
#import "RPVaultClient.h"
#import "Base64.h"

@implementation RippleJSManager (Authentication)

#define SSKEYCHAIN_SERVICE      @"ripple"
#define USERDEFAULTS_RIPPLE_KEY @"RippleKey"

-(NSString*)account_id
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_RIPPLE_KEY];
}

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block
{
    // Normalize
    username = [username lowercaseString];
    
    [SSKeychain setPassword:password forService:SSKEYCHAIN_SERVICE account:username];
    
    NSString * beforeHash = [NSString stringWithFormat:@"%@%@",username,password];
    NSString * afterHash = [beforeHash sha256];
    
    NSString * path = [NSString stringWithFormat:@"/%@", afterHash];
    
    [[RPVaultClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && ![responseObject isKindOfClass:[NSNull class]] && ((NSData*)responseObject).length > 0) {
            // Login correct
            NSString * response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString * decodedResponse = [response base64DecodedString];
            NSLog(@"%@: login success", self.class.description);
            
            NSString * key = [NSString stringWithFormat:@"%d|%@%@",username.length, username,password];
            //NSLog(@"%@: key: %@", self.class.description, key);
            
            // Decrypt
            [_bridge callHandler:@"sjcl_decrypt" data:@{@"key": key,@"decrypt": decodedResponse} responseCallback:^(id responseData) {
                if (responseData && ![responseData isKindOfClass:[NSNull class]]) {
                    // Success
                    NSLog(@"New Blob: %@", responseData);
                    RPBlobData * blob = [RPBlobData new];
                    [blob setDictionary:responseData];
                    _blobData = blob;
                    
                    // Collect contacts
                    NSArray * contacts = [responseData objectForKey:@"contacts"];
                    _contacts = [NSMutableArray arrayWithCapacity:contacts.count];
                    for (NSDictionary * contactDic in contacts) {
                        RPContact * contact = [RPContact new];
                        [contact setDictionary:contactDic];
                        [_contacts  addObject:contact];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedContacts object:nil userInfo:nil];
                    
                    // Save ripple address
                    [[NSUserDefaults standardUserDefaults] setObject:_blobData.account_id forKey:USERDEFAULTS_RIPPLE_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self wrapperSetAccount:_blobData.account_id];
                    _isLoggedIn = YES;
                    
                    block(nil);
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedIn object:nil userInfo:nil];
                    /*
                     Example blob
                     {
                     "account_id" = rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96;
                     contacts =     (
                     );
                     "master_seed" = snShK2SuSqw7VjAzGKzT5xc1Qyp4K;
                     "preferred_issuer" =     {
                     };
                     "preferred_second_issuer" =     {
                     };
                     }
                     */
                }
                else {
                    // Failed
                    NSLog(@"decrypt_blob failed response: %@", responseData);
                    NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
                    [self logout];
                    block(error);
                }
            }];
        }
        else {
            // Login blobvault failed
            NSLog(@"%@: login failed. Invalid username or password", self.class.description);
            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
            [self logout];
            block(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: login failed: %@",self.class.description, error.localizedDescription);
        [self logout];
        block(error);
    }];
}

-(void)wrapperSetAccount:(NSString*)account
{
    // Set account in wrapper
    NSDictionary * data = @{@"account": account};
    [_bridge callHandler:@"set_account" data:data responseCallback:^(id responseData) {
        NSLog(@"set_account response: %@", responseData);
        assert([responseData isEqualToString:account]);
    }];
}


-(NSString*)returnUsername:(NSArray*)array
{
    for (NSDictionary* dic in array) {
        NSString * username = [dic objectForKey:@"acct"];
        if (username && [username isKindOfClass:[NSString class]]) {
            return username;
        }
    }
    return nil;
}

-(void)checkForLogin
{
    NSArray * accounts = [SSKeychain allAccounts];
    NSString * username = [self returnUsername:accounts];
    if (username) {
        NSString * password = [SSKeychain passwordForService:SSKEYCHAIN_SERVICE account:username];
        if (username && password && username.length > 0 && password.length > 0) {
            
            NSString *account_id = [self account_id];
            if (account_id) {
                [self wrapperSetAccount:account_id];
            }
            
            
            [self login:username andPassword:password withBlock:^(NSError *error) {
                
            }];
            
            
        }
    }
}


-(BOOL)isLoggedIn
{
    NSArray * accounts = [SSKeychain allAccounts];
    NSString * username = [self returnUsername:accounts];
    if (username) {
        return YES;
    }
    return NO;
}

-(void)logout
{
    _isLoggedIn = NO;
    _blobData = nil;
    [_accountBalance clearBalances];
    
    NSArray * accounts = [SSKeychain allAccounts];
    for (NSDictionary * dic in accounts) {
        NSString * username = [dic objectForKey:@"acct"];
        NSError * error;
        [SSKeychain deletePasswordForService:SSKEYCHAIN_SERVICE account:username error:&error];
        //NSLog(@"%@", error.localizedDescription);
        
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_RIPPLE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedOut object:nil userInfo:nil];
}

@end
