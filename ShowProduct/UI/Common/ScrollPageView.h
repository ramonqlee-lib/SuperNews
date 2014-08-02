//
//  ScrollPageView.h
//  ShowProduct
//
//  Created by lin on 14-5-23.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMTableView.h"


@protocol ScrollPageViewDelegate <NSObject>
-(void)didScrollPageViewChangedPage:(NSInteger)aPage;
@end

@interface ScrollPageView : UIView<UIScrollViewDelegate,TableViewWithPullRefreshLoadMoreButtonDataSource,TableViewWithPullRefreshLoadMoreButtonDelegate>
{
    NSInteger mCurrentPage;
    BOOL mNeedUseDelegate;
}
@property (nonatomic,retain) UIScrollView *scrollView;

@property (nonatomic,retain) NSMutableArray *contentItems;

@property (nonatomic,assign) id<ScrollPageViewDelegate> delegate;

@property (nonatomic,assign) id<TableViewWithPullRefreshLoadMoreButtonDelegate> dataDelegate;

#pragma mark 添加ScrollowViewd的ContentView
-(void)setContentOfTables:(NSInteger)aNumerOfTables;

#pragma mark 滑动到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex;

#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex;
-(void)freshContentTableAtIndex:(NSInteger)aIndex withData:(NSArray*)tableArray;

#pragma mark 改变TableView上面滚动栏的内容
-(void)changeHeaderContentWithCustomTable:(RMTableView *)aTableContent;

#pragma mark 返回某个页面的数据集合
-(NSMutableArray*)tableArrayAtIndex:(NSInteger)aIndex;
@end
