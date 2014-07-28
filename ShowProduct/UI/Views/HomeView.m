//
//  HomeView.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "HomeView.h"
#import "HomeViewCell.h"
#import "HTTPHelper.h"

NSString* kDefaultCategoryTableName = @"Duanzi";
NSString* kDefaultCategoryUrl = @"http://novelists.duapp.com/crawler/refer.php?tableName=DuanZi";
NSUInteger kDefaultCategoryDataLength = 20; //缺省请求的数量
NSUInteger kDefaultCategoryDataIncrement = 20; //每次加载更多请求的数量
NSString* kContentKey = @"Content";
NSString* kUrlKey = @"Url";

#define MENUHEIHT 40

@interface HomeView()
{
    NSArray* titleArray;
    NSArray* urlArray;
    NSArray *vButtonItemArray; // 顶部button相关
    NSInteger currentPageIndex;// 当前所处的页面
    
    TableViewWithPullRefreshLoadMoreButton * refreshLoadMoreTableView;
    void(^loadMoreComplete)(int count); // 加载更多完毕时的数据刷新
    void(^refreshComplete)(); // 重新获取数据完成的数据刷新
}
@end
@implementation HomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commInit];
    }
    return self;
}

#pragma mark UI初始化
-(void)commInit{
    // TODO:此处需要读取缓存数据，进行展示
    // 缓存的频道列表和频道数据
    vButtonItemArray = @[@{NOMALKEY: @"normal.png",
                           HEIGHTKEY:@"helight.png",
                           TITLEKEY:@"头条",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal.png",
                           HEIGHTKEY:@"helight.png",
                           TITLEKEY:@"推荐",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"娱乐",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥1",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥2",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥3ß",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           }
                         ];
    [self resetContent];
}

-(void)resetContent
{
    if (mHorizontalMenu == nil) {
        mHorizontalMenu = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, MENUHEIHT) ButtonItems:vButtonItemArray];
        mHorizontalMenu.delegate = self;
        [self addSubview:mHorizontalMenu];
    }
    else
    {
        [mHorizontalMenu setButtonItems:vButtonItemArray];
    }
    
    //初始化滑动列表
    if (mScrollPageView == nil) {
        mScrollPageView = [[ScrollPageView alloc] initWithFrame:CGRectMake(0, MENUHEIHT, self.frame.size.width, self.frame.size.height - MENUHEIHT)];
        mScrollPageView.delegate = self;
        mScrollPageView.dataDelegate = self;
        [self addSubview:mScrollPageView];
    }
    
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    //默认选中第一个button
    [mHorizontalMenu clickButtonAtIndex:0];
}
#pragma mark 内存相关
-(void)dealloc{
    [mHorizontalMenu release],mHorizontalMenu = nil;
    [mScrollPageView release],mScrollPageView = nil;
    [super dealloc];
}

#pragma mark - 其他辅助功能
#pragma mark MenuHrizontalDelegate
-(void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex{
    NSLog(@"第%d个Button点击了",aIndex);
    [mScrollPageView moveScrollowViewAthIndex:aIndex];
}

#pragma mark ScrollPageViewDelegate
-(void)didScrollPageViewChangedPage:(NSInteger)aPage{
    NSLog(@"CurrentPage:%d",aPage);
    [mHorizontalMenu changeButtonStateAtIndex:aPage];

    // TODO 发起数据请求，首先从本地存储读取，然后从网络获取
    currentPageIndex= aPage;
    //刷新当页数据
    [mScrollPageView freshContentTableAtIndex:aPage];
}

// 加载更多时的数据加载
#pragma refresh & load more delegate
-(void)loadData:(void(^)(int aAddedRowCount))complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView{
    // 联网获取数据，然后刷新本地数据
    refreshLoadMoreTableView = aView;
    //    mScrollPageView tableArrayAtIndex:<#(NSInteger)#>
    NSLog(@"loadMore from offset: %d",aView.tableInfoArray.count);
    
    loadMoreComplete = complete;
    [loadMoreComplete copy];
    [self retrieveCategoryDataLoadMore:aView.tableInfoArray.count withNumber:kDefaultCategoryDataIncrement];
}

// 刷新数据
-(void)refreshData:(void(^)())complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView
{
    refreshLoadMoreTableView = aView;
    refreshComplete = complete;
    [refreshComplete copy];
    if( [self retrieveCategoryDataRefesh] )
    {
        return;
    }
    
    NSLog(@"refresh");
    if (complete) {
        complete();
    }
}

#pragma mark 获取频道分类数据
-(BOOL)retrieveCategoryDataRefesh
{
    if (!urlArray || !urlArray.count || currentPageIndex>=urlArray.count) {
        return NO;
    }
    
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(categoryDataRefeshHandler:) name:url object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:url withDictionary:nil];
    return YES;
}
-(void)retrieveCategoryDataLoadMore:(NSInteger)offset withNumber:(NSInteger)count
{
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    NSString* completeUrl = [NSString stringWithFormat:@"%@?offset=%d&limit=%d",url,offset,count];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(categoryDataLoadMoreHandler:) name:completeUrl object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:url withDictionary:nil];
}

// 获取到了更多数据
-(void)categoryDataLoadMoreHandler:(NSNotification*)notification
{
    //这个url不对，想其他办法，比如enumerate
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    // : 保存当前的频道数据
    id obj = [notification.userInfo objectForKey:url];
    if ([obj isKindOfClass:[NSData class]])
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        
        // TODO 加载完毕，通知回调
        if(loadMoreComplete)
        {
            loadMoreComplete(3);
            [loadMoreComplete release];
        }
    }
}

// 刷新数据完毕
-(void)categoryDataRefeshHandler:(NSNotification*)notification
{
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    // : 保存当前的频道数据
    id obj = [notification.userInfo objectForKey:url];
    if ([obj isKindOfClass:[NSData class]])
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        // TODO 刷新完毕，通知回调
        if (refreshComplete)
        {
            refreshComplete();
            [refreshComplete release];
        }
    }
}

#pragma mark Notifier impl
-(void) onChange:(NSObject*) object
{
    // [titleArray,urlArray]
    // 更新主页的频道列表
    // object中包含频道列表数据
    // TODO:: 刷新第一个页面的数据（自上次更新后，是否需要更新）
    if (![object isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray* r = (NSArray*)object;
    if ( !r  || r.count != 2) {
        return;
    }
    
    titleArray = [[NSArray alloc]initWithArray:[r objectAtIndex:0]];
    urlArray = [[NSArray alloc]initWithArray:[r objectAtIndex:1]];
    
    if ( !titleArray || 0 == titleArray.count || !urlArray || 0 == urlArray.count ) {
        return;
    }
    
    NSMutableArray* itemsArray = [NSMutableArray arrayWithCapacity:titleArray.count];
    vButtonItemArray = itemsArray;
    for (NSString* val in titleArray) {
        // FIXME: 动态计算文本所占宽度.目前是简单的字符数定宽推断法
        [itemsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"normal.png",NOMALKEY,
                               @"helight.png",HEIGHTKEY,
                               val,TITLEKEY,
                               [NSNumber numberWithFloat:val.length*20],TITLEWIDTH, nil]];
    }
    
    [self resetContent];
}

@end
