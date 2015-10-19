//
//  ZBCycleScrollView.h
//  ZBCycleScrollView
//
//  Created by zyon on 15/10/8.
//  Copyright © 2015年 zyon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBCycleScrollViewDelegate;
@protocol ZBCycleScrollViewDataSource;

typedef NS_ENUM(NSInteger, CycleScrollStyle){
    kCycleScrollStyleBarCoverOnView = 0,
    kCycleScrollStyleBarSeparatedFromView
};

@interface ZBCycleScrollView : UIView

@property (nonatomic, assign, readonly) NSInteger currentIndex;
@property (nonatomic) NSTimeInterval autoScrollTimeInterval;
@property (nonatomic) CycleScrollStyle style;
@property (nonatomic) UIColor *frontBarColor;
@property (nonatomic) UIColor *titleTextColor;
@property (nonatomic) UIColor *indicatorHighlightColor;
@property (nonatomic) UIColor *indicatorNormalDotColor;

@property (nonatomic, weak) id<ZBCycleScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<ZBCycleScrollViewDelegate> delegate;

- (void)reloadData;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;

@end


@protocol ZBCycleScrollViewDataSource  <NSObject>

- (NSInteger)numberOfPagesIncyCleScrollView;
- (UIView *)cycleScrollView:(ZBCycleScrollView*)scrollView viewForPageAtIndex:(NSInteger)index;
- (NSString *)cycleScrollView:(ZBCycleScrollView*)scrollView titleForPageAtIndex:(NSInteger)index;

@end

@protocol ZBCycleScrollViewDelegate<NSObject>

- (void)cycleScrollView:(ZBCycleScrollView*)scrollView didTapAtIndex:(NSInteger)index;

@end