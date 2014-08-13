//
//  RMFavoriteController.m
//  Elite
//
//  Created by Ramonqlee on 11/17/13.
//  Copyright (c) 2013 iDreems. All rights reserved.
//

#import "RMFavoriteController.h"
#import "HomeViewCell.h"
#import "RMArticle.h"
#import "UIImageView+WebCache.h"
#import "SVWebViewController.h"
#import "RMFavoriteUtils.h"
#import "Flurry.h"
#import "RMFavoriteConstants.h"
#import "NSString+HTML.h"
#import "PrettyKit.h"
#import "UIScrollView+AH3DPullRefresh.h"
#import "CommandMaster.h"
#import "RMBaiduAd.h"

#define kEnableTestData NO//FIXME::测试数据
#define kLoadMorePageCount 10//单页加载的item数目
#define kLoadUIDelay 0.5f
#define kCellHeight 76.0f

// toolbar的button编号
#define kZoomInButtonTag 1
#define kZoomOutTag 2

@interface RMFavoriteController ()<CommandMasterDelegate>
{
    SVWebViewController* webViewController;
}
@property (nonatomic,retain) NSMutableArray *itemsArr;//列表数据
@end


@implementation RMFavoriteController
@synthesize itemsArr;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.itemsArr = [[[NSMutableArray alloc] initWithCapacity:16] autorelease];
    [self loadData:NSMakeRange(0,kLoadMorePageCount)];
    [self updateTableViewHandler];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",self.itemsArr.count],kFavoriteCount,nil];
    [Flurry logEvent:kEnterFavorite withParameters:dict];
    
    //ad banner view
    RMBaiduAd* baiduAd = [[RMBaiduAd alloc]init];
    UIView* adView = [baiduAd getBaiduBanner:nil WithAppSpec:nil];
    if (adView) {
        self.tableView.tableHeaderView = adView;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArr.count;//+((self.coverPush!=nil)?1:0);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)aIndexPath
{
    RMArticle* article = [self.itemsArr objectAtIndex:aIndexPath.row];
    static NSString *vCellIdentify = @"homeCell";
    HomeViewCell *vCell = [aTableView dequeueReusableCellWithIdentifier:vCellIdentify];
    if (vCell == nil) {
        vCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeViewCell" owner:self options:nil] lastObject];
    }
    
    NSString* placeHolderImage = (0==aIndexPath.row%2)?kOddTableCellPlaceHolderImage:kEvenTableCellPlaceHolderImage;
    placeHolderImage = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle]resourcePath],placeHolderImage];
    NSString* imageUrl = article.url;
    NSURL* urlForImage = nil;
    if (imageUrl && [imageUrl isKindOfClass:[NSString class]] && [[imageUrl lowercaseString] hasPrefix:kHTTP]) {
        urlForImage = [NSURL URLWithString:imageUrl];
    }
    
    [vCell.headerImageView setImageWithURL:urlForImage imageFile:placeHolderImage];
    
    // TODO 是一个空白的cell，后续采用广告位填充
    // 广告采用插件方式
    vCell.titleLabel.text = article.title;
    NSString* htmlString = article.content;
    vCell.summaryLabel.text = [htmlString stringByStrippingTags];
    if ( (vCell.titleLabel.text && vCell.titleLabel.text.length==0) || (vCell.summaryLabel.text && vCell.summaryLabel.text.length==0))
    {
        vCell.titleLabel.text = @"这是一个预留的位置，投放个性化内容在此";
    }
    
    //    NSLog(@"cell title:%@",vCell.titleLabel.text);
    return vCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //check before going on
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RMArticle* article = [self.itemsArr objectAtIndex:indexPath.row];
    //flurry
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:article.title,kClickArticle,nil];
    [Flurry logEvent:kClickArticle withParameters:dict];
    
    webViewController = [[[SVWebViewController alloc]init]autorelease];
    webViewController.titleString = article.title;
    webViewController.htmlBody = [article.content stringByLinkifyingURLs];
    CGRect rc = [UIScreen mainScreen].applicationFrame;
    webViewController.webviewFrame = CGRectMake(0, 0,rc.size.width , rc.size.height-kAppBarMinimalHeight);
    
    UINavigationController* controller = [[UINavigationController alloc]initWithNavigationBarClass:[PrettyNavigationBar class] toolbarClass:nil/*[PrettyToolbar class]*/];
    [controller setViewControllers:@[webViewController]];
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackAction:)];
    
    webViewController.navigationItem.leftBarButtonItem = BackBtn;
    //[self customizeNavBar:controller];
    [self presentViewController:controller animated:YES completion:(^(void)
                                                                    {
                                                                        self.navigationController.toolbar.hidden = YES;
                                                                        UIButton* zoomInButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomIn"] andTitle:@"放大"];
                                                                        zoomInButton.tag = kZoomInButtonTag;
                                                                        
                                                                        UIButton* zoomOutButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomOut"] andTitle:@"缩小"];
                                                                        zoomOutButton.tag = kZoomOutTag;
                                                                        
                                                                        CommandMaster* commandMaster = [[[CommandMaster alloc]init]autorelease];
                                                                        [commandMaster addButtons:@[zoomInButton,zoomOutButton] forGroup:@"WebviewToolbar"];
                                                                        [commandMaster addToView:webViewController.view andLoadGroup:@"WebviewToolbar"];
                                                                        commandMaster.delegate = self;
                                                                    })];
}

