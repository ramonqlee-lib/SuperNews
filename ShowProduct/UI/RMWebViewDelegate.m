//
//  RMWebViewDelegate.m
//  SuperNews
//
//  Created by ramonqlee on 8/28/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import "RMWebViewDelegate.h"
#import "SVWebViewController.h"
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
#import "UMSocial.h"
#import "AppDelegate.h"



// toolbar的button编号
#define kZoomInButtonTag 1
#define kZoomOutTag 2
#define kAdd2FavoriteButtonTag 3
#define kShareButtonTag 4

@interface RMWebViewDelegate()<UMSocialUIDelegate,CommandMasterDelegate>
{
    
}
@property (nonatomic,retain) UIViewController* viewController;
@property (nonatomic,retain) SVWebViewController* webViewController;
@property (nonatomic,retain) NSDictionary* dataDict;
@end

@implementation RMWebViewDelegate
@synthesize viewController,webViewController,dataDict;

Impl_Singleton(RMWebViewDelegate)


-(void)presentInWebView:(NSDictionary*)dict inViewContrller:(UIViewController*)vController
{
    if (!dict || !dict.count) {
        return;
    }
    self.dataDict = dict;
    
    NSString* content = [dict objectForKey:kLowercaseContentKey];
    NSString* title = [dict objectForKey:kLowercaseTitleKey];
    
    [Flurry logEvent:@"Title" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:title ,@"Title", nil]];
    
    webViewController = [[[SVWebViewController alloc]init]autorelease];
    webViewController.titleString = title;
    webViewController.htmlBody = [content stringByLinkifyingURLs];
    CGRect rc = [UIScreen mainScreen].applicationFrame;
    webViewController.webviewFrame = CGRectMake(0, 0,rc.size.width , rc.size.height-kAppBarMinimalHeight);
    
    UINavigationController* controller = [[UINavigationController alloc]initWithNavigationBarClass:[PrettyNavigationBar class] toolbarClass:nil];
    [controller setViewControllers:@[webViewController]];
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(BackAction:)];
    
    webViewController.navigationItem.leftBarButtonItem = BackBtn;
    self.viewController = vController;
    UIViewController* rootController = self.viewController;//[[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController presentViewController:controller animated:YES completion:(^(void)
                                                                              {
                                                                                  UIButton* zoomInButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomIn"] andTitle:@"放大"];
                                                                                  zoomInButton.tag = kZoomInButtonTag;
                                                                                  
                                                                                  // FIXME: 全局的，修改为局部的，防止在 收藏中 有添加收藏出现
                                                                                  UIButton* zoomOutButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"zoomOut"] andTitle:@"缩小"];
                                                                                  zoomOutButton.tag = kZoomOutTag;
                                                                                  
                                                                                  UIButton* add2FavoriteButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"saveIcon"] andTitle:@"收藏"];
                                                                                  add2FavoriteButton.tag = kAdd2FavoriteButtonTag;
                                                                                  
                                                                                  UIButton* shareButton = [CommandButton createButtonWithImage:[UIImage imageNamed:@"UMS_share"] andTitle:@"分享"];
                                                                                  shareButton.tag = kShareButtonTag;
                                                                                  
                                                                                  CommandMaster* commandMaster = [[[CommandMaster alloc]init]autorelease];
                                                                                  [commandMaster addButtons:@[zoomInButton,zoomOutButton,add2FavoriteButton,shareButton] forGroup:@"WebviewToolbar"];
                                                                                  [commandMaster addToView:webViewController.view andLoadGroup:@"WebviewToolbar"];
                                                                                  commandMaster.delegate = self;
                                                                              })];
    
}

-(IBAction)BackAction:(id)sender
{
    UIViewController* rootController = self.viewController;//[[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController dismissViewControllerAnimated:YES completion:nil];
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
            [self add2FavoriteAction:nil];
            break;
        case kShareButtonTag:
            [self showShareList:nil];
            break;
        default:
            break;
    }
}
/*
 注意分享到新浪微博我们使用新浪微博SSO授权，你需要在xcode工程设置url scheme，并重写AppDelegate中的`- (BOOL)application openURL sourceApplication`方法，详细见文档。否则不能跳转回来原来的app。
 */
-(IBAction)showShareList:(id)sender
{
    // TODO: 待在delegate中修改配置参数
    NSString* temp = NSLocalizedString(@"RecommendFormatter", nil);
    NSString *shareText = [NSString stringWithFormat:temp,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]]; //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"Default"];          //分享内嵌图片
    
    //如果得到分享完成回调，需要设置delegate为self
    [UMSocialSnsService presentSnsIconSheetView:webViewController appKey:UmengAppkey shareText:shareText shareImage:shareImage shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,UMShareToWechatFavorite,UMShareToEmail,nil] delegate:self];
}



////下面可以设置根据点击不同的分享平台，设置不同的分享文字
//-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
//{
//    if ([platformName isEqualToString:UMShareToSina]) {
//        socialData.shareText = @"分享到新浪微博";
//    }
//    else{
//        socialData.shareText = @"分享内嵌文字";
//    }
//}

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    NSLog(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        NSString* snsName = [[response.data allKeys] objectAtIndex:0];
        [Flurry logEvent:snsName];
        
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",snsName);
    }
}

-(void)add2FavoriteAction:(id)sender
{
    NSDictionary* dict = self.dataDict;
    
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

@end
