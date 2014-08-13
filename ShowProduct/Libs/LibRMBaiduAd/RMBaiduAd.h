//
//  RMBaiduAd.h
//  RMBaiduAd
//
//  Created by ramonqlee on 8/12/14.
//  Copyright (c) 2014 iDreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface RMBaiduAd : NSObject

// 是否百度banner类
+(BOOL)isKindOfBaiduBanner:(UIView*)view;

// 设置百度banner的参数
+(BOOL)setBaiduPublisherId:(NSString*)val;
+(BOOL)setBaiduAppSpec:(NSString*)val;

// 获取百度banner参数
+(NSString*)baiduPublisherId;
+(NSString*)baiduAppSpec;

// 获取百度banner广告的size
+(CGSize) getBaiduBannerSize;

// 获取指定id的百度banner广告
// 参数未设置时，返回nil
-(UIView*)getBaiduBanner:(NSString*)publisherId WithAppSpec:(NSString*)appSpec;

@end
