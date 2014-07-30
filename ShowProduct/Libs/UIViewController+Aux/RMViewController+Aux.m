//
//  RMViewController+Aux.m
//  MessageGuru
//
//  Created by ramonqlee on 2/26/14.
//  Copyright (c) 2014 iDreems. All rights reserved.
//

#import "RMViewController+Aux.h"
#import "MobiSageSDK.h"
#import "Constants.h"
#import <objc/runtime.h>
#import "PulsingHaloLayer.h"
#import "BaiduMobAdView.h"
#import "BaiduMobAdInterstitial.h"

#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
NSString* kClientViewKey   = @"kClientView";
NSString* kPulsingHaloKey  = @"kPulsingHaloKey";

static BaiduMobAdInterstitial* interstitialView;

@interface UIViewController(RMViewController_Aux_Private)<BaiduMobAdInterstitialDelegate,MobiSageAdBannerDelegate,MobiSageRecommendDelegate,BaiduMobAdViewDelegate>
{
 
}
@end

@implementation UIViewController(RMViewController_Aux)
//适配ios7
-(UIView*)clientView
{
    UIView* adapterView = (UIView*)objc_getAssociatedObject(self,&kClientViewKey);
    
    if (adapterView) {
        return adapterView;
    }
    
    CGFloat minusHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        minusHeight += self.navigationController.navigationBar.frame.size.height;
    }
    
    //adapterview，适配ios7
    adapterView = [[UIView alloc]initWithFrame:CGRectZero];
    CGRect rect = [[UIScreen mainScreen]bounds];
    rect.size.height -= minusHeight;
    if (IOS7_OR_LATER) {
        rect.origin.y += minusHeight;
    }
    
    adapterView.frame = rect;
    [self.view addSubview:adapterView];
    [adapterView release];
    
    objc_setAssociatedObject(self, &kClientViewKey, adapterView, OBJC_ASSOCIATION_ASSIGN);
    
    return adapterView;
}
- (void)addNavigationButton:(UIBarButtonItem*)leftButtonItem withRightButton:(UIBarButtonItem*)rightButtonItem;
{
    // Dispose of any resources that can be recreated.
    if (!leftButtonItem) {
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"")
                                          style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(back)] autorelease];
    }
    
    if (leftButtonItem) {
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    }
    if (rightButtonItem) {
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
}

#pragma mark dismiss selector
-(IBAction)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark mobisage banner
-(UIView*)getMobisageBanner
{
    MobiSageAdBanner* adBanner = nil;
    if (adBanner == nil) {
        if (UIUserInterfaceIdiomPad == [UIDevice currentDevice].userInterfaceIdiom) {
            adBanner = [[[MobiSageAdBanner alloc] initWithAdSize:Ad_728X90 withDelegate:self]autorelease];
            adBanner.frame = CGRectMake(20, 80, 728, 90);
        }
        else {
            adBanner = [[[MobiSageAdBanner alloc] initWithAdSize:Ad_320X50 withDelegate:self]autorelease];
            adBanner.frame = CGRectMake(0, 80, 320, 50);
        }
        
        //设置广告轮播动画效果
        [adBanner setSwitchAnimeType:Random];
    }
    return adBanner;
}

#pragma  mark MobiSageAdBannerDelegate
#pragma mark
- (UIViewController *)viewControllerForPresentingModalView;
{
    return self;
}

- (UIViewController *)viewControllerToPresent
{
    return self;
}

/**
 *  横幅广告被点击
 *  @param adBanner
 */
- (void)mobiSageAdBannerClick:(MobiSageAdBanner*)adBanner
{
    NSLog(@"横幅广告被点击");
}

/**
 *  adBanner请求成功并展示广告
 *  @param adBanner
 */
- (void)mobiSageAdBannerSuccessToShowAd:(MobiSageAdBanner*)adBanner
{
    NSLog(@"横幅广告请求成功并展示广告");
}
/**
 *  adBanner请求失败
 *  @param adBanner
 */
- (void)mobiSageAdBannerFaildToShowAd:(MobiSageAdBanner*)adBanner
{
    NSLog(@"横幅广告请求失败");
}
/**
 *  adBanner被点击后弹出LandingSit
 *  @param adBanner
 */
