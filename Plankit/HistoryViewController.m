//
//  HistoryViewController.m
//  Plankit
//
//  Created by Jason Hsu on 2018/9/10.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import "HistoryViewController.h"

static NSString *identifier = @"PLKHistoryRecordCell";

@interface PLKRecord : NSObject

@property (nonatomic, assign) NSTimeInterval ago;
@property (nonatomic, copy) NSString *createTimeDesc;
@property (nonatomic, copy) NSString *durationDesc;

@end

@implementation PLKRecord
@end

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *contentView;
@property (nonatomic, strong) NSArray<PLKRecord *> *records;

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];

    UITableView *contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentView];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.delegate = self;
    contentView.dataSource = self;
    self.contentView = contentView;

    [self reloadHistory];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHistory)
                                                 name:@"PLKHistoryChanged"
                                               object:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.records.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:30];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    PLKRecord *record = self.records[indexPath.row];
    cell.textLabel.text = record.durationDesc;
    cell.detailTextLabel.text = record.createTimeDesc;
    return cell;
}

- (void)reloadHistory
{
    NSURL *docPath = [self applicationDocumentsDirectory];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:docPath
                                                   includingPropertiesForKeys:@[]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:nil];
    NSMutableArray *records = [NSMutableArray array];
    for (NSInteger i=files.count - 1; i >= 0; i--) {
        NSURL *fileURL = files[i];
        NSString *filename = [fileURL lastPathComponent];
        PLKRecord *record = [PLKRecord new];
        if ([filename hasSuffix:@".txt"]) {
            NSTimeInterval ago = CFAbsoluteTimeGetCurrent() - [[[filename componentsSeparatedByString:@"."] firstObject] doubleValue];
            record.ago = ago;
            if (ago < 0) {
                continue;
            }
            if (ago < 24 * 3600) {
                record.createTimeDesc = @"最近";
            } else {
                NSInteger days = ago / 3600 * 24;
                record.createTimeDesc = [NSString stringWithFormat:@"%ld天前", days];
            }
        }
        NSString *content = [[NSString alloc] initWithContentsOfURL:fileURL
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        if (content) {
            record.durationDesc = [NSString stringWithFormat:@"%ld", [content integerValue]];
        }
        [records addObject:record];
    }
    [records sortUsingComparator:^NSComparisonResult(PLKRecord * _Nonnull r1, PLKRecord * _Nonnull r2) {
        return r1.ago - r2.ago;
    }];
    self.records = records;
    [self.contentView reloadData];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
