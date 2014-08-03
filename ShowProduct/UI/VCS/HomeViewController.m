//
//  HomeVC.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "HomeViewController.h"
#import "ScrollViewWithTopBar.h"
#import "Macros.h"
#import "OrderViewController.h"
#import "OrderButton.h"
#import "TouchView.h"
#import "Header.h"
#import "HTTPHelper.h"
#import "TouchViewModel.h"
#import "ASIDownloadCache.h"
#import "RMViewController+Aux.h"
#import "CommonHelper.h"
#import "PrettyKit.h"

#define MENUHEIGHT 40

NSString* kAppSettingUrl = @"http://novelists.duapp.com/crawler/category.php";//?column=ZhongYi";
NSUInteger kDefaultCategoryCount = 4;// 用户没有订阅时的推荐订阅数目
NSString* kCategoryTitleKey = @"title";
NSString* kCategoryUrlKey = @"url";

@interface HomeViewController ()
{
    ScrollViewWithTopBar *mHomeView;
    NSArray* allCategories;// FIXME:将数据缓存到本地，不再内存中保留，降低内存占用
    NSMutableArray* mySubscriptionDataObservers;
}

@end

@implementation HomeViewController

//-----------------------------标准方法------------------
- (id) initWithNibName:(NSString *)aNibName bundle:(NSBundle *)aBuddle {
    self = [super initWithNibName:aNibName bundle:aBuddle];
    if (self != nil) {
    }
    return self;
}

-(void)viewDidLoad{
    [self initCommonData];
    [self initView];
}

//初始化数据
-(void)initCommonData{
    [self retrieveAppSettings];
    if (! mySubscriptionDataObservers ) {
        mySubscriptionDataObservers = [[NSMutableArray alloc ]initWithCapacity:1];
    }
}

#if __has_feature(objc_arc)
#else
// dealloc函数
- (void) dealloc {
    [mHomeView release];
    [super dealloc];
}
#endif

// 初始View
- (void) initView {
    
    if (IS_IOS7) {
        self.edgesForExtendedLayout =UIRectEdgeNone ;
    }
    
    // set app name
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    self.title = appName;
    
    //contentView大小设置
    int vWidth = (int)([UIScreen mainScreen].bounds.size.width);
    int vHeight = (int)([UIScreen mainScreen].bounds.size.height);
    CGRect vViewRect = CGRectMake(0, 0, vWidth, vHeight -44 -20);
    UIView *vContentView = [[UIView alloc] initWithFrame:vViewRect];
    if (mHomeView == nil) {
        mHomeView = [[ScrollViewWithTopBar alloc] initWithFrame:vContentView.frame];
        mHomeView.topBarHeight = MENUHEIGHT;
        mHomeView.topBarRightPadding = [self orderButtonReframed].frame.size.width;
        [mySubscriptionDataObservers addObject:mHomeView];
    }
    [vContentView addSubview:mHomeView];
    
    self.view = vContentView;
    [vContentView release];
    
    [self notifySubscriptionChange];
}

#pragma mark 获取频道分类数据
-(void)retrieveAppSettings
{
    // : 联网获取app启动参数
    // 1.频道列表
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"LiShi",@"column", nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appCategoriesHandler:) name:kAppSettingUrl object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:kAppSettingUrl withDictionary:dict];
}

