//
//  OrderViewController.m
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "OrderViewController.h"
#import "TouchViewModel.h"
#import "TouchView.h"
#import "Header.h"


@interface OrderViewController ()
{
    NSArray * topModelArray;
    NSArray * bottomModelArray;
    
    NSMutableArray * topViewArr;
    NSMutableArray * bottomViewArr;
}
@end

@implementation OrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // 需要设置数据，分为上部和下部两个区域
    topModelArray = [self touchModelConstructor:self.topTitleArr withUrlArray:self.topUrlStringArr];
    bottomModelArray =  [self touchModelConstructor:self.bottomTitleArr withUrlArray:self.bottomUrlStringArr];
    
    topViewArr = [[NSMutableArray alloc] init];
    bottomViewArr = [[NSMutableArray alloc] init];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 320, 40)];
    _titleLabel.text = @"我的订阅:点击不再订阅";
    [_titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:[UIColor colorWithRed:187/255.0 green:1/255.0 blue:1/255.0 alpha:1.0]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_titleLabel];

    _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, KTableStartPointY + KButtonHeight * ([self array2StartY] - 1) + 22, 320, 20)];
    _titleLabel2.text = @"更多: 点击加入 我的订阅";
    [_titleLabel2 setFont:[UIFont systemFontOfSize:10]];
    [_titleLabel2 setTextAlignment:NSTextAlignmentCenter];
//    [_titleLabel2 setTextColor:[UIColor grayColor]];
    [_titleLabel2 setTextColor:[UIColor colorWithRed:187/255.0 green:1/255.0 blue:1/255.0 alpha:1.0]];
    [_titleLabel2 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_titleLabel2];
    
    // TODO 上部和下部均支持scrollview
    for (int i = 0; i < topModelArray.count; i++) {
        TouchView * touchView = [[TouchView alloc] initWithFrame:CGRectMake(KTableStartPointX + KButtonWidth * (i%kMaxItemPerLine), KTableStartPointY + KButtonHeight * (i/kMaxItemPerLine), KButtonWidth, KButtonHeight)];
        [touchView setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
        
        [topViewArr addObject:touchView];
        [touchView release];
        touchView->_array = topViewArr;
        if (i == 0) {
            [touchView.label setTextColor:[UIColor colorWithRed:187/255.0 green:1/255.0 blue:1/255.0 alpha:1.0]];
        }
        else{
            [touchView.label setTextColor:[UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]];
        }
        touchView.label.text = [[topModelArray objectAtIndex:i] title];
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_topViewsArr = topViewArr;
        touchView->_bottomViewsArr = bottomViewArr;
        [touchView setTouchViewModel:[topModelArray objectAtIndex:i]];
        
        [self.view addSubview:touchView];
    }
    
    
    for (int i = 0; i < bottomModelArray.count; i++) {
        TouchView * touchView = [[TouchView alloc] initWithFrame:CGRectMake(KTableStartPointX + KButtonWidth * (i%kMaxItemPerLine), KTableStartPointY + [self array2StartY] * KButtonHeight + KButtonHeight * (i/kMaxItemPerLine), KButtonWidth, KButtonHeight)];
        
        [touchView setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
        
        [bottomViewArr addObject:touchView];
        touchView->_array = bottomViewArr;
        
        touchView.label.text = [[bottomModelArray objectAtIndex:i] title];
        [touchView.label setTextColor:[UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]];
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_topViewsArr = topViewArr;
        touchView->_bottomViewsArr = bottomViewArr;
        [touchView setTouchViewModel:[bottomModelArray objectAtIndex:i]];
        
        [self.view addSubview:touchView];
        [touchView release];
    }
}

- (void)dealloc{
    [_topTitleArr release];
    [_topUrlStringArr release];
    [_titleLabel2 release];
    [_titleLabel release];
    [topViewArr release];
    [bottomViewArr release];
    [super dealloc];
}


- (unsigned long )array2StartY{
    unsigned long y = 0;
    
    y = topModelArray.count/kMaxItemPerLine + 2;
    if (topModelArray.count%kMaxItemPerLine == 0) {
        y -= 1;
    }
    return y;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSArray*) touchModelConstructor:(NSArray*)titleArray withUrlArray:(NSArray*)urlArray
{
    NSMutableArray * mutArr = [NSMutableArray array];
    for (int i = 0; i < [titleArray count]; i++) {
        NSString * title = [titleArray objectAtIndex:i];
        NSString * urlString = [urlArray objectAtIndex:i];
        TouchViewModel * touchViewModel = [[TouchViewModel alloc] initWithTitle:title urlString:urlString];
        [mutArr addObject:touchViewModel];
        [touchViewModel release];
    }
    return mutArr;
}
-(NSArray*)topViewModels
{
    NSMutableArray * modelArr = [NSMutableArray array];
    
    for (TouchView * touchView in topViewArr) {
        [modelArr addObject:touchView.touchViewModel];
    }
    return modelArr;
}

-(NSArray*)bottomViewModels
{
    NSMutableArray * modelArr = [NSMutableArray array];
    
    for (TouchView * touchView in bottomViewArr) {
        [modelArr addObject:touchView.touchViewModel];
    }
    return modelArr;
}
@end
