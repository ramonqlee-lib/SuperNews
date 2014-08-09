//
//  RMFavoriteUtils.h
//  SuperNews
//  收藏数据持久化的管理
//  Created by ramonqlee on 8/10/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMArticle;

@interface RMFavoriteUtils : NSObject

// 添加到收藏库中
+(void)addFavorite:(RMArticle*)article;

// 从收藏库中删除
+(void)removeFavorite:(NSString*)url;

// 获取指定范围的数据
+(NSArray*)favorites:(NSRange)range;

// 返回收藏数据的总数
+(NSInteger)count;
@end
