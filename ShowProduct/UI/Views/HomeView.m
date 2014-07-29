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
#import "jsonKeys.h"
#import "Base64.h"

NSString* kDefaultCategoryTableName = @"Duanzi";
NSString* kDefaultCategoryUrl = @"http://novelists.duapp.com/crawler/refer.php?tableName=DuanZi";
NSUInteger kDefaultCategoryDataLength = 20; //缺省请求的数量
NSUInteger kDefaultCategoryDataIncrement = 20; //每次加载更多请求的数量


#define MENUHEIHT 40

@interface HomeView()
{
    NSArray* titleArray;
    NSArray* urlArray;
    NSArray *vButtonItemArray; // 顶部button相关
    NSInteger currentPageIndex;// 当前所处的页面
    
    TableViewWithPullRefreshLoadMoreButton * myTableView;
    void(^loadMoreComplete)(int); // 加载更多完毕时的数据刷新
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
    
    [self loadCache];
    
    //默认选中第一个button
    [mHorizontalMenu clickButtonAtIndex:0];
}

//    读取缓存，并显示
-(void)loadCache
{
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    NSArray* ret = [HomeViewController restoreArrayFromFile:[HomeViewController categoryDataFilePath:url]];
    if (ret && ret.count) {
        [mScrollPageView freshContentTableAtIndex:currentPageIndex withData:ret];
    }
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
    myTableView = aView;
    NSLog(@"loadMore from offset: %d",aView.tableInfoArray.count);
    
    loadMoreComplete = Block_copy(complete);
    [self loadMore:aView.tableInfoArray.count withNumber:kDefaultCategoryDataIncrement];
}

// 刷新数据
-(void)refreshData:(void(^)())complete FromView:(TableViewWithPullRefreshLoadMoreButton *)aView
{
    myTableView = aView;
    refreshComplete = Block_copy(complete);
    if( [self refesh] )
    {
        return;
    }
    
    NSLog(@"refresh");
    if (complete) {
        complete();
    }
}

#pragma mark 获取频道分类数据
-(BOOL)refesh
{
    if (!urlArray || !urlArray.count || currentPageIndex>=urlArray.count) {
        return NO;
    }
    
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refeshHandler:) name:url object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:url withDictionary:nil];
    return YES;
}

-(void)loadMore:(NSInteger)offset withNumber:(NSInteger)count
{
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    NSString* completeUrl = [NSString stringWithFormat:@"%@&offset=%d&limit=%d",url,offset,count];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadMoreHandler:) name:completeUrl object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:completeUrl withDictionary:nil];
}

// 获取到了更多数据
-(void)loadMoreHandler:(NSNotification*)notification
{
    // : 保存当前的频道数据
    NSInteger pos = 0;
    NSArray* allKeys = [notification.userInfo allKeys];
    if (allKeys.count) {
        id obj = [notification.userInfo objectForKey:[allKeys objectAtIndex:0]];
        if ([obj isKindOfClass:[NSData class]])
        {
            [[NSNotificationCenter defaultCenter]removeObserver:self];
            
            // TODO: 解析数据，追加到列表的底部(需要考虑是否有更多数据的问题，当前返回的数量，当前数组的数量，然后确定是否有更多数据)
            NSMutableArray* ret = [NSMutableArray array];
            [self Json2Array:(NSData*)obj forArray:ret];
            
            pos = ret.count;
            [myTableView.tableInfoArray addObjectsFromArray:ret];
        }
    }
    
    // 加载完毕，通知回调
    if(loadMoreComplete)
    {
        loadMoreComplete(pos);
    }
}

// 刷新数据完毕
-(void)refeshHandler:(NSNotification*)notification
{
    NSString* url = (currentPageIndex<urlArray.count)?[urlArray objectAtIndex:currentPageIndex]:kDefaultCategoryUrl;
    // : 保存当前的频道数据
    id obj = [notification.userInfo objectForKey:url];
    if ([obj isKindOfClass:[NSData class]])
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        // : 解析json数据，并设置到列表中
        [self Json2Array:(NSData*)obj forArray:myTableView.tableInfoArray];
        
        //  数据缓存:见鬼，key带下划线不能保存成功
        NSMutableArray* cacheArray = [NSMutableArray array];
        for (NSDictionary* item in myTableView.tableInfoArray) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:item];
            [dict removeObjectForKey:kWordCount];
            [dict removeObjectForKey:kUrlKey];
//            NSString* leadImageUrl = [dict objectForKey:kLeadImageUrl];
            [dict removeObjectForKey:kLeadImageUrl];
            
            //FIXME: url may be relative url,fix it from server
//            [dict setObject:leadImageUrl forKey:kImageUrl];
            [cacheArray addObject:dict];
        }
        
        NSString* filePath = [HomeViewController categoryDataFilePath:url];
        [HomeViewController saveArray2File:filePath withArray:cacheArray];
        
        /*
        NSArray* ret = [HomeViewController restoreArrayFromFile:filePath];
        NSLog(@"%@",ret);
        */
    }
    // 刷新完毕，通知回调
    if (refreshComplete)
    {
        refreshComplete();
    }
}

// 解析返回的频道数据，设置到数据中，并返回总数量
-(NSInteger)Json2Array:(NSData*)data forArray:(NSMutableArray*)array
{
    if (array) {
        [array removeAllObjects];
    }
    NSInteger count = 0;
    NSError* error;
    id obj = data;
    if ([obj isKindOfClass:[NSData class] ]) {
        id res = [NSJSONSerialization JSONObjectWithData:(NSData*)obj  options:NSJSONReadingMutableContainers error:&error];
        
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            count = [((NSString*)[res objectForKey:@"count"]) intValue];
            res = [res objectForKey:@"data"];
            if (res && [res isKindOfClass:[NSArray class]]) {
                
                if (!array) {
                    return count;
                }
                
                NSArray* items = (NSArray*)res;
                for (NSDictionary* dict in  items) {
                    NSString* base64EncodedString = [NSString stringWithBase64EncodedString:[dict objectForKey:kContentKey]];
                    id tmp = [NSJSONSerialization JSONObjectWithData:[base64EncodedString dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
                    
                    if ([tmp isKindOfClass:[NSDictionary class]]) {
                        [array addObject:tmp];
                    }
                }
                
            }
        }
    }
    return count;
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
