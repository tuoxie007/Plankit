//
//  HistoryViewController.m
//  Plankit
//
//  Created by Jason Hsu on 2018/9/10.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import "HistoryViewController.h"
#import "UIView+PLKFrame.h"

static NSString *identifier = @"PLKHistoryRecordCell";

@interface PLKRecord : NSObject

@property (nonatomic, assign) NSTimeInterval ago;
@property (nonatomic, copy) NSString *createTimeDesc;
@property (nonatomic, copy) NSString *durationDesc;
@property (nonatomic, assign) NSInteger duration;

@end

@implementation PLKRecord
@end

@interface PLKRecordCell : UITableViewCell

@property (nonatomic, assign) double progress;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *ago;

@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *agoLabel;
@property (nonatomic, strong) UIView *progressView;

@end

@implementation PLKRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.durationLabel];
        [self.contentView addSubview:self.agoLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.progressView.size = CGSizeMake(self.progress * 0.9 * self.contentView.width, self.contentView.height);

    self.durationLabel.text = self.duration;
    [self.durationLabel sizeToFit];
    self.durationLabel.leftBottom = CGPointMake(20, self.contentView.height - 20);

    self.agoLabel.text = self.ago;
    [self.agoLabel sizeToFit];
    self.agoLabel.left = self.durationLabel.right + 10;
    self.agoLabel.bottom = self.contentView.height - 20;
}

- (UILabel *)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [UILabel new];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:30];
    }
    return _durationLabel;
}

- (UILabel *)agoLabel
{
    if (!_agoLabel) {
        _agoLabel = [UILabel new];
        _agoLabel.textColor = [UIColor whiteColor];
        _agoLabel.font = [UIFont systemFontOfSize:12];
    }
    return _agoLabel;
}

- (UIView *)progressView
{
    if (!_progressView) {
        _progressView = [UIView new];
        _progressView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    }
    return _progressView;
}

@end

@interface HistoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *contentView;
@property (nonatomic, strong) NSArray<PLKRecord *> *records;
@property (nonatomic, assign) NSInteger maxDuration;

@end

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];

    UITableView *contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentView];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    PLKRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PLKRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    PLKRecord *record = self.records[indexPath.row];
    cell.duration = record.durationDesc;
    cell.ago = record.createTimeDesc;
    cell.progress = record.duration * 1.0 /  self.maxDuration;
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
                record.createTimeDesc = @"今天";
            } else {
                NSInteger days = ago / 3600 / 24;
                record.createTimeDesc = [NSString stringWithFormat:@"%ld天前", days];
            }
        }
        NSString *content = [[NSString alloc] initWithContentsOfURL:fileURL
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        if (content) {
            NSInteger duration = [content integerValue];
            if (duration >= 10) {
                record.duration = duration;
                record.durationDesc = [NSString stringWithFormat:@"%ld", duration];
                [records addObject:record];
                if (duration > self.maxDuration) {
                    self.maxDuration = duration;
                }
            }
        }
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
