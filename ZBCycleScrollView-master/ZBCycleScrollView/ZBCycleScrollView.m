//
//  ZBCycleScrollView.m
//  ZBCycleScrollView
//
//  Created by zyon on 15/10/8.
//  Copyright © 2015年 zyon. All rights reserved.
//

#import "ZBCycleScrollView.h"
#import "ZBDotPageControl.h"

#define DEFAULT_TIME_INTERVAL 3.0f
#define FRONT_BAR_HEIGHT_RATIO 6.0f //greater smaller

@interface ZBCycleScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *containerArray;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) NSTimeInterval timeInterVal;
@property (nonatomic, strong) NSTimer *animationTimer;

@property (nonatomic , strong) ZBDotPageControl *indicator;

@end

@implementation ZBCycleScrollView{
    
    NSInteger _containerOneIndex;//containerOne页面所对应的总index
    NSInteger _totalPageCount;
    UIView *_frontBar;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeConfig];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeConfig];
    }
    return self;
}

- (void)initializeConfig{
    
    self.backgroundColor = [UIColor clearColor];
    _scrollView = [[UIScrollView alloc] init];
    _containerArray = @[[[UIView alloc] init],[[UIView alloc] init],[[UIView alloc] init],[[UIView alloc] init],[[UIView alloc] init]];
    
    [self addSubview:_scrollView];
    for (UIView *container in _containerArray) {
        [_scrollView addSubview:container];
    }
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)];
    [_scrollView addGestureRecognizer:_tapRecognizer];
    _containerOneIndex = 0;
    _style = kCycleScrollStyleBarCoverOnView;
    
    
    _frontBar = [UIView new];
    [self addSubview:_frontBar];
    self.indicator = [[ZBDotPageControl alloc] init];
    [_frontBar addSubview:self.indicator];
    
}

- (void)updateConstraints{
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    for (UIView *container in _containerArray) {container.translatesAutoresizingMaskIntoConstraints = NO;}
    _frontBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_frontBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_frontBar)]];
    if (kCycleScrollStyleBarCoverOnView == _style) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_frontBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_frontBar)]];
    }else if (kCycleScrollStyleBarSeparatedFromView == _style){
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView][_frontBar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_scrollView, _frontBar)]];
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_frontBar attribute:NSLayoutAttributeHeight multiplier:FRONT_BAR_HEIGHT_RATIO constant:0.0f]];
    
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerZero][containerOne][containerTwo][containerThree][containerFour]|" options:0 metrics:nil views:@{@"containerZero":_containerArray[0],@"containerOne":_containerArray[1],@"containerTwo":_containerArray[2],@"containerThree":_containerArray[3],@"containerFour":_containerArray[4]}]];
    
    for (UIView *container in _containerArray) {
        [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[container]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(container)]];
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeHeight multiplier:1.0f constant:CGFLOAT_MIN]];
        [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeWidth multiplier:1.0f constant:CGFLOAT_MIN]];
    }
    
    /**
     *  FrontBar Constraints
     */
    _indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [_frontBar addConstraint:[NSLayoutConstraint constraintWithItem:_frontBar attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_indicator attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:CGFLOAT_MIN]];
    [_frontBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_indicator]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_indicator)]];
    [super updateConstraints];
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    _frontBar.backgroundColor = _frontBarColor ? _frontBarColor:[UIColor colorWithWhite:0.0/255.0 alpha:0.7];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    self.indicator.currentPage = 0;
    [self reloadData];
    
    if (_autoScrollTimeInterval>0){
        _timeInterVal = _autoScrollTimeInterval;
        
    }else{
        _timeInterVal = DEFAULT_TIME_INTERVAL;
    }
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterVal
                                                       target:self
                                                     selector:@selector(animationTimerDidFired:)
                                                     userInfo:nil
                                                      repeats:YES];
}

#pragma mark - reload data
- (void)reloadData{
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesIncyCleScrollView)]) {
        NSInteger newTotalCount = [_dataSource numberOfPagesIncyCleScrollView];
        
        self.indicator.numberOfPages = newTotalCount;
        
        if(_totalPageCount < 1) _totalPageCount = newTotalCount;
        
        if ([_dataSource respondsToSelector:@selector(cycleScrollView:viewForPageAtIndex:)])
        {
            NSInteger pageCount = round(_scrollView.contentOffset.x/_scrollView.frame.size.width)-1;
            if (self.currentIndex >= newTotalCount) {
                _containerOneIndex = [self getpageWithIndex:newTotalCount - 1 - pageCount withTotalCount:newTotalCount];
                _totalPageCount = newTotalCount;
            }else{
                _containerOneIndex = [self getpageWithIndex:self.currentIndex - pageCount withTotalCount:newTotalCount];
                _totalPageCount = newTotalCount;
            }
            [self loadContainerView];
        }else{
            _totalPageCount = 0;
            self.indicator.numberOfPages = 0;
            [self loadContainerView];
        }
    }
}

