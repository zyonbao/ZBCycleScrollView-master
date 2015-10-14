//
//  ZBDotPageControl.m
//  ZBCycleScrollView
//
//  Created by gamedog on 15/6/18.
//  Copyright (c) 2015年 gamedog. All rights reserved.
//

#import "ZBDotPageControl.h"


#define dotSize 11

@implementation ZBDotPageControl


-(void) updateDots

{
    for (int i=0; i<[self.subviews count]; i++) {
        
        UIView *dot = [self.subviews objectAtIndex:i];
        //自定义圆点的大小
        
        [dot setBounds:CGRectMake(0, 0, dotSize, dotSize)];
        [dot.layer setCornerRadius:dotSize/2];
        [dot setClipsToBounds:YES];
        if (i==self.currentPage)dot.backgroundColor=_dotColor ? _dotColor : [UIColor cyanColor];
        else dot.backgroundColor = [UIColor whiteColor];;
    }
    
}

-(void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self updateDots];
}

-(void)setDotColor:(UIColor *)dotColor{
    if (_dotColor != dotColor) {
        _dotColor = dotColor;
        [self updateDots];
    }
}

@end
