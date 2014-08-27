//
//  RMWebViewDelegate.h
//  SuperNews
//
//  Created by ramonqlee on 8/28/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHelper.h"

@interface RMWebViewDelegate : NSObject

Decl_Singleton(RMWebViewDelegate)

-(void)presentInWebView:(NSDictionary*)dict inViewContrller:(UIViewController*)vController;

@end
