//
//  OfflineDowloader.m
//  SuperNews
//
//  Created by ramonqlee on 8/20/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import "OfflineDowloader.h"
#import "HTTPHelper.h"

@interface OfflineDowloader()
{
    NSMutableDictionary* dowloadingTasks;
}
@end

@implementation OfflineDowloader
Impl_Singleton(OfflineDowloader)
@synthesize downloadDelegate;

-(BOOL)working
{
    return dowloadingTasks?dowloadingTasks.count>0:NO;
}

-(BOOL)addTask:(NSArray*)urlArray
{
    if (!urlArray || !urlArray.count) {
        return NO;
    }
    if (!dowloadingTasks) {
        dowloadingTasks = [[NSMutableDictionary alloc]initWithCapacity:urlArray.count];
    }
    for (NSString* url in urlArray) {
        [dowloadingTasks setObject:@"" forKey:url];
        
        [self download:url];
    }
    return YES;
}


// 下载完毕后的通知
-(void)downloadComplete:(NSString*)url
{
    // TODO::单个通知栏弹出提示以及整体的通知提示
    // 删除当前的下载任务索引
    // 是否已经全部下载完毕
    if (dowloadingTasks) {
        [dowloadingTasks removeObjectForKey:url];
    }
    
    if (dowloadingTasks && !dowloadingTasks.count) {
        if (self.downloadDelegate) {
            [self.downloadDelegate complete];
        }
//        [[ZJTStatusBarAlertWindow getInstance]showWithString:@"离线下载完毕！"];
    }
    else
    {
        [self.downloadDelegate complete:url];
//        [[ZJTStatusBarAlertWindow getInstance]showWithString:@"离线下载中..."];
    }
}

#pragma mark 获取频道分类数据
-(BOOL)download:(NSString*)url
{
    NSString* filePath = [HTTPHelper cachePathForKey:url];
    NSDictionary* dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSMutableDictionary* postDict = [NSMutableDictionary dictionary];
    if (dict) {
        NSDate* lastModified = [dict fileModificationDate];
        NSTimeInterval interval = [lastModified timeIntervalSince1970];
        [postDict setObject:[NSString stringWithFormat:@"%.0f",interval] forKey:@"since"];
    }
    [postDict setObject:@"1" forKey:@"zipped"];//请求压缩格式的数据
    
    NSLog(@"refresh from url: %@",url);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refeshHandler:) name:url object:nil];
    
    [[HTTPHelper sharedInstance]beginPostRequest:url withDictionary:postDict];
    return YES;
}


// 刷新数据完毕
-(void)refeshHandler:(NSNotification*)notification
{
    NSString* url = notification.name;
    NSLog(@"offline downloaded: %@",url);
    [self downloadComplete:url];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:url object:nil];
    
    id obj = [notification.userInfo objectForKey:url];
    // : 解析json数据，并设置到列表中
    NSMutableArray* temp = [NSMutableArray array];
    if ([obj isKindOfClass:[NSData class]])
    {
        NSData* unzipped = [CommonHelper uncompressZippedData:(NSData*)obj];
        [HTTPHelper Json2Array:unzipped forArray:temp];
    }
    if (temp.count)
    {
        NSString* filePath = [HTTPHelper cachePathForKey:url];
        NSLog(@"receive http data &refresh tableview & cache file under %@",filePath);
        [CommonHelper saveArchiver:temp path:filePath];
    }
}
@end
