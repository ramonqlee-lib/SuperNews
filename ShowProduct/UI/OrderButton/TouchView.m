//
//  TouchView.m
//  TouchDemo
//
//  Created by Zer0 on 13-8-11.
//  Copyright (c) 2013年 Zer0. All rights reserved.
//

#import "TouchView.h"
#import "Header.h"
#define BUTTON_PER_LINE 4

@implementation TouchView
- (void)dealloc
{
    [_label release];
    [_moreChannelsLabel release];
    [_touchViewModel release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label = l;
        [l release];
        _sign = 0;
        
    }
    return self;
}

- (void)layoutSubviews{
    
    [self.label setFrame:CGRectMake(1, 1, KButtonWidth - 2, KButtonHeight - 2)];
    [self.label setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    [self addSubview:self.label];
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = [touches anyObject];
    
    _point = [touch locationInView:self];
    _point2 = [touch locationInView:self.superview];
    
    [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[[self.superview subviews] count] - 1];
    
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    int a = point.x - _point.x;
    int b = point.y - _point.y;
    //    if (![self.label.text isEqualToString:@"头条"])
    {
        [self.label setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
        [self setImage:nil];
        
        if (_sign == 0) {
            if (_array == _topViewsArr) {
                [_topViewsArr removeObject:self];
                [_bottomViewsArr insertObject:self atIndex:_bottomViewsArr.count];
                _array = _bottomViewsArr;
                [self animationAction];
            }
            else if ( _array == _bottomViewsArr){
                [_bottomViewsArr removeObject:self];
                [_topViewsArr insertObject:self atIndex:_topViewsArr.count];
                _array = _topViewsArr;
                [self animationAction];
            }
        }
        
        else if (([self buttonInArrayArea1:_topViewsArr Point:point] || [self buttonInArrayArea2:_bottomViewsArr Point:point])&&!(point.x - _point.x > KTableStartPointX && point.x - _point.x < KTableStartPointX + KButtonWidth && point.y - _point.y > KTableStartPointY && point.y - _point.y < KTableStartPointY + KButtonHeight)){
            if (point.x < KTableStartPointX || point.y < KTableStartPointY) {
                [self setFrame:CGRectMake(_point2.x - _point.x, _point2.y - _point.y, self.frame.size.width, self.frame.size.height)];
            }
            else{
                [self setFrame:CGRectMake(KTableStartPointX + (a + KButtonWidth/2 - KTableStartPointX)/KButtonWidth*KButtonWidth, KTableStartPointY + (b + KButtonHeight/2 - KTableStartPointY)/KButtonHeight*KButtonHeight, self.frame.size.width, self.frame.size.height)];
            }
            
        }
        else{
            
            [self animationAction];
            
        }
        _sign = 0;
    }
    [self.label setBackgroundColor:[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0]];
    [self setImage:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    _sign = 1;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    //    if (![self.label.text isEqualToString:@"头条"])
    {
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self setImage:[UIImage imageNamed:@"order_drag_move_bg.png"]];
        [self setFrame:CGRectMake( point.x - _point.x, point.y - _point.y, self.frame.size.width, self.frame.size.height)];
        
        CGFloat newX = point.x - _point.x + KButtonWidth/2;
        CGFloat newY = point.y - _point.y + KButtonHeight/2;
        
//        if (!CGRectContainsPoint([[_topViewsArr objectAtIndex:0] frame], CGPointMake(newX, newY)) )
        {
            
            if ( _array == _bottomViewsArr) {
                
                if ([self buttonInArrayArea1:_topViewsArr Point:point]) {
                    
                    int index = ((int)newX - KTableStartPointX)/KButtonWidth + (BUTTON_PER_LINE * (((int)newY - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];
                    [_topViewsArr insertObject:self atIndex:index];
                    _array = _topViewsArr;
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if (newY < KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea1:_topViewsArr Point:point]){
                    
                    [ _array removeObject:self];
                    [_topViewsArr insertObject:self atIndex:_topViewsArr.count];
                    _array = _topViewsArr;
                    [self animationAction2];
                    
                }
                else if([self buttonInArrayArea2:_bottomViewsArr Point:point]){
                    unsigned long index = ((unsigned long )(newX) - KTableStartPointX)/KButtonWidth + (BUTTON_PER_LINE * (((int)(newY) - [self array2StartY] * KButtonHeight - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];
                    [_bottomViewsArr insertObject:self atIndex:index];
                    [self animationAction2a];
                    
                }
                else if(newY > KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea2:_bottomViewsArr Point:point]){
                    [ _array removeObject:self];
                    [_bottomViewsArr insertObject:self atIndex:_bottomViewsArr.count];
                    [self animationAction2a];
                    
                }
            }
            else if ( _array == _topViewsArr) {
                if ([self buttonInArrayArea1:_topViewsArr Point:point]) {
                    int index = ((int)newX - KTableStartPointX)/KButtonWidth + (BUTTON_PER_LINE * (((int)(newY) - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];
                    [_topViewsArr insertObject:self atIndex:index];
                    _array = _topViewsArr;
                    
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if (newY < KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea1:_topViewsArr Point:point]){
                    [ _array removeObject:self];
                    [_topViewsArr insertObject:self atIndex: _array.count];
                    [self animationAction1a];
                    [self animationAction2];
                }
                else if([self buttonInArrayArea2:_bottomViewsArr Point:point]){
                    unsigned long index = ((unsigned long)(newX) - KTableStartPointX)/KButtonWidth + (BUTTON_PER_LINE * (((int)(newY) - [self array2StartY] * KButtonHeight - KTableStartPointY)/KButtonHeight));
                    [ _array removeObject:self];
                    [_bottomViewsArr insertObject:self atIndex:index];
                    _array = _bottomViewsArr;
                    [self animationAction2a];
                }
                else if(newY > KTableStartPointY + [self array2StartY] * KButtonHeight &&![self buttonInArrayArea2:_bottomViewsArr Point:point]){
                    [ _array removeObject:self];
                    [_bottomViewsArr insertObject:self atIndex:_bottomViewsArr.count];
                    _array = _bottomViewsArr;
                    [self animationAction2a];
                    
                }
            }
        }
    }
}
- (void)animationAction1{
    for (int i = 0; i < _topViewsArr.count; i++) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_topViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
        } completion:^(BOOL finished){
            
        }];
    }
}
- (void)animationAction1a{
    for (int i = 0; i < _topViewsArr.count; i++) {
        if ([_topViewsArr objectAtIndex:i] != self) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                [[_topViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
            } completion:^(BOOL finished){
                
            }];
        }
    }
    
}
- (void)animationAction2{
    for (int i = 0; i < _bottomViewsArr.count; i++) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_bottomViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + [self array2StartY] * KButtonHeight + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
            
        } completion:^(BOOL finished){
            
        }];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + KButtonHeight * ([self array2StartY] - 1) + 22, self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        
    } completion:^(BOOL finished){
        
    }];
}
- (void)animationAction2a{
    for (int i = 0; i < _bottomViewsArr.count; i++) {
        if ([_bottomViewsArr objectAtIndex:i] != self) {
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                
                [[_bottomViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + [self array2StartY] * KButtonHeight + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
                
            } completion:^(BOOL finished){
            }];
        }
        
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + KButtonHeight * ([self array2StartY] - 1) + 22, self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        
    } completion:^(BOOL finished){
        
    }];
}
- (void)animationActionLabel{
    
}

