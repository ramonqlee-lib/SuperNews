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
#import "SVWebViewController.h"
#import "PrettyKit.h"
#import "CommandMaster.h"
#import "RMFavoriteUtils.h"
#import "RMArticle.h"
#import "ZJTStatusBarAlertWindow.h"
#import "Flurry.h"
#import "RMBaiduAd.h"
#import "BaiduMobAdView.h"


// toolbar的button编号
#define kZoomInButtonTag 1
#define kZoomOutTag 2
#define kAdd2FavoriteButtonTag 3

#define kCellHeight 76.0f

@interface ScrollPageView()<CommandMasterDelegate>
{
    RMTableView * tableViewWithPullRefreshLoadMoreButton;
    CGPoint mLastContentOffset;
    SVWebViewController* webViewController;
    NSInteger selectedCellPos;
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
    mLastContentOffset = CGPointZero;
    [self freshContentTableAtIndex:0];
}


-(void)commInit{
    if (_contentItems == nil) {
        _contentItems = [[NSMutableArray alloc] init];
    }
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.pagingEnabled = YES;// 这个可以防止跨页面滚动
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
    
//    NSLog(@"setContentOfTables: %d",count);
    for (int i = 0; i < count; i++) {
        
        // 放到合适的位置
        NSInteger index = _contentItems.count;
        RMTableView *vCustomTableView = [[RMTableView alloc] initWithFrame:CGRectMake(320 * index, 0, 320, self.frame.size.height)];
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
    [_scrollView scrollRectToVisible:vMoveRect animated:NO];
    mCurrentPage= aIndex;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)]) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

#pragma mark 返回某个页面的数据集合
-(NSMutableArray*)tableArrayAtIndex:(NSInteger)aIndex
{
    if (_contentItems.count <= aIndex || aIndex < 0) {
        return nil;
    }
    RMTableView *vTableContentView =(RMTableView *)[_contentItems objectAtIndex:aIndex];
    return vTableContentView.tableInfoArray;
}

#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex{
    if (_contentItems.count < aIndex) {
        return;
    }
    RMTableView *vTableContentView =(RMTableView *)[_contentItems objectAtIndex:aIndex];
    [vTableContentView forceToFreshData];
}
-(void)freshContentTableAtIndex:(NSInteger)aIndex withData:(NSArray*)tableArray onDate:(NSDate*)time
{
    if (_contentItems.count < aIndex || aIndex < 0) {
        return;
    }
    
    NSMutableArray* r = [self tableArrayAtIndex:aIndex];
    if (r) {
        [r removeAllObjects];
        [r addObjectsFromArray:tableArray];
        
        RMTableView *vTableContentView =(RMTableView *)[_contentItems objectAtIndex:aIndex];
        vTableContentView.lastUpdated = time?time:[NSDate date];
        [vTableContentView reloadData];
    }
}
-(void)freshContentTableAtIndex:(NSInteger)aIndex withData:(NSArray*)tableArray
{
    [self freshContentTableAtIndex:aIndex withData:tableArray onDate:[NSDate date]];
}
#pragma mark 添加HeaderView
-(void)addLoopScrollowView:(RMTableView *)aTableView {
    tableViewWithPullRefreshLoadMoreButton = aTableView;
    
    //添加一张默认图片
    SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithDict:@{@"image": [NSString stringWithFormat:@"girl%d",2]} tag:-1] autorelease];
    SGFocusImageFrame *bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, -105, 320, 105) delegate:aTableView imageItems:@[item] isAuto:YES];
    aTableView.homeTableView.tableHeaderView = bannerView;
    [bannerView release];
    
}

#pragma mark 改变TableView上面滚动栏的内容
-(void)changeHeaderContentWithCustomTable:(RMTableView *)aTableContent{
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
    //  优化滑动时的效果，可以平滑的出现两个页面
    // 1.超过当前页面边界时，可以出现第二个页面的内容，仅仅加载本地数据，不刷新
    // 2.超过一半时，可以跳转到第二个页面了
    NSLog(@"scrollViewDidScroll offset:(%f,%f)",scrollView.contentOffset.x,scrollView.contentOffset.y);
    // TODO:如何计算下一个页面呢？
    // 左右滑动即可
    NSInteger nextPage = mCurrentPage + ((mLastContentOffset.x<scrollView.contentOffset.x)?1:-1);
    NSLog(@"scrollViewDidScroll lastOffset:(%f,%f)",mLastContentOffset.x,mLastContentOffset.y);
    
    mLastContentOffset = scrollView.contentOffset;
    
    int page = (_scrollView.contentOffset.x+320/2.0) / 320;
    if (mCurrentPage == page) {
        // 页面没切换，但是需要显示相邻页面的本地内容
        if ([_delegate respondsToSelector:@selector(didScrollPageViewUnchangedPage:accrossPage:)] && mNeedUseDelegate) {
            if(nextPage >= _contentItems.count || nextPage < 0)
            {
                NSLog(@"scroll out of bounds,just return");
                return;
            }
            
            [_delegate didScrollPageViewUnchangedPage:mCurrentPage accrossPage:nextPage];
        }
        return;
    }
    
    // 可以认为发生了页面切换
    mCurrentPage= page;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)] && mNeedUseDelegate) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