// 应用分类数据返回的处理
-(void)appCategoriesHandler:(NSNotification*)notification
{
    // : 保存全部的频道列表
    id obj = [notification.userInfo objectForKey:kAppSettingUrl];
    if ([obj isKindOfClass:[NSData class]])
    {
        if( allCategories )
        {
            [allCategories release];
        }
        
        allCategories = [[NSMutableArray alloc]initWithArray:[HomeViewController Json2Array:(NSData*)obj] ];
        //FIXME 测试保存和恢复（此部分数据将用于频道的自定义功能）
        /*
        NSString* file = [HomeViewController categoryFilePath];
         [HomeViewController saveArray2File:file withArray:allCategories];
         allCategories = nil;
         allCategories = [HomeViewController restoreArrayFromFile:file];
        */
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        
        // 通知频道数据发生了变化
        [self notifySubscriptionChange ];
    }
    
    OrderButton* orderButton = [self orderButtonReframed];
    
    [orderButton addTarget:self action:@selector(orderViewOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:orderButton];
}

-(OrderButton*)orderButtonReframed
{
    OrderButton* orderButton = [self orderButton];
    
    UIColor* color = [UIColor lightGrayColor];//[UIColor colorWithRed:(float)0x53/255.0 green:(float)0xa4/255.0 blue:(float)0xde/255.0 alpha:1.0];
    UIImage* image = [CommonHelper createImageWithColor:color];
    [orderButton setBackgroundImage:image forState:UIControlStateNormal];
    
    // 显示在靠右边的clientview处
    CGRect frame = orderButton.frame;
    CGFloat scale = frame.size.width/frame.size.height;
    frame.size.width = MENUHEIGHT*scale;
    frame.size.height = MENUHEIGHT;// 参考上部滚动条的高度
    
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    frame.origin.y = 0;
    orderButton.frame = frame;

    return orderButton;
}

#pragma mark category Button
// 获取频道按钮，并设置数据
-(OrderButton*)orderButton
{
    NSMutableArray* mySubscriptionCategoriesTitleArray = [NSMutableArray array];
    NSMutableArray* mySubscriptionCategoriesUrlArray = [NSMutableArray array];
    NSMutableArray* moreCategoriesTitleArray = [NSMutableArray array];
    NSMutableArray* moreCategoriesUrlArray = [NSMutableArray array];
    
    [self retrieveOrderButtonArray:mySubscriptionCategoriesTitleArray urlStringArr:mySubscriptionCategoriesUrlArray bottomTitleArr:moreCategoriesTitleArray bottomUrlStringArr:moreCategoriesUrlArray];
    
   return [OrderButton orderButtonWithViewController:self titleArr:mySubscriptionCategoriesTitleArray urlStringArr:mySubscriptionCategoriesUrlArray bottomTitleArr:moreCategoriesTitleArray bottomUrlStringArr:moreCategoriesUrlArray];
}

// 刷新频道数据
-(void)refreshOrderButton:(OrderButton*)orderButton
{
    if (!orderButton) {
        return;
    }
    
    NSMutableArray* mySubscriptionCategoriesTitleArray = [NSMutableArray array];
    NSMutableArray* mySubscriptionCategoriesUrlArray = [NSMutableArray array];
    NSMutableArray* moreCategoriesTitleArray = [NSMutableArray array];
    NSMutableArray* moreCategoriesUrlArray = [NSMutableArray array];
    
    [self retrieveOrderButtonArray:mySubscriptionCategoriesTitleArray urlStringArr:mySubscriptionCategoriesUrlArray bottomTitleArr:moreCategoriesTitleArray bottomUrlStringArr:moreCategoriesUrlArray];

    orderButton.topTitleArr = mySubscriptionCategoriesTitleArray;
    orderButton.topUrlStringArr = mySubscriptionCategoriesUrlArray;
    orderButton.bottomTitleArr = moreCategoriesTitleArray;
    orderButton.bottomUrlStringArr = moreCategoriesUrlArray;
}

//返回订阅和更多分类数据：如果用户自定义过分类，则使用用户自定义的分类；否则使用缺省的分类
-(void)retrieveOrderButtonArray:(NSMutableArray *)titleArr urlStringArr:(NSMutableArray *)urlStringArr bottomTitleArr:(NSMutableArray *)bottomTitleArr bottomUrlStringArr:(NSMutableArray *)bottomUrlStringArr
{
    // 如果用户自定义过分类，则使用用户自定义的分类；否则使用缺省的分类
    //缺省的分类：将前几项作为缺省的分类
    // 获取了缺省的分类（如果联网失败，则弹出网络提示）
    NSArray* mySubscriptionSavedCategories = [CommonHelper readArchiver:[HomeViewController topCategorySavePath]];
    NSArray* moreSavedCategories = [CommonHelper readArchiver:[HomeViewController bottomCategorySavePath]];
    
    // 用户还没来得及自定义我的订阅，为用户推荐几个？
    //整理成频道名和频道对应的url的数组
    if (!mySubscriptionSavedCategories) {
        if ( !allCategories ) {
            return;
        }
        NSUInteger count =  MIN(kDefaultCategoryCount, allCategories.count);
        for (NSInteger i = 0; i < count; ++i) {
            NSDictionary* dict = [allCategories objectAtIndex:i];
            if (titleArr) {
                [titleArr addObject:[dict objectForKey:kCategoryTitleKey]];
            }
            
            if (urlStringArr) {
                [urlStringArr addObject:[dict objectForKey:kCategoryUrlKey]];
            }
        }
        
        for (NSInteger i = count; i < allCategories.count; ++i) {
            NSDictionary* dict = [allCategories objectAtIndex:i];
            if (bottomTitleArr) {
                [bottomTitleArr addObject:[dict objectForKey:kCategoryTitleKey]];
            }
            
            if(bottomUrlStringArr)
            {
                [bottomUrlStringArr addObject:[dict objectForKey:kCategoryUrlKey]];
            }
        }
    }
    else
    {
        [self split:mySubscriptionSavedCategories titleArray:titleArr urlArray:urlStringArr];
        [self split:moreSavedCategories titleArray:bottomTitleArr urlArray:bottomUrlStringArr];
        
        if (!allCategories) {
            return;
        }
        // 将allCategory的其他频道添加到更多频道里面,前提是不在现有的频道列表中
        NSMutableArray* newMoreCategoryArray = [NSMutableArray arrayWithArray:allCategories];
        for (NSInteger i = newMoreCategoryArray.count-1; i>=0; i--) {
            NSString* title = [[newMoreCategoryArray objectAtIndex:i]objectForKey:kCategoryTitleKey];
            
            if (NSNotFound != [titleArr indexOfObject:title]) {
                [newMoreCategoryArray removeObjectAtIndex:i];
                continue;
            }
            
            if (NSNotFound != [bottomTitleArr indexOfObject:title]) {
                [newMoreCategoryArray removeObjectAtIndex:i];
            }
        }
        
        for (NSDictionary* dict in newMoreCategoryArray) {
            [bottomTitleArr addObject:[dict objectForKey:kCategoryTitleKey]];
            [bottomUrlStringArr addObject:[dict objectForKey:kCategoryUrlKey]];
        }
    }
}

// 根据内存中的数据结构，返回标题和url的数组
-(void)split:(NSArray*)touchViewModels titleArray:(NSMutableArray*)titleArray urlArray:(NSMutableArray*)urlArray
{
    if (!touchViewModels || ( !titleArray && !urlArray)) {
        return;
    }
    
    for (TouchViewModel *model in touchViewModels) {
        if (titleArray) {
            [titleArray addObject:model.title];
        }
        
        if (urlArray) {
            [urlArray addObject:model.urlString];
        }
    }
}

#pragma mark category Button Responder
// 弹出了自定义频道列表视图
- (void)orderViewOut:(id)sender{
    OrderButton * orderButton = (OrderButton *)sender;
    [self refreshOrderButton:orderButton];
    
    if([[orderButton.vc.view subviews] count]>1){
        //        [[[orderButton.vc.view subviews]objectAtIndex:1] removeFromSuperview];
        NSLog(@"%@",[orderButton.vc.view subviews]);
    }
    OrderViewController * orderVC = [[[OrderViewController alloc] init] autorelease];
    orderVC.topTitleArr = orderButton.topTitleArr;
    orderVC.topUrlStringArr = orderButton.topUrlStringArr;
    
    orderVC.bottomTitleArr = orderButton.bottomTitleArr;
    orderVC.bottomUrlStringArr = orderButton.bottomUrlStringArr;
    
    UIView * orderView = [orderVC view];
    [orderView setFrame:CGRectMake(0, - orderButton.vc.view.bounds.size.height, orderButton.vc.view.bounds.size.width, orderButton.vc.view.bounds.size.height)];
    [orderView setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    
    // replace target
    [orderButton removeTarget:self action:@selector(orderViewOut:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setImage:[UIImage imageNamed:KOrderButtonUpImage] forState:UIControlStateNormal];
    
    [self.view insertSubview:orderView belowSubview:orderButton];
    [self addChildViewController:orderVC];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [orderView setFrame:CGRectMake(0, 0, orderButton.vc.view.bounds.size.width, orderButton.vc.view.bounds.size.height)];
        
    } completion:^(BOOL finished){
        
    }];
    
}

// 自定义列表完毕了
- (void)backAction:(id)sender{
    // replace target
    OrderButton * orderButton = (OrderButton *)sender;
    [orderButton removeTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton addTarget:self action:@selector(orderViewOut:) forControlEvents:UIControlEventTouchUpInside];
    [orderButton setImage:[UIImage imageNamed:KOrderButtonDownImage] forState:UIControlStateNormal];
    
    OrderViewController * orderVC = [self.childViewControllers objectAtIndex:0];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [orderVC.view setFrame:CGRectMake(0, - self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height)];
        
    } completion:^(BOOL finished){
        [CommonHelper saveArchiver:[orderVC topViewModels] path:[HomeViewController topCategorySavePath]];
        [CommonHelper saveArchiver:[orderVC bottomViewModels] path:[HomeViewController bottomCategorySavePath]];
        
        [[[self.childViewControllers  objectAtIndex:0] view] removeFromSuperview];
        [orderVC removeFromParentViewController];
        
        [self notifySubscriptionChange];
    }];
}

