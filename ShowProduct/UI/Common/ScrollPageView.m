//
//  ScrollPageView.m
//  ShowProduct
//
//  Created by lin on 14-5-23.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "ScrollPageView.h"
#import "HomeViewCell.h"
#import "jsonKeys.h"
#import "NSString+HTML.h"
#import "UIImageView+WebCache.h"

@interface ScrollPageView()
{
    TableViewWithPullRefreshLoadMoreButton * tableViewWithPullRefreshLoadMoreButton;
}
@end

@implementation ScrollPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mNeedUseDelegate = YES;
        [self commInit];
    }
    return self;
}

-(void)initData{
    [self freshContentTableAtIndex:0];
}


-(void)commInit{
    if (_contentItems == nil) {
        _contentItems = [[NSMutableArray alloc] init];
    }
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        NSLog(@"ScrollViewFrame:(%f,%f)",self.frame.size.width,self.frame.size.height);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    [self addSubview:_scrollView];
}

-(void)dealloc{
    [self releaseObjs];
    [super dealloc];
}

-(void)releaseObjs
{
    [_contentItems removeAllObjects];
    [_contentItems release];
    _contentItems= nil;
    
    [_scrollView removeFromSuperview];
    [_scrollView release];
    _scrollView = nil;
}
#pragma mark - 其他辅助功能
#pragma mark 添加ScrollowViewd的ContentView
-(void)setContentOfTables:(NSInteger)aNumerOfTables{
    [_scrollView setContentSize:CGSizeMake(320 * aNumerOfTables, self.frame.size.height)];
    
    NSInteger count = (aNumerOfTables - _contentItems.count);
    if (count < 0) {
        //keep extra views, re-use them if posssible later
        NSLog(@"setContentOfTables for reuse: %d",-count);
        return;
    }
    
    NSLog(@"setContentOfTables: %d",count);
    for (int i = 0; i < count; i++) {
        TableViewWithPullRefreshLoadMoreButton *vCustomTableView = [[TableViewWithPullRefreshLoadMoreButton alloc] initWithFrame:CGRectMake(320 * i, 0, 320, self.frame.size.height)];
        vCustomTableView.delegate = self;
        vCustomTableView.dataSource = self;
        
        //        [self addLoopScrollowView:vCustomTableView];// 为table添加嵌套HeadderView
        [_scrollView addSubview:vCustomTableView];
        [_contentItems addObject:vCustomTableView];
        [vCustomTableView release];
    }
}

#pragma mark 移动ScrollView到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex{
    mNeedUseDelegate = NO;
    CGRect vMoveRect = CGRectMake(self.frame.size.width * aIndex, 0, self.frame.size.width, self.frame.size.width);
    [_scrollView scrollRectToVisible:vMoveRect animated:YES];
    mCurrentPage= aIndex;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)]) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

#pragma mark 返回某个页面的数据集合
-(NSMutableArray*)tableArrayAtIndex:(NSInteger)aIndex
{
    if (_contentItems.count < aIndex) {
        return nil;
    }
    TableViewWithPullRefreshLoadMoreButton *vTableContentView =(TableViewWithPullRefreshLoadMoreButton *)[_contentItems objectAtIndex:aIndex];
    return vTableContentView.tableInfoArray;
}

#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex{
    if (_contentItems.count < aIndex) {
        return;
    }
    TableViewWithPullRefreshLoadMoreButton *vTableContentView =(TableViewWithPullRefreshLoadMoreButton *)[_contentItems objectAtIndex:aIndex];
    [vTableContentView forceToFreshData];
}
-(void)freshContentTableAtIndex:(NSInteger)aIndex withData:(NSArray*)tableArray
{
    NSMutableArray* r = [self tableArrayAtIndex:aIndex];
    if (r) {
        [r removeAllObjects];
        [r addObjectsFromArray:tableArray];
        [self freshContentTableAtIndex:aIndex];
    }
}
#pragma mark 添加HeaderView
-(void)addLoopScrollowView:(TableViewWithPullRefreshLoadMoreButton *)aTableView {
    tableViewWithPullRefreshLoadMoreButton = aTableView;
    
    //添加一张默认图片
    SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithDict:@{@"image": [NSString stringWithFormat:@"girl%d",2]} tag:-1] autorelease];
    SGFocusImageFrame *bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, -105, 320, 105) delegate:aTableView imageItems:@[item] isAuto:YES];
    aTableView.homeTableView.tableHeaderView = bannerView;
    [bannerView release];
    
}

