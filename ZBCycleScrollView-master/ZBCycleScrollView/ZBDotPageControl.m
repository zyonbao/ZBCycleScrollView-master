//
//  ZBDotPageControl.m
//  ZBCycleScrollView
//
//  Created by gamedog on 15/6/18.
//  Copyright (c) 2015年 gamedog. All rights reserved.
//

#import "ZBDotPageControl.h"


#define dotSize 10

@implementation ZBDotPageControl


- (void) updateDots{
    for (UIView *dot in self.subviews) {
        [dot setBounds:CGRectMake(0, 0, dotSize, dotSize)];
        [dot.layer setCornerRadius:dotSize/2];
        [dot setClipsToBounds:YES];
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

@end
