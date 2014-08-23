//
//  AppDelegate.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFlurryAPIKey @"VD57WGD28683BPMSQ9X9"
#define UmengAppkey @"53f672a5fd98c5922101a575"
#define kAppStoreUrl @"https://itunes.apple.com/us/app/qu-wei-li-shi/id905734176?ls=1&mt=8"

// push related
#define kAppPushUploadUrl @"http://novelists.duapp.com/crawler/update.php"
#define kUserIdKey @"UserId"
#define kChannelIdKey @"ChannelId"
#define kUIDKey @"UID"
#define kTagNameKey @"TagName"
#define kPushIds @"PushIDs"
#define kTableName @"tableName"

#define kFirstTagUploadedFlag @"kFirstTagUploadedFlag"// 首次push上传tag用标示
#define kAllTags @"kAllTags"// 所有tag的本地key
#define kAllTagsSwitchFlag @"kAllTagsFlag"// 所有tag的开关，YES代表开，NO代表关
#define kComma @","// 本地tag的分割符


@interface
AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *mNavigationController;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain)  UINavigationController *navigationController;

+(BOOL)uploadPushTags:(NSArray*)tagArr;
@end