- (void)animationAction{
    for (int i = 0; i < _topViewsArr.count; i++) {
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_topViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
        } completion:^(BOOL finished){
            
        }];
    }
    for (int i = 0; i < _bottomViewsArr.count; i++) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            [[_bottomViewsArr objectAtIndex:i] setFrame:CGRectMake(KTableStartPointX + (i%kMaxItemPerLine) * KButtonWidth, KTableStartPointY + [self array2StartY] * KButtonHeight + (i/kMaxItemPerLine)* KButtonHeight, KButtonWidth, KButtonHeight)];
            
        } completion:^(BOOL finished){
            
        }];
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [self.moreChannelsLabel setFrame:CGRectMake(self.moreChannelsLabel.frame.origin.x, KTableStartPointY + KButtonHeight * ([self array2StartY] - 1) + 22, self.moreChannelsLabel.frame.size.width, self.moreChannelsLabel.frame.size.height)];
        
    } completion:^(BOOL finished){
        
    }];
    
}

- (BOOL)buttonInArrayArea1:(NSMutableArray *)arr Point:(CGPoint)point{
    CGFloat newX = point.x - _point.x + KButtonWidth/2;
    CGFloat newY = point.y - _point.y + KButtonHeight/2;
    int a =  arr.count%kMaxItemPerLine;
    unsigned long b =  arr.count/kMaxItemPerLine;
    if ((newX > KTableStartPointX && newX < KTableStartPointX + kMaxItemPerLine * KButtonWidth && newY > KTableStartPointY && newY < KTableStartPointY + b * KButtonHeight) || (newX > KTableStartPointX && newX < KTableStartPointX + a * KButtonWidth && newY > KTableStartPointY + b * KButtonHeight && newY < KTableStartPointY + (b+1) * KButtonHeight) ) {
        return YES;
    }
    return NO;
}
- (BOOL)buttonInArrayArea2:(NSMutableArray *)arr Point:(CGPoint)point{
    CGFloat newX = point.x - _point.x + KButtonWidth/2;
    CGFloat newY = point.y - _point.y + KButtonHeight/2;
    int a =  arr.count%kMaxItemPerLine;
    unsigned long b =  arr.count/kMaxItemPerLine;
    if ((newX > KTableStartPointX && newX < KTableStartPointX + kMaxItemPerLine * KButtonWidth && newY > KTableStartPointY + [self array2StartY] * KButtonHeight && newY < KTableStartPointY + (b + [self array2StartY]) * KButtonHeight) || (newX > KTableStartPointX && newX < KTableStartPointX + a * KButtonWidth && newY > KTableStartPointY + (b + [self array2StartY]) * KButtonHeight && newY < KTableStartPointY + (b+[self array2StartY]+1) * KButtonHeight) ) {
        return YES;
    }
    return NO;
}
- (unsigned long)array2StartY{
    unsigned long y = 0;
    
    y = _topViewsArr.count/kMaxItemPerLine + 2;
    if (_topViewsArr.count%kMaxItemPerLine == 0) {
        y -= 1;
    }
    return y;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
