//
//  DashboardViewController.m
//  Plankit
//
//  Created by Jason Hsu on 2018/9/10.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import "DashboardViewController.h"

@interface DashboardViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval launchTime;
@property (nonatomic, assign) NSTimeInterval time;

@end

@implementation DashboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
    
    UIButton *launchButton = [[UIButton alloc] init];
    [launchButton setTitle:@"启动" forState:UIControlStateNormal];
    [launchButton setTitle:@"停止" forState:UIControlStateSelected];
    [launchButton addTarget:self action:@selector(launch:) forControlEvents:UIControlEventTouchUpInside];
    launchButton.titleLabel.font = [UIFont systemFontOfSize:20];
    launchButton.frame = CGRectMake(0, 0, 125, 43);
    launchButton.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height * 0.8);
    [self.view addSubview:launchButton];
    launchButton.layer.borderWidth = 1;
    launchButton.layer.borderColor = [UIColor whiteColor].CGColor;
    launchButton.layer.cornerRadius = 10;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    timeLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - 50);
    [self.view addSubview:timeLabel];
    timeLabel.tag = 1;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.text = @"0";
    timeLabel.font = [UIFont systemFontOfSize:40];
}

- (void)launch:(UIButton *)button
{
    if (!button.selected) {
        self.launchTime = CFAbsoluteTimeGetCurrent();
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            weakSelf.time = CFAbsoluteTimeGetCurrent();
            UILabel *timeLabel = [weakSelf.view viewWithTag:1];
            timeLabel.text = [NSString stringWithFormat:@"%.1f", weakSelf.time - weakSelf.launchTime];
        }];
        [button setSelected:YES];
    } else {
        NSTimeInterval duration = self.time - self.launchTime;
        NSURL *docPath = [self applicationDocumentsDirectory];
        NSString *filename = [NSString stringWithFormat:@"%ld.txt", (long)self.launchTime];
        NSURL *fileURL = [docPath URLByAppendingPathComponent:filename];
        NSError *err = nil;
        [[NSString stringWithFormat:@"%ld", (long)duration] writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&err];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PLKHistoryChanged" object:nil];

        [button setSelected:NO];
        [self.timer invalidate];
        self.timer = nil;
        self.launchTime = 0;
        self.time = 0;
        
        if (err) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Write file failed." message:fileURL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [button setTitle:@"已保存" forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [button setTitle:@"启动" forState:UIControlStateNormal];
        });
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