- (void)mobiSageAdBannerPopADWindow:(MobiSageAdBanner*)adBanner
{
    NSLog(@"被点击后弹出LandingSit");
}
/**
 *  adBanner弹出的LandingSit被关闭
 *  @param adBanner
 */
- (void)mobiSageAdBannerHideADWindow:(MobiSageAdBanner*)adBanner
{
    NSLog(@"弹出的LandingSit被关闭");
}

#pragma mark PulsingHalo
-(void)pulsingView:(UIView*)decoratedView
{
    [self pulsingView:decoratedView withRadius:0.0 withColor:nil];
}
-(void)pulsingView:(UIView*)decoratedView withRadius:(CGFloat)radius withColor:(UIColor *)color
{
    PulsingHaloLayer* adapterView = (PulsingHaloLayer*)objc_getAssociatedObject(self,&kPulsingHaloKey);
    
    if (adapterView) {
        return;
    }
    
    adapterView = [PulsingHaloLayer layer];
    adapterView.position = decoratedView.center;
    [decoratedView.superview.layer insertSublayer:adapterView below:decoratedView.layer];
    
    adapterView.radius = (radius<=1.0)?40:radius;
    if(!color)
    {
        color = [UIColor colorWithRed:1.0
                                green:0
                                 blue:0
                                alpha:1.0];
    }
    
    adapterView.backgroundColor = color.CGColor;
    
    objc_setAssociatedObject(self, &kPulsingHaloKey, adapterView, OBJC_ASSOCIATION_ASSIGN);
}
#pragma mark baiduadview
// 返回nil，表示已经添加过
-(UIView*)getBaiduBanner
{
    NSArray* views = [self.view subviews];
    for (UIView* child in views) {
        if ([child isKindOfClass:[BaiduMobAdView class]]) {
            return nil;
        }
    }
    
    CGRect frame = self.view.frame;
    CGSize sz = isPad?kBaiduAdViewBanner728x90:kBaiduAdViewBanner320x48;
    CGFloat xOffset = (frame.size.width-sz.width)/2;
    //使用嵌入广告的方法实例。
    BaiduMobAdView* sharedAdView = [[[BaiduMobAdView alloc] init]autorelease];
    //sharedAdView.AdUnitTag = @"myAdPlaceId1";
    //此处为广告位id，可以不进行设置，如需设置，在百度移动联盟上设置广告位id，然后将得到的id填写到此处。
    sharedAdView.AdType = BaiduMobAdViewTypeBanner;
    sharedAdView.frame = CGRectMake(xOffset, 0, sz.width, sz.height);
    sharedAdView.delegate = self;
    //[self.view addSubview:sharedAdView];
    [sharedAdView start];
    
    return sharedAdView;
}
#pragma mark BaiduMobAdViewDelegate

#define kBaiduBannerAppId @"ade01d31"
- (NSString *)publisherId
{
    return  kBaiduBannerAppId; //@"your_own_app_id";
}

- (NSString*) appSpec
{
    //注意：该计费名为测试用途，不会产生计费，请测试广告展示无误以后，替换为您的应用计费名，然后提交AppStore.
    return kBaiduBannerAppId;
}

-(BOOL) enableLocation
{
    //启用location会有一次alert提示
    return NO;
}
-(UIView*)getAdBanner
{
    return [self getBaiduBanner];
}

- (IBAction)loadBaiduMobAdInterstitial:(id)sender
{
    if (interstitialView) {
        return;
    }
    interstitialView = [[BaiduMobAdInterstitial alloc] init];
    interstitialView.delegate = self;
    [interstitialView load];
}

- (IBAction)showBaiduMobAdInterstitial:(id)sender {
    if (interstitialView.isReady) {
        [interstitialView presentFromRootViewController:self.tabBarController];
    }else {
        NSLog(@"ad not ready");
    }
}

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    [self showBaiduMobAdInterstitial:nil];
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
}

-(UIView*)getMobisageRecommendListView
{
    MSRecommendContentView* view = [[MSRecommendContentView alloc]initWithdelegate:self width:self.view.frame.size.width adCount:10];
    
    return view;
}
@end
