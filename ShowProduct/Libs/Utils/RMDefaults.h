//
//  RMDefaults.h
//  SuperNews
//
//  Created by ramonqlee on 8/14/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMDefaults : NSObject

// String
+(BOOL)saveString:(NSString*)key withValue:(NSString*)value;
+(NSString*)stringForKey:(NSString*)key;

// int
+(BOOL)saveInt:(NSString*)key withValue:(NSInteger)value;
+(NSInteger)integerForKey:(NSString*)key;

@end