#pragma mark - CustomTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(UITableView *)aTableView InSection:(NSInteger)section FromView:(RMTableView *)aView{
    return aView.tableInfoArray.count;
}

-(UITableViewCell *)cellForRowInTableView:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    static NSString *vCellIdentify = @"homeCell";
    HomeViewCell *vCell = [aTableView dequeueReusableCellWithIdentifier:vCellIdentify];
    if (vCell == nil) {
        vCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary* dict = [tableViewWithPullRefreshLoadMoreButton.tableInfoArray objectAtIndex:aIndexPath.row];
    // TODO 是一个空白的cell，后续采用广告位填充
    NSString* title = [dict objectForKey:kLowercaseTitleKey];
    NSString* summary = [dict objectForKey:kLowercaseContentKey];
    
    //remove baiduadview
    for (UIView* view in vCell.contentView.subviews) {
        if ([view isKindOfClass:[BaiduMobAdView class]]) {
            [view removeFromSuperview];
        }
    }
    if ( (title && title.length==0) || (summary && summary.length==0)) {
        
        RMBaiduAd* baiduAd = [[RMBaiduAd alloc]init];
        UIView* adView = [baiduAd getBaiduBanner:kDefaultBaiduPublisherId WithAppSpec:kDefaultBaiduAppSpec];
        [vCell.contentView addSubview: adView];
        
        //remove image and textview
        vCell.headerImageView.image = nil;
        vCell.titleLabel.text   = @"";
        vCell.summaryLabel.text = @"";
        
        return vCell;
    }
    
    // 设置数据
    vCell.titleLabel.text = title;
    NSString* htmlString = summary;
    vCell.summaryLabel.text = [htmlString stringByStrippingTags];
    
    NSString* placeHolderImage = (0==aIndexPath.row%2)?kOddTableCellPlaceHolderImage:kEvenTableCellPlaceHolderImage;
    placeHolderImage = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle]resourcePath],placeHolderImage];
    id imageUrl = [dict objectForKey:kImageUrl];
    NSURL* urlForImage = nil;
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]] && [[imageUrl lowercaseString] hasPrefix:kHTTP]) {
        urlForImage = [NSURL URLWithString:imageUrl];
    }
    
    [vCell.headerImageView setImageWithURL:urlForImage imageFile:placeHolderImage];
    return vCell;
}

#pragma mark CustomTableViewDelegate
-(float)heightForRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    if (aIndexPath.row >= tableViewWithPullRefreshLoadMoreButton.tableInfoArray.count) {
        NSLog(@"row: %d",aIndexPath.row);
        return kCellHeight;
    }
    
    NSDictionary* dict = [tableViewWithPullRefreshLoadMoreButton.tableInfoArray objectAtIndex:aIndexPath.row];
    // TODO 是一个空白的cell，后续采用广告位填充
    NSString* title = [dict objectForKey:kLowercaseTitleKey];
    NSString* summary = [dict objectForKey:kLowercaseContentKey];
    
    if ( (title && title.length==0) || (summary && summary.length==0)) {
        return [RMBaiduAd getBaiduBannerSize].height;
    }
    return kCellHeight;
}

-(void)didSelectedRowAthIndexPath:(UITableView *)aTableView IndexPath:(NSIndexPath *)aIndexPath FromView:(RMTableView *)aView
{
    //check before going on
    [aTableView deselectRowAtIndexPath:aIndexPath animated:YES];
    selectedCellPos = aIndexPath.row;
    
    NSDictionary* dict = [tableViewWithPullRefreshLoadMoreButton.tableInfoArray objectAtIndex:aIndexPath.row];
    NSString* content = [dict objectForKey:kLowercaseContentKey];
    NSString* title = [dict objectForKey:kLowercaseTitleKey];
    
    [Flurry logEvent:@"Title" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:title ,@"Title", nil]];
    
    webViewController = [[[SVWebViewController alloc]init]autorelease];
    webViewController.titleString = title;
    webViewController.htmlBody = [content stringByLinkifyingURLs];
    CGRect rc = [UIScreen mainScreen].applicationFrame;
    webViewController.webviewFrame = CGRectMake(0, 0,rc.size.width , rc.size.height-kAppBarMinimalHeight);
    
    UINavigationController* controller = [[UINavigationController alloc]initWithNavigationBarClass:[PrettyNavigationBar class] toolbarClass:nil];