#pragma mark 数据持久化的文件路径
// 顶部分类:我的订阅
+(NSString*)topCategorySavePath
{
    NSString * string = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [string stringByAppendingPathComponent:@"topCategory.out"];
}

// 底部分类：更多分类
+(NSString*)bottomCategorySavePath
{
    NSString * string = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [string stringByAppendingPathComponent:@"bottomCategory.out"];
}


// 返回存储类别文件的路径
+(NSString*)categoryFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    return [[paths objectAtIndex:0]
            stringByAppendingPathComponent:@"category.out"];
    
}

//频道数据的缓存路径
+(NSString*)categoryDataFilePath:(NSString*)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString* fileName = [NSString stringWithFormat:@"%@.out",[ASIDownloadCache keyForURL:[NSURL URLWithString:url]]];
    return [[paths objectAtIndex:0]
            stringByAppendingPathComponent:fileName];
    
}

// 将数组保存到文件
+(void)saveArray2File:(NSString*)file withArray:(NSArray*)array
{
    if (file && array) {
        [array writeToFile:file atomically:YES];
    }
}

// 从文件中读取数组
+(NSArray*)restoreArrayFromFile:(NSString*)file
{
    if (!file) {
        return nil;
    }
    return [NSArray arrayWithContentsOfFile:file];
}

