//
//  RPVaultClient.m
//  Ripple
//
//  Created by Kevin Johnson on 7/18/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import "RPVaultClient.h"
#import "AFJSONRequestOperation.h"

@implementation RPVaultClient

+(RPVaultClient *)sharedClient {
    static RPVaultClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:GLOBAL_BLOB_VAULT]];
    });
    return _sharedClient;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    //[self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    return self;
    
}

@end
