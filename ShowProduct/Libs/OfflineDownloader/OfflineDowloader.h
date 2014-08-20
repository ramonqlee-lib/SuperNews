//
//  OfflineDowloader.h
//  SuperNews
//
//  Created by ramonqlee on 8/20/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonHelper.h"

@protocol DownloadDelegate <NSObject>
-(void) complete;
-(void) complete:(NSString*)url;
@end

@interface OfflineDowloader : NSObject

Decl_Singleton(OfflineDowloader)

@property(nonatomic,retain)id<DownloadDelegate> downloadDelegate;

-(BOOL)working;// 是否正在离线下载中

-(BOOL)addTask:(NSArray*)urlArray;// 添加离线下载任务，并开始下载

@end
