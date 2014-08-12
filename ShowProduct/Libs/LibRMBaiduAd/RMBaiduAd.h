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

// 获取百度banner广告的size
+(CGSize) getBaiduBannerSize;

// 获取指定id的百度banner广告
-(UIView*)getBaiduBanner:(NSString*)publisherId WithAppSpec:(NSString*)appSpec;

@end
