//
//  CustomTableView.h
//  ShowProduct
//
//  Created by klbest1 on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@class TableViewWithPullRefreshLoadMoreButton;

@protocol TableViewWithPullRefreshLoadMoreButtonDelegate <NSObject>

@optional;
-(float)heightForRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;

-(void)didSelectedRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;

-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;

-(void)refreshData:(void(^)())complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;
@end


@protocol TableViewWithPullRefreshLoadMoreButtonDataSource <NSObject>
@required;
-(NSInteger)numberOfRowsInTableView:(UITableView *)aTableView InSection:(NSInteger)section FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;
-(UITableViewCell *)cellForRowInTableView:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView;

@end

@interface TableViewWithPullRefreshLoadMoreButton : UIView<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,SGFocusImageFrameDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    NSInteger     mRowCount;
}
//  Reloading var should really be your tableviews datasource
//  Putting it here for demo purposes
@property (nonatomic,assign) BOOL reloading;

@property (nonatomic,retain) UITableView *homeTableView;
@property (nonatomic,retain) NSMutableArray *tableInfoArray;
@property (nonatomic,assign) id<TableViewWithPullRefreshLoadMoreButtonDataSource> dataSource;
@property (nonatomic,assign) id<TableViewWithPullRefreshLoadMoreButtonDelegate>  delegate;

- (void)reloadTableViewDataSource;
#pragma mark 强制列表刷新
-(void)forceToFreshData;

@end