#pragma mark - fill the containers
- (void)loadContainerView{
    if (_totalPageCount == 0){
        for (UIView *container in _containerArray) [self configView:[UIView new] inContainerView:container];
        return;
    }
    for (NSInteger i = 0; i < _containerArray.count; i++) {
        [self configView:[_dataSource cycleScrollView:self viewForPageAtIndex:[self getpageWithIndex:_containerOneIndex+i-1 withTotalCount:_totalPageCount]] inContainerView:_containerArray[i]];
    }
    _indicator.currentPage = self.currentIndex;
}

#pragma mark - Calculate The start Index
- (NSInteger)getpageWithIndex:(NSInteger)index withTotalCount:(NSInteger)totalCount{
    if (0 == totalCount) {
        return 0;
    }
    if(index < 0){
        return totalCount+index%totalCount >= 0 ? totalCount+index%totalCount : [self getpageWithIndex:totalCount+index%totalCount withTotalCount:totalCount];
    }
    if (index >= _totalPageCount) {
        return index%totalCount < totalCount ? index%totalCount : [self getpageWithIndex:index%totalCount withTotalCount:totalCount];
    }
    return index;
}

#pragma mark - put the pageView into containerView
- (void)configView:(UIView*)pageView inContainerView:(UIView*)container{
    if (container.subviews.count>0) { [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; }
    [container addSubview:pageView];
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pageView)]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pageView)]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (_scrollView.contentOffset.x > _scrollView.frame.size.width * 3.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex += 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }else if (_scrollView.contentOffset.x < _scrollView.frame.size.width * 0.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 3, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex -= 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (_scrollView.contentOffset.x > _scrollView.frame.size.width * 3.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex += 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }else if (_scrollView.contentOffset.x < _scrollView.frame.size.width * 0.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 3, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex -= 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (![_animationTimer isValid]) {
        return ;
    }
    [self pauseTimer];
    
    if (_scrollView.contentOffset.x > _scrollView.frame.size.width * 3.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - _scrollView.frame.size.width * 3, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex += 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }else if (_scrollView.contentOffset.x < _scrollView.frame.size.width * 0.5) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 3 +_scrollView.contentOffset.x, 0)];
        _containerOneIndex = [self getpageWithIndex:_containerOneIndex -= 3 withTotalCount:_totalPageCount];
        [self loadContainerView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _indicator.currentPage = self.currentIndex;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self resumeTimerAfterTimeInterval:_timeInterVal];
    
}

#pragma mark - tap event handler
- (void)contentTapped:(UITapGestureRecognizer *)sender{
    CGFloat pointX = [sender locationInView:sender.view].x;
    NSInteger tapIndex = _containerOneIndex + (long)[@(pointX/_scrollView.frame.size.width) integerValue] - 1;
    if ([_delegate respondsToSelector:@selector(cycleScrollView:didTapAtIndex:)]) {
        [_delegate cycleScrollView:self didTapAtIndex:tapIndex];
    }
}

#pragma mark - Event for the timer
- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame), 0);
    [_scrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - animation timer method
- (void)pauseTimer
{
    if (![_animationTimer isValid]) {
        return ;
    }
    [_animationTimer setFireDate:[NSDate distantFuture]];
}


- (void)resumeTimer
{
    if (![_animationTimer isValid]) {
        return ;
    }
    [_animationTimer setFireDate:[NSDate date]];
}

- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval
{
    if (![_animationTimer isValid]) {
        return ;
    }
    [_animationTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
}
#pragma mark - setters & getters

- (void)setFrontBarColor:(UIColor *)frontBarColor{
    if (_frontBarColor != frontBarColor) {
        _frontBarColor = frontBarColor;
        _frontBar.backgroundColor = _frontBarColor;
    }
}

- (void)setIndicatorTintColor:(UIColor *)indicatorTintColor{
    if (_indicatorTintColor != indicatorTintColor) {
        _indicatorTintColor = indicatorTintColor;
        _indicator.dotColor = _indicatorTintColor;
    }
}

-(NSInteger)currentIndex{
    
    return [self getpageWithIndex:_containerOneIndex + round(_scrollView.contentOffset.x/_scrollView.frame.size.width) - 1 withTotalCount:_totalPageCount];
}



@end
