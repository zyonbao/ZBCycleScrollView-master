//
//  ViewController.m
//  ZBCycleScrollView-master
//
//  Created by zyon on 15/10/14.
//  Copyright © 2015年 zyon. All rights reserved.
//

#import "ViewController.h"
#import "ZBCycleScrollView.h"

@interface ViewController ()<ZBCycleScrollViewDataSource,ZBCycleScrollViewDelegate>

@end

@implementation ViewController{
    ZBCycleScrollView *cycleView;
    NSInteger count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 1;
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    cycleView = [[ZBCycleScrollView alloc] initWithFrame:CGRectMake(0, 60, 320, 180)];
    cycleView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cycleView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    cycleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cycleView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cycleView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-84-[cycleView(120)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cycleView)]];
    cycleView.dataSource = self;
    cycleView.delegate = self;
    cycleView.indicatorHighlightColor = [UIColor cyanColor];
    cycleView.indicatorNormalDotColor = [UIColor whiteColor];
    
    UIButton *chageCount = [UIButton buttonWithType:UIButtonTypeCustom];
    [chageCount setTitle:@"点击刷新" forState:UIControlStateNormal];
    [chageCount setFrame:CGRectMake(0, 320, 320, 100)];
    [chageCount addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chageCount];
    
}

-(UIView *)cycleScrollView:(ZBCycleScrollView *)scrollView viewForPageAtIndex:(NSInteger)index{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:32.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%li",(long)index];
    return label;
}

- (NSString *)cycleScrollView:(ZBCycleScrollView *)scrollView titleForPageAtIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"This is the %lith page",(long)index];
}

-(NSInteger)numberOfPagesIncyCleScrollView {
    return count;
}
-(void)cycleScrollView:(ZBCycleScrollView *)scrollView didTapAtIndex:(NSInteger)index{
    NSLog(@"%li",(long)index);
}
- (void)btnClicked:(UIButton *)sender{
    count++;
    if (count > 4) {
        count = 1;
    }
    [cycleView reloadData];
}
@end
