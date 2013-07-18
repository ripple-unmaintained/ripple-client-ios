//
//  WebViewBridgeManager.h
//  Ripple
//
//  Created by Kevin Johnson on 7/17/13.
//  Copyright (c) 2013 OpenCoin Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RippleJSManager : NSObject

+(RippleJSManager*)shared;

-(NSString*)rippleHTML;

-(void)setLog:(UITextView*)textView;

@end
