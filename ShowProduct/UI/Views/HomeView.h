//
//  HomeView.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"
#import "ScrollPageView.h"
#import "HomeViewController.h"

@interface HomeView : UIView<HorizontalMenuDelegate,ScrollPageViewDelegate,Notifier>
{
    MenuHrizontal *mHorizontalMenu;
    ScrollPageView *mScrollPageView;
}


@end
