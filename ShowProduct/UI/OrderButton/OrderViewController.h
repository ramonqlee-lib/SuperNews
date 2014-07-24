//
//  OrderViewController.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderViewController : UIViewController

@property (nonatomic,retain)UILabel * titleLabel;
@property (nonatomic,retain)UILabel * titleLabel2;

//我的订阅
@property (nonatomic,retain)NSArray * topTitleArr;
@property (nonatomic,retain)NSArray * topUrlStringArr;

//更多
@property (nonatomic,retain)NSArray * bottomTitleArr;
@property (nonatomic,retain)NSArray * bottomUrlStringArr;

//@property (nonatomic,retain)UIButton * backButton;

-(NSArray*)topViewModels;
-(NSArray*)bottomViewModels;
@end
