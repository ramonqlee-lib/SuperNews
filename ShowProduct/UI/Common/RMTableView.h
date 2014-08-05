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

@class RMTableView;

@protocol TableViewWithPullRefreshLoadMoreButtonDelegate <NSObject>

@optional;
-(float)heightForRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView;

-(void)didSelectedRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView;

-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(RMTableView *)aView;

-(void)refreshData:(void(^)())complete FromView:(RMTableView *)aView;
@end


@protocol TableViewWithPullRefreshLoadMoreButtonDataSource <NSObject>
@required;
-(NSInteger)numberOfRowsInTableView:(UITableView *)aTableView InSection:(NSInteger)section FromView:(RMTableView *)aView;
-(UITableViewCell *)cellForRowInTableView:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView;

@end

@interface RMTableView : UIView<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,SGFocusImageFrameDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    NSInteger     mRowCount;
}
//  Reloading var should really be your tableviews datasource
//  Putting it here for demo purposes
@property (nonatomic,assign) BOOL reloading;
@property (nonatomic,retain) NSDate* lastUpdated;

@property (nonatomic,retain) UITableView *homeTableView;
@property (nonatomic,retain) NSMutableArray *tableInfoArray;
@property (nonatomic,assign) id<TableViewWithPullRefreshLoadMoreButtonDataSource> dataSource;
@property (nonatomic,assign) id<TableViewWithPullRefreshLoadMoreButtonDelegate>  delegate;

- (void)reloadTableViewDataSource;
#pragma mark 强制列表刷新
-(void)forceToFreshData;

-(void)reloadData;// 类似tableview更新数据后的，刷新请求
@end