//    UINavigationController* controller = [[[UINavigationController alloc]initWithRootViewController:webViewController]autorelease];
    [controller setViewControllers:@[webViewController]];
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackAction:)];
    
    webViewController.navigationItem.leftBarButtonItem = BackBtn;
    //[self customizeNavBar:controller];
    UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController presentViewController:controller animated:YES completion:(^(void)
     {
         UIButton* zoomInButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomIn"] andTitle:@"放大"];
         zoomInButton.tag = kZoomInButtonTag;
         
         // FIXME: 全局的，修改为局部的，防止在 收藏中 有添加收藏出现
         UIButton* zoomOutButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomOut"] andTitle:@"缩小"];
         zoomOutButton.tag = kZoomOutTag;
         
         UIButton* add2FavoriteButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"saveIcon"] andTitle:@"收藏"];
         add2FavoriteButton.tag = kAdd2FavoriteButtonTag;
         
         CommandMaster* commandMaster = [[[CommandMaster alloc]init]autorelease];
         [commandMaster addButtons:@[zoomInButton,zoomOutButton,add2FavoriteButton] forGroup:@"WebviewToolbar"];
         [commandMaster addToView:webViewController.view andLoadGroup:@"WebviewToolbar"];
         commandMaster.delegate = self;
     })];
}


#pragma CommandMaster delegate
- (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(CommandButton *)selectedButton {
//    NSLog([NSString stringWithFormat:@"index %i of button titled \"%@\"", index, selectedButton.title]);
}

- (void)didSelectButton:(CommandButton *)selectedButton {
//    NSLog([NSString stringWithFormat:@"button titled \"%@\" was selected", selectedButton.title]);
    if(!webViewController)
    {
        return;
    }
    
    switch (selectedButton.tag) {
        case kZoomInButtonTag:
            [webViewController zoomIn];
            break;
        case kZoomOutTag:
            [webViewController zoomOut];
            break;
        case  kAdd2FavoriteButtonTag:
            [self add2FavoriteAction:selectedCellPos];
            break;
        default:
            break;
    }
}

-(void)add2FavoriteAction:(NSInteger)pos
{
    if (pos < 0 || pos >= tableViewWithPullRefreshLoadMoreButton.tableInfoArray.count) {
        return;
    }
    
    NSDictionary* dict = [tableViewWithPullRefreshLoadMoreButton.tableInfoArray objectAtIndex:pos];
    
    RMArticle* article = [[[RMArticle alloc]init]autorelease];
    article.title = [dict objectForKey:kLowercaseTitleKey];
    article.content = [dict objectForKey:kLowercaseContentKey];
    article.url = [dict objectForKey:kImageUrl];
    if (![article.url isKindOfClass:[NSString class]]) {
        article.url = [dict objectForKey:kLowercaseUrl];
    }
    
    [RMFavoriteUtils addFavorite:article];
    
    [[ZJTStatusBarAlertWindow getInstance]showWithString:@"添加到收藏"];
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[ZJTStatusBarAlertWindow getInstance] hide];
    });
}

- (void) customizeNavBar:(UINavigationController*)navi {
    if (!navi) {
        return;
    }
    PrettyNavigationBar *navBar = (PrettyNavigationBar *)navi.navigationBar;
    
    if (!navBar) {
        return;
    }
    
    navBar.topLineColor = [UIColor colorWithHex:0xFF1000];
    navBar.gradientStartColor = [UIColor colorWithHex:0xDD0000];
    navBar.gradientEndColor = [UIColor colorWithHex:0xAA0000];
    navBar.bottomLineColor = [UIColor colorWithHex:0x990000];
    navBar.tintColor = navBar.gradientEndColor;
    navBar.roundedCornerRadius = 0;
}


-(IBAction)BackAction:(id)sender
{
    UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController dismissViewControllerAnimated:YES completion:nil];
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
-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(RMTableView *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    // 加载更多数据，并更新到tableview中(现有数据保留，在其后面加载了新数据)
    if (self.dataDelegate) {
        [self.dataDelegate loadData:complete FromView:aView];
    }

}

// 下拉刷新时的加载
-(void)refreshData:(void(^)())complete FromView:(RMTableView *)aView{
    tableViewWithPullRefreshLoadMoreButton = aView;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.dataDelegate)
        {
            [self.dataDelegate refreshData:complete FromView:aView];
        }
    });
}

- (BOOL)tableViewEgoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view FromView:(RMTableView *)aView{
    return  aView.reloading;
}

@end
