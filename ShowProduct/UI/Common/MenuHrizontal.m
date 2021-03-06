//
//  MenuHrizontal.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "MenuHrizontal.h"

@implementation MenuHrizontal
- (id)initWithFrame:(CGRect)frame ButtonItems:(NSArray *)aItemsArray  withRightPadding:(CGFloat)rPadding
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setButtonItems:aItemsArray withRightPadding:rPadding];
    }
    return self;
}

-(void)setButtonItems:(NSArray *)aItemsArray  withRightPadding:(CGFloat)rPadding
{
    if (mButtonArray == nil) {
        mButtonArray = [[NSMutableArray alloc] init];
    }
    else
    {
        for (UIButton* btn in mButtonArray) {
            [btn removeFromSuperview];
        }
        [mButtonArray removeAllObjects];
    }
    
    if (mScrollView == nil) {
        mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-rPadding, self.frame.size.height)];
        mScrollView.showsHorizontalScrollIndicator = NO;
    }
    
    if (mItemInfoArray == nil) {
        mItemInfoArray = [[NSMutableArray alloc]init];
    }
    [mItemInfoArray removeAllObjects];
    
    [self createMenuItems:aItemsArray];
}

-(void)createMenuItems:(NSArray *)aItemsArray{
    int i = 0;
    float menuWidth = 0.0;
    for (NSDictionary *lDic in aItemsArray) {
        NSString *vNormalImageStr = [lDic objectForKey:NOMALKEY];
        NSString *vHeligtImageStr = [lDic objectForKey:HILIGHTKEY];
        NSString *vTitleStr = [lDic objectForKey:TITLEKEY];
        float vButtonWidth = [[lDic objectForKey:TITLEWIDTH] floatValue];
        UIButton *vButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [vButton setBackgroundImage:[UIImage imageNamed:vNormalImageStr] forState:UIControlStateNormal];
        UIColor* selectedColor = [lDic objectForKey:HILIGHT_COLOR_KEY];//优先级高于背景图片
        if (selectedColor) {
            [vButton setBackgroundImage:[CommonHelper createImageWithColor:selectedColor] forState:UIControlStateSelected];
        }
        else if(vHeligtImageStr)
        {
            [vButton setBackgroundImage:[UIImage imageNamed:vHeligtImageStr] forState:UIControlStateSelected];
        }

        [vButton setTitle:vTitleStr forState:UIControlStateNormal];
        [vButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [vButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [vButton setTag:i];
        [vButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [vButton setFrame:CGRectMake(menuWidth, 0, vButtonWidth, self.frame.size.height)];
        [mScrollView addSubview:vButton];
        [mButtonArray addObject:vButton];
        
        menuWidth += vButtonWidth;
        i++;
        
        //保存button资源信息，同时增加button.oringin.x的位置，方便点击button时，移动位置。
        NSMutableDictionary *vNewDic = [lDic mutableCopy];
        [vNewDic setObject:[NSNumber numberWithFloat:menuWidth] forKey:TOTALWIDTH];
        [mItemInfoArray addObject:vNewDic];
    }

    [mScrollView setContentSize:CGSizeMake(menuWidth, self.frame.size.height)];
    [self addSubview:mScrollView];
    // 保存menu总长度，如果小于320则不需要移动，方便点击button时移动位置的判断
    mTotalWidth = menuWidth;
}

#pragma mark - 其他辅助功能
#pragma mark 取消所有button点击状态
-(void)changeButtonsToNormalState{
    for (UIButton *vButton in mButtonArray) {
        vButton.selected = NO;
    }
}

#pragma mark 模拟选中第几个button
-(void)clickButtonAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    [self menuButtonClicked:vButton];
}

#pragma mark 改变第几个button为选中状态，不发送delegate
-(void)changeButtonStateAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    [self changeButtonsToNormalState];
    vButton.selected = YES;
    [self moveScrolViewWithIndex:aIndex];
}

#pragma mark 移动button到可视的区域
-(void)moveScrolViewWithIndex:(NSInteger)aIndex{
    NSLog(@"moveScrolViewWithIndex: %d",aIndex);
    if (mItemInfoArray.count < aIndex) {
        return;
    }
    
    //宽度小于320肯定不需要移动
    CGFloat scrollWidth = mScrollView.frame.size.width;
    if (mTotalWidth <= scrollWidth) {
        return;
    }
    NSDictionary *vDic = [mItemInfoArray objectAtIndex:aIndex];
    float vButtonOrigin = [[vDic objectForKey:TOTALWIDTH] floatValue];
    if (vButtonOrigin >= 300) {
        if ((vButtonOrigin + 180) >= mScrollView.contentSize.width) {
            [mScrollView setContentOffset:CGPointMake(mScrollView.contentSize.width - scrollWidth, mScrollView.contentOffset.y) animated:YES];
            NSLog(@"setContentOffset: (%f,%f)",mScrollView.contentSize.width - scrollWidth, mScrollView.contentOffset.y);
            return;
        }
        
        float vMoveToContentOffset = vButtonOrigin - 180;
        if (vMoveToContentOffset > 0) {
            [mScrollView setContentOffset:CGPointMake(vMoveToContentOffset, mScrollView.contentOffset.y) animated:YES];
            NSLog(@"setContentOffset: (%f,%f)",vMoveToContentOffset, mScrollView.contentOffset.y);
        }
        //        NSLog(@"scrollwOffset.x:%f,ButtonOrigin.x:%f,mscrollwContentSize.width:%f",mScrollView.contentOffset.x,vButtonOrigin,mScrollView.contentSize.width);
    }else{
        [mScrollView setContentOffset:CGPointMake(0, mScrollView.contentOffset.y) animated:YES];
        NSLog(@"setContentOffset: (%f,%f)",0.0, mScrollView.contentOffset.y);
        return;
    }
}

#pragma mark - 点击事件
-(void)menuButtonClicked:(UIButton *)aButton{
    [self changeButtonStateAtIndex:aButton.tag];
    if ([_delegate respondsToSelector:@selector(didMenuHrizontalClickedButtonAtIndex:)]) {
        [_delegate didMenuHrizontalClickedButtonAtIndex:aButton.tag];
    }
}


#pragma mark 内存相关
-(void)dealloc{
    [mButtonArray removeAllObjects],mButtonArray = nil;
    [super dealloc];
}

@end
