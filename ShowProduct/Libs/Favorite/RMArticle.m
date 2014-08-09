//
//  RMArticle.m
//  InfiniteTabProject
//
//  Created by Ramonqlee on 8/4/13.
//  Copyright (c) 2013 iDreems. All rights reserved.
//

#import "RMArticle.h"
#import "RMFavoriteConstants.h"

#define kDefaultUrl @"http://www.idreems.com/default.html"

@implementation RMArticle
@synthesize title;
@synthesize summary;
@synthesize content;
@synthesize url;
@synthesize likeNumber;
@synthesize favoriteNumber;
@synthesize commentNumber;
@synthesize thumbnailUrl;

+(NSArray*)initWithData:(NSData*)data withKey:(NSString*)use
{
    if (data) {
        NSError* error;
        id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (res && [res isKindOfClass:[NSDictionary class]]) {
            NSObject* items = [res objectForKey:use];
            
            if (items && [items isKindOfClass:[NSArray class]]) {
                NSMutableArray* array = [[[NSMutableArray alloc]initWithCapacity:((NSArray*)items).count]autorelease];
                
                for (NSDictionary* item in (NSArray*)items) {
                    RMArticle* article = [[[RMArticle alloc]init]autorelease];
                    article.title = [item valueForKey:kDBLowercaseTitle];
                    article.summary = [item valueForKey:kDBLowercaseSummary];
                    article.thumbnailUrl = [item valueForKey:kDBLowercaseThumbnail];
                    article.content = [item valueForKey:kDBLowercaseContent];
                    article.url = [item valueForKey:kDBPageUrl];
                    //
                    if (!article.url|| article.url.length==0) {
                        article.url = kDefaultUrl;
                    }
                    
                    const id kNull = (id)[NSNull null];
                    if (article.title && article.title != kNull) {
                        article.title = [[article.title
                                          stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    if (article.summary && article.summary != kNull) {
                        article.summary = [[article.summary
                                            stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    if (article.thumbnailUrl && article.thumbnailUrl != kNull) {
                        article.thumbnailUrl=[[article.thumbnailUrl
                                               stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                                              stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    if (article.content && article.content != kNull) {
                        article.content=[[article.content
                                          stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    
                    [array addObject:article];
                }
                
                //TODO::other field reserved for future use
                return array;
            }
        } else {
            //NSLog(@"arr dataSourceDidError == %@",arrayData);
        }
    }
    
    return nil;
}
@end