#pragma mark 改变TableView上面滚动栏的内容
-(void)changeHeaderContentWithCustomTable:(TableViewWithPullRefreshLoadMoreButton *)aTableContent{
    int length = 4;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0 ; i < length; i++)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"title%d",i],@"title" ,
                              [NSString stringWithFormat:@"girl%d",(i + 1)],@"image",
                              nil];
        [tempArray addObject:dict];
    }
    
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
    //添加最后一张图 用于循环
    if (length > 1)
    {
        NSDictionary *dict = [tempArray objectAtIndex:length-1];
        SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithDict:dict tag:-1] autorelease];
        [itemArray addObject:item];
    }
    for (int i = 0; i < length; i++)
    {
        NSDictionary *dict = [tempArray objectAtIndex:i];
        SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithDict:dict tag:i] autorelease];
        [itemArray addObject:item];
        
    }
    //添加第一张图 用于循环
    if (length >1)
    {
        NSDictionary *dict = [tempArray objectAtIndex:0];
        SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithDict:dict tag:length] autorelease];
        [itemArray addObject:item];
    }
    
    SGFocusImageFrame *vFocusFrame = (SGFocusImageFrame *)aTableContent.homeTableView.tableHeaderView;
    if( vFocusFrame )
    {
        [vFocusFrame changeImageViewsContent:itemArray];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    mNeedUseDelegate = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (_scrollView.contentOffset.x+320/2.0) / 320;
    if (mCurrentPage == page) {
        return;
    }
    mCurrentPage= page;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)] && mNeedUseDelegate) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        //        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        //        targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        //        [self moveToTargetPosition:targetX];
    }
    
    
}

#pragma mark - CustomTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(UITableView *)aTableView InSection:(NSInteger)section FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    return aView.tableInfoArray.count;
}

-(UITableViewCell *)cellForRowInTableView:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    static NSString *vCellIdentify = @"homeCell";
    HomeViewCell *vCell = [aTableView dequeueReusableCellWithIdentifier:vCellIdentify];
    if (vCell == nil) {
        vCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary* dict = [tableViewWithPullRefreshLoadMoreButton.tableInfoArray objectAtIndex:aIndexPath.row];
    
    id imageUrl = [dict objectForKey:kImageUrl];
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]] && [[imageUrl lowercaseString] hasPrefix:kHTTP]) {
        NSLog(@"icon image: %@",imageUrl);
        [vCell.headerImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:kTableCellPlaceHolderImage]];
    }
    vCell.titleLabel.text = [dict objectForKey:kLowercaseTitleKey];
    NSString* htmlString = [dict objectForKey:kLowercaseContentKey];
    
    vCell.summaryLabel.text = [htmlString stringByStrippingTags];
    
    return vCell;
}

#pragma mark CustomTableViewDelegate
-(float)heightForRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    HomeViewCell *vCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewCell" owner:self options:nil] lastObject];
    return vCell.frame.size.height;
}

-(void)didSelectedRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
}

//更新tableview数据
-(void)updateTableViewDataOnly:(NSArray*)data
{
    if (!tableViewWithPullRefreshLoadMoreButton || !data) {
        return;
    }
    [tableViewWithPullRefreshLoadMoreButton.tableInfoArray removeAllObjects];
    
    [tableViewWithPullRefreshLoadMoreButton.tableInfoArray addObjectsFromArray:data];
}

// 加载更多时的数据加载
-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    // 加载更多数据，并更新到tableview中(现有数据保留，在其后面加载了新数据)
    if (self.dataDelegate) {
        [self.dataDelegate loadData:complete FromView:aView];
    }
    
    /*
     NSMutableArray* data = [NSMutableArray arrayWithArray:aView.tableInfoArray];
    for (int i = 0; i < 4; i++) {
        [data  addObject:@"0"];
    }
    [self updateTableViewDataOnly:data];
    
    // 数据更新完毕，该刷新view了
    if (complete) {
        complete(4);
    }
     */
}

// 下拉刷新时的加载
-(void)refreshData:(void(^)())complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (self.dataDelegate)
        {
            [self.dataDelegate refreshData:complete FromView:aView];
        }
        
        /*
        // 全新的数据集
        NSMutableArray* data = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            [data  addObject:@"0"];
        }
        [self updateTableViewDataOnly:data];
        
        //改变header显示图片
        [self changeHeaderContentWithCustomTable:aView];
        if (complete) {
            complete();
        }
         */
    });
}

- (BOOL)tableViewEgoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    return  aView.reloading;
}


@end
