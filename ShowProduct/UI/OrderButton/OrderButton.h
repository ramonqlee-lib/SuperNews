//
//  OrderButton.h
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderButton : UIButton

@property (nonatomic,retain) UIViewController * vc;
@property (nonatomic,retain) NSArray * topTitleArr;
@property (nonatomic,retain) NSArray * topUrlStringArr;

@property (nonatomic,retain)NSArray * bottomTitleArr;
@property (nonatomic,retain)NSArray * bottomUrlStringArr;

+ (id)orderButtonWithViewController:(UIViewController *)vc titleArr:(NSArray *)titleArr urlStringArr:(NSArray *)urlStringArr bottomTitleArr:(NSArray *)bottomTitleArr bottomUrlStringArr:(NSArray *)bottomUrlStringArr;
@end
