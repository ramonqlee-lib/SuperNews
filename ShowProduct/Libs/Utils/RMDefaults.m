//
//  RMDefaults.m
//  SuperNews
//
//  Created by ramonqlee on 8/14/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import "RMDefaults.h"

@implementation RMDefaults

+(BOOL)saveString:(NSString*)key withValue:(NSString*)value
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setValue:value forKey:key];
    return [setting synchronize];
}
+(NSString*)stringForKey:(NSString*)key
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return [setting valueForKey:key];
}

+(BOOL)saveInt:(NSString*)key withValue:(NSInteger)value
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    [setting setInteger:value forKey:key];
    return [setting synchronize];
}
+(NSInteger)integerForKey:(NSString*)key
{
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    return [setting integerForKey:key];
}

@end
