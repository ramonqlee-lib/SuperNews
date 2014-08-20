//
//  HTTPHelper.h
//  HappyLife
//
//  Created by ramonqlee on 4/5/13.
//
//

#import <Foundation/Foundation.h>
#import "CommonHelper.h"
@class FileModel;

//缓存路径
#define CategoryDir @"Category" //频道的目录缓存
#define CategoryCache @"CategoryCache" //频道的数据缓存
#define ImageCache @"ImageCache" //频道的图片缓存

@interface HTTPHelper : NSObject


Decl_Singleton(HTTPHelper)

/**
 return:将以请求的url为key，发送通知，返回请求数据
 */
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown setAllowResumeForFileDownloads:(BOOL)allow;
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown;

-(void)beginPostRequest:(NSString*)url withDictionary:(NSDictionary*)postData;

+(void)clearCache;
+ (NSString *)cachePathForKey:(NSString *)key;
+ (NSString *)cachePathForKey:(NSString *)key underDir:(NSString*)dir;
+(NSInteger)Json2Array:(NSData*)data forArray:(NSMutableArray*)array;
@end