#pragma CommandMaster delegate
- (void)didSelectMenuListItemAtIndex:(NSInteger)index ForButton:(CommandButton *)selectedButton {
    NSLog([NSString stringWithFormat:@"index %i of button titled \"%@\"", index, selectedButton.title]);
}

- (void)didSelectButton:(CommandButton *)selectedButton {
    NSLog([NSString stringWithFormat:@"button titled \"%@\" was selected", selectedButton.title]);
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
            break;
        default:
            break;
    }
}


-(IBAction)BackAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tableview edit
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RMArticle* article = [self.itemsArr objectAtIndex:indexPath.row];
    if (article) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:article.title,kRemoveFromFavorite,nil];
        [Flurry logEvent:kRemoveFromFavorite withParameters:dict];
        
        [RMFavoriteUtils removeFavorite:article.url];
        
        [self.itemsArr removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark test data
-(void)loadData:(NSRange)r
{
    if (!kEnableTestData) {
        NSArray* items = [RMFavoriteUtils favorites:r];
        if (items && items.count) {
            [self.itemsArr removeAllObjects];
            [self.itemsArr addObjectsFromArray:items];
        }
        return;
    }
    //init data
    for (NSInteger i = 0;i<16;++i) {
        RMArticle* v = [[[RMArticle alloc]init]autorelease];
        v.title = [NSString stringWithFormat:@"title for item %d",i];
        v.summary= [NSString stringWithFormat:@"summary for item %d",i];
        v.url = @"http://www.sohu.com";
        v.content = [NSString stringWithFormat:@"content for item %d",i];
        [self.itemsArr addObject:v];
    }
}

#pragma mark back
-(void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark util methods

//-(void)dataDidRefresh
//{
//    if(![self PullToRefreshHandler])
//    {
//        //        [self.tableView setPullToRefreshHandler:nil];
//    }
//    [self.tableView refreshFinished];
//}
-(void)dataDidLoadMore
{
    NSArray* r  = [RMFavoriteUtils favorites:NSMakeRange(self.itemsArr.count, self.itemsArr.count+kLoadMorePageCount)];
    if (r!=nil&&r.count>0) {
        [self.itemsArr addObjectsFromArray:r];
    }
    [self.tableView loadMoreFinished];
    [self.tableView reloadData];
}

-(void)updateTableViewHandler
{
    if (self.tableView) {
        //        if ([self respondsToSelector:@selector(PullToRefreshHandler)])
        //        {
        //            [self.tableView setPullToRefreshHandler:^{
        //                [self performSelector:@selector(dataDidRefresh) withObject:nil afterDelay:kLoadUIDelay];
        //            }];
        //        }
        
        [self.tableView setPullToLoadMoreHandler:^{
            [self performSelector:@selector(dataDidLoadMore) withObject:nil afterDelay:kLoadUIDelay];
        }];
    }
}


@end
