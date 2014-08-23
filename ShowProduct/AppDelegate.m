//
//  AppDelegate.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "PrettyKit.h"
#import "Flurry.h"
#import "BPush.h"
#import "JSONKit.h"
#import "OpenUDID.h"
#import "UMSocial.h"
#import "HTTPHelper.h"
//#import "MobClick.h"
#import "Base64.h"
#import "RMDefaults.h"
#import "NSString+Json.h"

#import "UMSocialYixinHandler.h"
#import "UMSocialFacebookHandler.h"
#import "UMSocialLaiwangHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialTwitterHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialTencentWeiboHandler.h"
#import "UMSocialRenrenHandler.h"

#import "UMSocialInstagramHandler.h"
@interface AppDelegate()
{
    HomeViewController* homeViewController;
}
@end

@implementation AppDelegate
@synthesize navigationController = mNavigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    homeViewController = [[HomeViewController alloc] init];
    mNavigationController = (UINavigationController*)[[UINavigationController alloc ]initWithNavigationBarClass:[PrettyNavigationBar class] toolbarClass:nil/*[PrettyToolbar class]*/];
    [mNavigationController setViewControllers:@[homeViewController]];
    self.window.rootViewController = mNavigationController;
    [self appInit];
    [self initBaiduPush:launchOptions];
    
    [self.window makeKeyAndVisible];
    return YES;
}

#if SUPPORT_IOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"test:%@",deviceToken);
    [BPush registerDeviceToken: deviceToken];
    
    [BPush bindChannel];// 无账号绑定
//    self.viewController.textView.text = [self.viewController.textView.text stringByAppendingFormat: @"Register device token: %@\n openudid: %@", deviceToken, [OpenUDID value]];
}


- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    NSLog(@"On method:%@", method);
    NSLog(@"data:%@", [data description]);
    NSDictionary* res = [[[NSDictionary alloc] initWithDictionary:data] autorelease];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        
        if (returnCode == BPushErrorCode_Success) {
            // TODO:发送到云端,方便后续进行精准推送
            //上述参数，保存到本地config中
            NSString* uid = [NSString stringWithFormat:@"%@_%@",userid,channelid];
            [RMDefaults saveString:kUserIdKey withValue:userid];
            [RMDefaults saveString:kChannelIdKey withValue:channelid];
            [RMDefaults saveString:kUIDKey withValue:uid];
            
            //
            if (homeViewController) {
                [homeViewController uploadPushTags];
            }
        }
    } else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
//            self.viewController.appidText.text = nil;
//            self.viewController.useridText.text = nil;
//            self.viewController.channelidText.text = nil;
        }
    }
//    self.viewController.textView.text = [[[NSString alloc] initWithFormat: @"%@ return: \n%@", method, [data description]] autorelease];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Receive Notify: %@", [userInfo JSONString]);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@", alert]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [application setApplicationIconBadgeNumber:0];
    
    [BPush handleNotification:userInfo];
    
//    self.viewController.textView.text = [self.viewController.textView.text stringByAppendingFormat:@"Receive notification:\n%@", [userInfo JSONString]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) dealloc {
    // 先释放掉加载的所有的ViewController
    
    if (mNavigationController != nil) {
        [mNavigationController release];
        mNavigationController = nil;
    }
    [super dealloc];
}

-(void)initBaiduPush:(NSDictionary *)launchOptions
{
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

}
-(void)appInit
{
    [Flurry startSession:kFlurryAPIKey];
    [Flurry setDebugLogEnabled:LOG_ENABLED];
    
    //打开调试log的开关
    [UMSocialData openLog:LOG_ENABLED];
    
    //如果你要支持不同的屏幕方向，需要这样设置，否则在iPhone只支持一个竖屏方向
    [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
    
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UmengAppkey];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:kAppStoreUrl];
    
    //打开新浪微博的SSO开关
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    //打开腾讯微博SSO开关，设置回调地址
    [UMSocialTencentWeiboHandler openSSOWithRedirectUrl:@"http://sns.whalecloud.com/tencent2/callback"];
    
    //打开人人网SSO开关
    [UMSocialRenrenHandler openSSO];
    
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:kAppStoreUrl];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置易信Appkey和分享url地址
    [UMSocialYixinHandler setYixinAppKey:@"yx35664bdff4db42c2b7be1e29390c1a06" url:kAppStoreUrl];
    
    //设置来往AppId，appscret，显示来源名称和url地址
    [UMSocialLaiwangHandler setLaiwangAppId:@"8112117817424282305" appSecret:@"9996ed5039e641658de7b83345fee6c9" appDescription:@"我的分享" urlStirng:kAppStoreUrl];
    
    //使用友盟统计
//    [MobClick startWithAppkey:UmengAppkey];
    
    //设置facebook应用ID，和分享纯文字用到的url地址
    [UMSocialFacebookHandler setFacebookAppID:@"91136964205" shareFacebookWithURL:kAppStoreUrl];
    
    //下面打开Instagram的开关
    [UMSocialInstagramHandler openInstagramWithScale:NO paddingColor:[UIColor blackColor]];
    
    [UMSocialTwitterHandler openTwitter];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

+(BOOL)uploadPushTags:(NSArray*)tagArr
{
    if (!tagArr || !tagArr.count) {
        return NO;
    }
    // FIXME：将订阅的通知提交到服务器(和push管理处的进行合并)
    NSString* userid = [RMDefaults stringForKey:kUserIdKey];
    NSString* channelid = [RMDefaults stringForKey:kChannelIdKey];
    NSString* uid = [RMDefaults stringForKey:kUIDKey];
    if (userid && [userid isKindOfClass:[NSString class]] && userid.length
        && channelid && [channelid isKindOfClass:[NSString class]] && channelid.length
        && uid && [uid isKindOfClass:[NSString class]] && uid.length) {
        NSDictionary* kvDict = [NSDictionary dictionaryWithObjectsAndKeys:userid,kUserIdKey,channelid,kChannelIdKey,uid,kUIDKey, [tagArr componentsJoinedByString:kComma],kTagNameKey,nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kPushIds,kTableName,
                                    kvDict,@"KV",
                                    nil];
        NSLog(@"dictionary:%@",dictionary);
        NSString *pushString = [NSString jsonStringWithObject:dictionary];
        NSLog(@"dictionary jsonString:%@",pushString);
        
        NSString* base64EncodedString = [pushString base64EncodedString];
        //            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appSettingHandler:) name:kAppPushUploadUrl object:nil];
        [[HTTPHelper sharedInstance]beginPostRequest:kAppPushUploadUrl withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:base64EncodedString,@"data", nil]];
        
        [RMDefaults saveString:kFirstTagUploadedFlag withValue:kFirstTagUploadedFlag];//设置首次上传的标示
        return YES;
    }
    return NO;
}
@end
