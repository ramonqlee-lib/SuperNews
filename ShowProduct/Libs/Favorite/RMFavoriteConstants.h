//
//  RMFavoriteConstants.h
//  SuperNews
//
//  Created by ramonqlee on 8/10/14.
//  Copyright (c) 2014 IDreems. All rights reserved.
//

#import <Foundation/Foundation.h>

// flurry events
#define kAdd2Favorite @"kAdd2Favorite"
#define kEnterFavorite @"kEnterFavorite"
#define kFavoriteCount @"kFavoriteCount"
#define kRemoveFromFavorite @"kRemoveFromFavorite"
#define kClickArticle @"kClickArticle"

// db design
#define FAVORITE_DB_NAME    @"favorite.sqlite"
#define kDBTableName    @"Content"
#define kDBTitle         @"Title"
#define kDBLowercaseTitle         @"title"
#define kDBSummary       @"Summary"
#define kDBLowercaseSummary      @"summary"
#define kDBContent       @"Content"
#define kDBLowercaseContent       @"content"
#define kDBPageUrl       @"PageUrl"
#define kDBFavoriteTime  @"FavTime"
#define kThumbnail       @"Thumbnail"
#define kDBLowercaseThumbnail       @"thumbnail"

#define kLikeNumber @"kLikeNumber"
#define kLikeNumberPlus @"kLikeNumberPlus"
#define kLikeNumberMinus @"kLikeNumberMinus"
#define kCommentNumber @"kCommentNumber"

#define kFavoriteNumber @"kFavoriteNumber"
#define kFavoriteNumberPlus @"kFavoriteNumberPlus"
#define kFavoriteNumberMinus @"kFavoriteNumberMinus"

#define kFavoriteDBChangedEvent @"kFavoriteDBChangedEvent"

