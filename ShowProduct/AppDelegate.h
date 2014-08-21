//
//  AppDelegate.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFlurryAPIKey @"VD57WGD28683BPMSQ9X9"
#define UmengAppkey @"53f672a5fd98c5922101a575"
#define kAppStoreUrl @"https://itunes.apple.com/us/app/qu-wei-li-shi/id905734176?ls=1&mt=8"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *mNavigationController;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;
@end
