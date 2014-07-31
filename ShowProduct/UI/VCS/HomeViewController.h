//
//  HomeVC.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>

// 数据发生变化时的回调
@protocol Notifier <NSObject>

-(void) onChange:(NSObject*) object;

@end

@interface HomeViewController : UIViewController

//频道数据的缓存路径
+(NSString*)categoryDataFilePath:(NSString*)url;



// 将数组保存到文件
//+(void)saveArray2File:(NSString*)file withArray:(NSArray*)array;
// 从文件中读取数组
//+(NSArray*)restoreArrayFromFile:(NSString*)file;

@end
