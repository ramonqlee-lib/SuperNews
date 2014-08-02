//
//  MenuHrizontal.h
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOMALKEY   @"normalKey" // 正常背景
#define HILIGHTKEY  @"hilightKey" // 选中背景
#define HILIGHT_COLOR_KEY  @"hilightColorKey" // 选中背景颜色（优先级高于HILIGHTKEY）
#define TITLEKEY   @"titleKey"
#define TITLEWIDTH @"titleWidth"
#define TOTALWIDTH @"totalWidth"

@protocol HorizontalMenuDelegate <NSObject>

@optional
-(void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex;
@end
@interface MenuHrizontal : UIView
{
    NSMutableArray        *mButtonArray;
    NSMutableArray        *mItemInfoArray;
    UIScrollView          *mScrollView;
    float                 mTotalWidth;
}

@property (nonatomic,assign) id <HorizontalMenuDelegate> delegate;

#pragma mark 初始化菜单
- (id)initWithFrame:(CGRect)frame ButtonItems:(NSArray *)aItemsArray  withRightPadding:(CGFloat)rPadding;

-(void)setButtonItems:(NSArray *)aItemsArray  withRightPadding:(CGFloat)rPadding;

#pragma mark 选中某个button
-(void)clickButtonAtIndex:(NSInteger)aIndex;

#pragma mark 改变第几个button为选中状态，不发送delegate
-(void)changeButtonStateAtIndex:(NSInteger)aIndex;

@end
