//
//  HomeView.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "HomeView.h"
#import "HomeViewCell.h"

#define MENUHEIHT 40

@interface HomeView()
{
    NSArray* titleArray;
    NSArray* urlArray;
    NSArray *vButtonItemArray;
}
@end
@implementation HomeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commInit];
    }
    return self;
}

#pragma mark UI初始化
-(void)commInit{
    // TODO:此处需要读取缓存数据，进行展示
    // 缓存的频道列表和频道数据
    vButtonItemArray = @[@{NOMALKEY: @"normal.png",
                           HEIGHTKEY:@"helight.png",
                           TITLEKEY:@"头条",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal.png",
                           HEIGHTKEY:@"helight.png",
                           TITLEKEY:@"推荐",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"娱乐",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥1",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥2",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           },
                         @{NOMALKEY: @"normal",
                           HEIGHTKEY:@"helight",
                           TITLEKEY:@"帅哥3ß",
                           TITLEWIDTH:[NSNumber numberWithFloat:60]
                           }
                         ];
    [self resetContent];
}

-(void)resetContent
{
    if (mHorizontalMenu == nil) {
        mHorizontalMenu = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, MENUHEIHT) ButtonItems:vButtonItemArray];
        mHorizontalMenu.delegate = self;
        [self addSubview:mHorizontalMenu];
    }
    else
    {
        [mHorizontalMenu setButtonItems:vButtonItemArray];
    }
    
    //初始化滑动列表
    if (mScrollPageView == nil) {
        mScrollPageView = [[ScrollPageView alloc] initWithFrame:CGRectMake(0, MENUHEIHT, self.frame.size.width, self.frame.size.height - MENUHEIHT)];
        mScrollPageView.delegate = self;
        [self addSubview:mScrollPageView];
    }
    
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    //默认选中第一个button
    [mHorizontalMenu clickButtonAtIndex:0];
}
#pragma mark 内存相关
-(void)dealloc{
    [mHorizontalMenu release],mHorizontalMenu = nil;
    [mScrollPageView release],mScrollPageView = nil;
    [super dealloc];
}

#pragma mark - 其他辅助功能
#pragma mark MenuHrizontalDelegate
-(void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex{
    NSLog(@"第%d个Button点击了",aIndex);
    [mScrollPageView moveScrollowViewAthIndex:aIndex];
}

#pragma mark ScrollPageViewDelegate
-(void)didScrollPageViewChangedPage:(NSInteger)aPage{
    NSLog(@"CurrentPage:%d",aPage);
    [mHorizontalMenu changeButtonStateAtIndex:aPage];
    //    if (aPage == 3) {
    //刷新当页数据
    [mScrollPageView freshContentTableAtIndex:aPage];
    //    }
}

#pragma mark Notifier impl
-(void) onChange:(NSObject*) object
{
    // [titleArray,urlArray]
    // 更新主页的频道列表
    // object中包含频道列表数据
    // TODO:: 刷新第一个页面的数据（自上次更新后，是否需要更新）
    if (![object isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray* r = (NSArray*)object;
    if ( !r  || r.count != 2) {
        return;
    }
    
    titleArray = [r objectAtIndex:0];
    urlArray = [r objectAtIndex:1];
    
    if ( !titleArray || 0 == titleArray.count || !urlArray || 0 == urlArray.count ) {
        return;
    }
    
    NSMutableArray* itemsArray = [NSMutableArray arrayWithCapacity:titleArray.count];
    vButtonItemArray = itemsArray;
    for (NSString* val in titleArray) {
        // FIXME: 动态计算文本所占宽度.目前是简单的字符数定宽推断法
        [itemsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"normal.png",NOMALKEY,
                               @"helight.png",HEIGHTKEY,
                               val,TITLEKEY,
                               [NSNumber numberWithFloat:val.length*20],TITLEWIDTH, nil]];
    }
    
    [self resetContent];
}

@end