#pragma mark 网路返回json数据的解析
+(NSArray*)Json2Array:(NSData*)data
{
    NSError* error;
    id obj = data;
    if ([obj isKindOfClass:[NSData class] ]) {
        id res = [NSJSONSerialization JSONObjectWithData:(NSData*)obj  options:NSJSONReadingMutableContainers error:&error];
        
        if (res && [res isKindOfClass:[NSArray class]]) {
            NSDictionary* dict = [res objectAtIndex:0];
            NSString* val = [dict objectForKey:@"Data"];
            res = [NSJSONSerialization JSONObjectWithData:[val dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            if (res && [res isKindOfClass:[NSArray class]]) {
                dict = [res objectAtIndex:0];
                return [dict objectForKey:@"data"];
            }
        }
    }
    return nil;
}

// 我的订阅的变更通知
-(void)notifySubscriptionChange
{
    // 通知数据的关心者
    if ( mySubscriptionDataObservers ) {
        NSMutableArray* mySubscriptionCategoriesTitleArray = [NSMutableArray array];
        NSMutableArray* mySubscriptionCategoriesUrlArray = [NSMutableArray array];
        
        [self retrieveOrderButtonArray:mySubscriptionCategoriesTitleArray urlStringArr:mySubscriptionCategoriesUrlArray bottomTitleArr:nil bottomUrlStringArr:nil];
        for (id<Notifier> notifier in mySubscriptionDataObservers) {
            if ( notifier ) {
                [notifier onChange:[NSArray arrayWithObjects:mySubscriptionCategoriesTitleArray,mySubscriptionCategoriesUrlArray, nil]];
            }
        }
    }
}
@end
