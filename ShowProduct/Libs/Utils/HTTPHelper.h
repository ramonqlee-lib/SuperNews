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

@interface HTTPHelper : NSObject


Decl_Singleton(HTTPHelper)

/**
 return:将以请求的url为key，发送通知，返回请求数据
 */
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown setAllowResumeForFileDownloads:(BOOL)allow;
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown;

-(void)beginPostRequest:(NSString*)url withDictionary:(NSDictionary*)postData;

+(NSString*)cacheFilePath:(NSString*)url;
+(NSInteger)Json2Array:(NSData*)data forArray:(NSMutableArray*)array;
@end
