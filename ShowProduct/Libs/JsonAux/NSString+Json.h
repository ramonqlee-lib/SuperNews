//
//  NSString(JSon).h
//  SuperNews
//
//  Created by ramonqlee on 8/22/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface NSString (HXAddtions)

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;

+(NSString *) jsonStringWithArray:(NSArray *)array;

+(NSString *) jsonStringWithString:(NSString *) string;

+(NSString *) jsonStringWithObject:(id) object;

+(void) jsonTest;

@end

