//
//  RMViewController+Aux.h
//  MessageGuru
//
//  Created by ramonqlee on 2/26/14.
//  Copyright (c) 2014 iDreems. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )

@interface UIViewController(RMViewController_Aux)

-(UIView*)clientView;

@end
