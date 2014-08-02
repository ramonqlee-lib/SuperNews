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
#import "RMTableView.h"

@interface ScrollViewWithTopBar : UIView<HorizontalMenuDelegate,ScrollPageViewDelegate,Notifier,TableViewWithPullRefreshLoadMoreButtonDelegate>
{
    MenuHrizontal *mHorizontalMenu;
    ScrollPageView *mScrollPageView;
}
@property(nonatomic,assign)CGFloat topBarHeight;
@property(nonatomic,assign)CGFloat topBarRightPadding;
@end
