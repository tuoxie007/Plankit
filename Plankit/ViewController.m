//
//  ViewController.m
//  Plankit
//
//  Created by Jason Hsu on 2018/9/9.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import "ViewController.h"
#import "DashboardViewController.h"
#import "HistoryViewController.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:contentView];
    contentView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, self.view.bounds.size.height);
    contentView.pagingEnabled = YES;
    contentView.delegate = self;
    
    DashboardViewController *dashboard = [[DashboardViewController alloc] init];
    [self addChildViewController:dashboard];
    [contentView addSubview:dashboard.view];
    
    HistoryViewController *history = [[HistoryViewController alloc] init];
    [self addChildViewController:history];
    [contentView addSubview:history.view];
    CGRect f = dashboard.view.frame;
    f.origin = CGPointMake(self.view.bounds.size.width, 0);
    history.view.frame = f;

    UIPageControl *pager = [[UIPageControl alloc] init];
    pager.numberOfPages = 2;
    [pager sizeToFit];
    pager.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - pager.bounds.size.height - 10);
    [self.view addSubview:pager];
    pager.tintColor = [UIColor whiteColor];
    self.pager = pager;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger num = scrollView.contentOffset.x / self.view.bounds.size.width;
    if (num != self.pager.currentPage) {
        self.pager.currentPage = num;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
