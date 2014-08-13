//
//  RMBaiduAd.m
//  RMBaiduAd
//
//  Created by ramonqlee on 8/12/14.
//  Copyright (c) 2014 iDreems. All rights reserved.
//

#import "RMBaiduAd.h"
#import "BaiduMobAdView.h"
#import "BaiduMobAdDelegateProtocol.h"
#import "CommonHelper.h"

// const definitions
#define kDefaultBaiduPublisherId @"kDefaultBaiduPublisherId"
#define kDefaultBaiduAppSpec     @"kDefaultBaiduAppSpec"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@interface RMBaiduAd()<BaiduMobAdViewDelegate>
{
    NSString* baiduPublisherId;
    NSString* baiduAppSpec;
}
@end


@implementation RMBaiduAd

+(BOOL)setBaiduPublisherId:(NSString*)val
{
   return [CommonHelper saveDefaultsForString:kDefaultBaiduPublisherId withValue:val];
}

+(BOOL)setBaiduAppSpec:(NSString*)val
{
    return [CommonHelper saveDefaultsForString:kDefaultBaiduAppSpec withValue:val];
}


+(NSString*)baiduPublisherId
{
    return [CommonHelper defaultsForString:kDefaultBaiduPublisherId];
}

+(NSString*)baiduAppSpec
{
    return [CommonHelper defaultsForString:kDefaultBaiduAppSpec];
}




+(BOOL)viewIsKindOfBaiduBannerView:(UIView*)view
{
    if (!view) {
        return NO;
    }
    return [view isKindOfClass:[BaiduMobAdView class]];
}

+(CGSize) getBaiduBannerSize
{
    return isPad?kBaiduAdViewBanner728x90:kBaiduAdViewBanner320x48;
}

-(UIView*)getBaiduBanner:(NSString*)publisherId WithAppSpec:(NSString*)appSpec
{
    if (!publisherId || !publisherId.length) {
        baiduPublisherId = [RMBaiduAd baiduPublisherId];
    }
    else
    {
        baiduPublisherId = publisherId;
    }
    
    if (!appSpec || !appSpec.length) {
        baiduAppSpec = [RMBaiduAd baiduAppSpec];
    }
    else
    {
        baiduAppSpec = appSpec;
    }
    
    if (!baiduAppSpec || 0 == baiduAppSpec.length || !baiduPublisherId || 0 == baiduPublisherId.length) {
        return nil;
    }
    
    CGSize sz = [RMBaiduAd getBaiduBannerSize];
    //使用嵌入广告的方法实例。
    BaiduMobAdView* sharedAdView = [[[BaiduMobAdView alloc] init]autorelease];
    //sharedAdView.AdUnitTag = @"myAdPlaceId1";
    //此处为广告位id，可以不进行设置，如需设置，在百度移动联盟上设置广告位id，然后将得到的id填写到此处。
    sharedAdView.AdType = BaiduMobAdViewTypeBanner;
    sharedAdView.frame = CGRectMake(0, 0, sz.width, sz.height);
    sharedAdView.delegate = self;
    [sharedAdView start];
    
    return sharedAdView;
}

#pragma mark BaiduMobAdViewDelegate

- (NSString *)publisherId
{
    return  baiduPublisherId;
}

- (NSString*) appSpec
{
    //注意：该计费名为测试用途，不会产生计费，请测试广告展示无误以后，替换为您的应用计费名，然后提交AppStore.
    return baiduAppSpec;
}

-(BOOL) enableLocation
{
    //启用location会有一次alert提示
    return NO;
}

@end
