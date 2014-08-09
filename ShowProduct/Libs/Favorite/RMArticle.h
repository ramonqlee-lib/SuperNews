//描述每篇文章，包括标题，摘要，正文，缩略图等信息
//  RMArticle.h
//  InfiniteTabProject
//
//  Created by Ramonqlee on 8/4/13.
//  Copyright (c) 2013 iDreems. All rights reserved.
//
/**
 article class
 */
#import <Foundation/Foundation.h>

@interface RMArticle : NSObject

@property(nonatomic,copy)NSString* title;//标题
@property(nonatomic,copy)NSString* summary;//摘要
@property(nonatomic,copy)NSString* content;//正文
@property(nonatomic,copy)NSString* thumbnailUrl;//缩略图
@property(nonatomic,copy)NSString* url;
@property(nonatomic,assign)NSInteger likeNumber;
@property(nonatomic,assign)NSInteger favoriteNumber;
@property(nonatomic,assign)NSInteger commentNumber;

+(NSArray*)initWithData:(NSData*)data withKey:(NSString*)use;
@end
