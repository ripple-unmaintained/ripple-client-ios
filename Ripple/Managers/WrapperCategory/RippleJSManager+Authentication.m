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
#import "Base64.h"

@implementation RippleJSManager (Authentication)

#define SSKEYCHAIN_SERVICE      @"ripple"
#define USERDEFAULTS_RIPPLE_KEY @"RippleKey"
#define USERDEFAULTS_RIPPLE_USERNAME @"RippleUsername"

-(NSString*)account_id
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_RIPPLE_KEY];
}

-(NSString*)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_RIPPLE_USERNAME];
}

-(void)customTimeout:(NSTimer*)timer
{
    [_operationManager.operationQueue cancelAllOperations];
    
    if (_isAttemptingLogin) {
        // Try again
        NSString * username = [timer.userInfo objectForKey:@"username"];
        NSString * password = [timer.userInfo objectForKey:@"password"];
        id block = [timer.userInfo objectForKey:@"block"];
        [self login:username andPassword:password withBlock:block];
    }
}

-(void)cancelTimeout
{
    // Cancel timeout
    [_networkTimeout invalidate];
    _networkTimeout = nil;
}

-(void)delayedLogin:(NSArray*)login
{
    [self login:login[0] andPassword:login[1] withBlock:login[2]];
}

-(void)login:(NSString*)username andPassword:(NSString*)password withBlock:(void(^)(NSError* error))block
{
    NSLog(@"%@: Atempting to log in as: %@", self, username);
    _isAttemptingLogin = YES;
    
    // Normalize
    username = [username lowercaseString];
    
    NSString * beforeHash = [NSString stringWithFormat:@"%@%@",username,password];
    NSString * afterHash = [beforeHash sha256];
    
    NSString * path = [NSString stringWithFormat:@"%@/%@", GLOBAL_BLOB_VAULT, afterHash];
    
    [_operationManager.operationQueue cancelAllOperations];
    
    _operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_operationManager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self cancelTimeout];
        
        if (responseObject && ![responseObject isKindOfClass:[NSNull class]] && ((NSData*)responseObject).length > 0) {
            
            NSString * response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString * decodedResponse = [response base64DecodedString];
            
            if (decodedResponse) {
                
                NSString * key = [NSString stringWithFormat:@"%d|%@%@",username.length, username,password];
                //NSLog(@"%@: key: %@", self.class.description, key);
                
                // Decrypt
                [_bridge callHandler:@"sjcl_decrypt" data:@{@"key": key,@"decrypt": decodedResponse} responseCallback:^(id responseData) {
                    if (responseData && ![responseData isKindOfClass:[NSNull class]]) {
                        // Success
                        // Save password
                        [SSKeychain setPassword:password forService:SSKEYCHAIN_SERVICE account:username];
                        
                        NSLog(@"%@: login success", self.class.description);
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
                        
                        NSString * wallet = _blobData.account_id;
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatedContacts object:nil userInfo:nil];
                        
                        // Save ripple address
                        [[NSUserDefaults standardUserDefaults] setObject:wallet forKey:USERDEFAULTS_RIPPLE_KEY];
                        [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERDEFAULTS_RIPPLE_USERNAME];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        _isLoggedIn = YES;
                        
                        block(nil);
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedIn object:nil userInfo:wallet];
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
                // Failed
                NSLog(@"decrypt_blob failed response");
                NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
                [self logout];
                block(error);
            }
        }
        else {
            // Login blobvault failed
            NSLog(@"%@: login failed. Invalid username or password", self.class.description);
            NSError * error = [NSError errorWithDomain:@"login" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid username or password"}];
            [self logout];
            block(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self cancelTimeout];
        NSLog(@"%@: login failed: %@",self.class.description, error.localizedDescription);
        
//        if (_isAttemptingLogin) {
//            // Keep trying
//            //[self login:username andPassword:password withBlock:block];
//            // After delay
//            [self performSelector:@selector(delayedLogin:) withObject:@[username,password,block] afterDelay:1.0];
//        }
        
        //[self logout];
        block(error);
    }];
    
    // Set custom timeout
    [self cancelTimeout];
    NSDictionary * userinfo = @{@"username": username,
                                @"password": password,
                                @"block": block};
    _networkTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(customTimeout:) userInfo:userinfo repeats:NO];
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
    _isAttemptingLogin = NO;
    _blobData = nil;
    [_accountBalance clearBalances];
    
    [self cancelTimeout];
    [_operationManager.operationQueue cancelAllOperations];
    
    NSArray * accounts = [SSKeychain allAccounts];
    for (NSDictionary * dic in accounts) {
        NSString * username = [dic objectForKey:@"acct"];
        NSError * error;
        [SSKeychain deletePasswordForService:SSKEYCHAIN_SERVICE account:username error:&error];
        //NSLog(@"%@", error.localizedDescription);
        
    }
    
    NSString * wallet = [self rippleWalletAddress];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_RIPPLE_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERDEFAULTS_RIPPLE_USERNAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedOut object:nil userInfo:(NSDictionary*)wallet];
}

@end
