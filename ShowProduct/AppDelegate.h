//
//  AppDelegate.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>

#define UmengAppkey @"5211818556240bc9ee01db2f"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *mNavigationController;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;
@end
