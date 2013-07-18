//
//  KJObjectSerializer.h
//  KJObjectSerialize
//
//  Created by Kevin Johnson on 6/20/13.
//  Copyright (c) 2013 KevinEJohn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (KJObjectSerializer)

-(NSMutableDictionary *)getDictionary;
-(void)setDictionary:(NSDictionary*)dictionary;

@end
