//
//  BLListViewController.m
//  https://github.com/batkov/BLListViewController
//
// Copyright (c) 2016 Hariton Batkov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "BLListViewController+Subclass.h"
@import DateTools;
#import <QuartzCore/QuartzCore.h>

NSString * const kBLListViewControllerDefaultCellReuseIdentifier = @"kBLListViewControllerDefaultCellReuseIdentifier";
NSString * const kBLDataSourceLastUpdatedKey = @"lastUpdated_%@";

@implementation BLListViewController
@synthesize dataSource = _dataSource;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    self.invertPullToRefreshControllers = NO;
    self.pullToRefreshEnabled = YES;
    self.loadMoreEnabled = YES;
    self.fetchObjectsIfNeededOnDisplay = NO;
    self.objectsBeingFetched = [NSMutableArray array];
}

#pragma mark - View Lifecycle
- (void) viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self setupDataSource];
    
    // If dataSource does not have onwn error block
    // We use errorBlock from controller
    if (!self.dataSource.errorBlock) {
        self.dataSource.errorBlock = self.errorBlock;
    }
    [self startLoadingDataSource];
}

#pragma mark - Table
- (UIView *) parentViewForTable {
    return self.view;
}

- (void) initTableView {
    if (self.tableView) {
        return;
    }
    UIView * parentView = [self parentViewForTable];
    self.tableView = [[UITableView alloc] initWithFrame:parentView.bounds
                                                  style:[self preferredTableViewStyle]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:self.tableView];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                           attribute:NSLayoutAttributeTrailing
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeTrailing
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:0.0]];
    self.tableView.rowHeight = kBLListViewControllerDefaultCellHeight;
}

- (UITableViewStyle) preferredTableViewStyle {
    return UITableViewStylePlain;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configureRefreshController];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tableView.mj_header = nil;
    self.tableView.mj_footer = nil;
}

- (void) reloadItemsFromSource {
    [self.tableView reloadData];
}

- (void) configureRefreshController {
    __weak typeof(self) weakSelf = self;
    NSString * lastUpdated = [NSBundle mj_localizedStringForKey:MJRefreshHeaderLastTimeText];
    if (self.invertPullToRefreshControllers) {
        if ([self refreshAvailable]) {
            MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf pullToLoadMoreRaised];
            }];
            header.automaticallyChangeAlpha = YES;
            header.lastUpdatedTimeText =  ^(NSDate *lastUpdatedTime) {
                return lastUpdatedTime ? [NSString stringWithFormat:@"%@%@", lastUpdated, [NSDate timeAgoSinceDate:lastUpdatedTime]] : nil;
            };
            header.lastUpdatedTimeKey = [self lastUpdatedKey];
            
            self.tableView.mj_header = header;
        }
        if ([self loadMoreAvailable]) {
            MJRefreshBackNormalFooter * footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [weakSelf pullToRefreshRaised];
            }];
            footer.automaticallyChangeAlpha = YES;
            
            self.tableView.mj_footer = footer;
            self.tableView.mj_footer.hidden = YES;
        }
    } else {
        if ([self refreshAvailable]) {
            MJRefreshNormalHeader * header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf pullToRefreshRaised];
            }];
            header.automaticallyChangeAlpha = YES;
            
            header.lastUpdatedTimeText =  ^(NSDate *lastUpdatedTime) {
                return lastUpdatedTime ? [NSString stringWithFormat:@"%@%@", lastUpdated, [NSDate timeAgoSinceDate:lastUpdatedTime]] : nil;
            };
            header.lastUpdatedTimeKey = [self lastUpdatedKey];
            
            self.tableView.mj_header = header;
        }
        if ([self loadMoreAvailable]) {
            MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf pullToLoadMoreRaised];
            }];
            footer.automaticallyChangeAlpha = YES;
            
            self.tableView.mj_footer = footer;
            self.tableView.mj_footer.hidden = YES;
        }
    }
    
    [self dataSource:self.dataSource stateChanged:self.dataSource.state];
    
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [self.view.layer removeAllAnimations];
    });
}

- (BLListDataSource *) dataSource {
    if (!_dataSource) {
        [self setupDataSource];
    }
    return _dataSource;
}

- (void) setupDataSource {
    if (!_dataSource) {
        self.dataSource = [self createDataSource];
        NSAssert(self.dataSource, @"You need to implement - createDataSource");
    }
    if (self.dataSource.itemsChangedBlock) {
        NSLog(@"setupDataSource dataSource provided with itemsChangedBlock.\nDo not forget to reload items in it.");
    } else {
        __weak typeof(self) weakSelf = self;
        self.dataSource.itemsChangedBlock = ^(id  _Nullable object) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadItemsFromSource];
            });
        };
    }
   
}

- (void) startLoadingDataSource {
    // Actual case when controller receives dataSource with existing data
    if (self.dataSource.state == BLDataSourceStateContent
        || self.dataSource.state == BLDataSourceStateNoContent) {
        [self.tableView reloadData];
    } else {
        [self.dataSource startContentLoading];
    }
}

#pragma mark -
- (void) pullToRefreshRaised {
    [self.dataSource refreshContentIfPossible];
}

- (void) pullToLoadMoreRaised {
    [self.dataSource loadMoreIfPossible];
}

- (void) dealloc {
    self.dataSource = nil;
}

#pragma mark - Data Source
- (void) setDataSource:(BLListDataSource *)dataSource {
    // Cleanup callbacks from previous data source
    id block = _dataSource.itemsChangedBlock;
    _dataSource.delegate = nil;
    _dataSource.itemsChangedBlock = nil;
    
    _dataSource = dataSource;
    
    // setup callback for new dataSource
    _dataSource.delegate = self;
    if (!_dataSource.itemsChangedBlock && block) {
        _dataSource.itemsChangedBlock = block;
    }
}

- (void) dataSource:(BLDataSource *)dataSource stateChanged:(BLDataSourceState)state {
    switch (state) {
        case BLDataSourceStateInit:
        case BLDataSourceStateLoadContent:
            break;
        case BLDataSourceStateError:
            [self showError];
            break;
        case BLDataSourceStateNoContent:
            [self showNoContent];
            break;
        case BLDataSourceStateRefreshContent:
            [self showRefreshing];
            break;
        case BLDataSourceStateContent:
            [self showContent];
            break;
    }
}

#pragma mark - TableView
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource.dataStructure sectionsCount];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource.dataStructure itemsCountForSection:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    NSAssert(reuseIdentifier, @"Cannot handle nil value of reuseIdentifierForIndexPath:");
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [self createCellForIndexPath:indexPath];
        NSAssert(cell, @"Cannot handle nil value of createCellForIndexPath:");
    }
    [self customizeCell:cell forIndexPath:indexPath];
    [self preFetchObjectAt:indexPath];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.rowHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self cellSelectedAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) updateItemAtIndexPath:(NSIndexPath *) indexPath {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BLListDataSource *) createDataSource {
    NSAssert(self.fetch, @"You need to provide fetch before -createDataSource called");
    return [[BLListDataSource alloc] initWithFetch:self.fetch]; // For subclassing
}

- (UITableViewCell *) createCellForIndexPath:(NSIndexPath *) indexPath {
    NSString * reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:reuseIdentifier]; // For subclassing
}

- (NSString *) reuseIdentifierForIndexPath:(NSIndexPath *) indexPath {
    return kBLListViewControllerDefaultCellReuseIdentifier; // For subclassing
}

#pragma mark - Abstract Methods
- (void) customizeCell:(UITableViewCell *) cell forIndexPath:(NSIndexPath *) indexPath {
    // Do nothing. For subclassing
#ifdef DEBUG
    id<BLDataObject> object = [self.dataSource.dataStructure objectForIndexPath:indexPath];
    cell.textLabel.text = object.objectId;
#endif
}

- (void) cellSelectedAtIndexPath:(NSIndexPath *) indexPath {
    
}

#pragma mark -
-(void) preFetchObjectAt:(NSIndexPath *)indexPath {
    if (!self.fetchObjectsIfNeededOnDisplay) {
        return;
    }
    id<BLDataObject> objectToFetch = [self.dataSource.dataStructure objectForIndexPath:indexPath];
    BOOL isAdataAvailable = YES;
    if ([objectToFetch respondsToSelector:@selector(isAllDataAvailable)]) {
        isAdataAvailable = [objectToFetch isAllDataAvailable];
    } else if ([objectToFetch respondsToSelector:@selector(isDataAvailable)]) {
        isAdataAvailable = [objectToFetch isDataAvailable];
    }
    // Object said that everything fetched
    if (isAdataAvailable) {
        return;
    }
    NSString * objectId = objectToFetch.objectId;
    // Object does not saved on server or already fetching
    if (objectId &&
        [self.objectsBeingFetched containsObject:objectId]) {
        return;
    }
    __weak typeof(self) selff  = self;
    [self.objectsBeingFetched addObject:objectId];
    [self.dataSource fecthObject:objectToFetch callback:^(id  _Nullable object, NSError * _Nullable error) {
        [selff.objectsBeingFetched removeObject:objectId];
        if (error) {
            if (self.errorBlock) {
                self.errorBlock(error, kBLErrorSourceFetchObject);
            }
            return;
        }
        NSIndexPath * indexPath = [selff.dataSource.dataStructure indexPathForObject:objectToFetch];
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            if (indexPath && [selff.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
                UITableViewCell * cell = [selff.tableView cellForRowAtIndexPath:indexPath];
                [selff customizeCell:cell forIndexPath:indexPath];
            }
        });
    }];
}

#pragma mark - Top Info
- (BOOL) shouldShowContent {
    return ![self.dataSource hasContent];
}

- (void) showLoading {
    MJRefreshFooter * footer = self.tableView.mj_footer;
    MJRefreshHeader * header = self.tableView.mj_header;
    if (self.invertPullToRefreshControllers) {
        if (!footer.isRefreshing && !header.isRefreshing)
            [footer beginRefreshing];
        if ([footer isRefreshing])
            header.hidden = YES;
    } else {
        if (!header.isRefreshing && !footer.isRefreshing)
            [header beginRefreshing];
        if ([header isRefreshing])
            footer.hidden = YES;
    }
}

- (void) showNoContent {
    [self stopLoading:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self lastUpdatedKey]];
    if (self.invertPullToRefreshControllers) {
        self.tableView.mj_header.hidden = YES;
    } else {
        self.tableView.mj_footer.hidden = YES;
    }
}

- (void) showError {
    [self stopLoading:NO];
    if (self.invertPullToRefreshControllers) {
        self.tableView.mj_header.hidden = YES;
    } else {
        self.tableView.mj_footer.hidden = YES;
    }
}

- (void) showContent {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[self lastUpdatedKey]];
    [self stopLoading:YES];
}

- (void) showRefreshing {
    if (![self.tableView.mj_header isRefreshing]) {
        self.tableView.mj_header.hidden = YES;
    } else {
        self.tableView.mj_footer.hidden = YES;
    }
}

- (void) stopLoading:(BOOL) updateTime {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        self.tableView.mj_footer.hidden = NO;
        self.tableView.mj_header.hidden = NO;
        if (self.invertPullToRefreshControllers) {
            if ([self.dataSource canLoadMore] ) {
                self.tableView.mj_header.state = MJRefreshStateIdle;
            } else {
                self.tableView.mj_header.state = MJRefreshStateNoMoreData;
            }
        } else {
            if ([self.dataSource canLoadMore] ) {
                [self.tableView.mj_footer resetNoMoreData];
            } else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    });
}

- (BOOL) loadMoreAvailable {
    return self.loadMoreEnabled && self.dataSource.pagingEnabled;
}

- (BOOL) refreshAvailable {
    return self.pullToRefreshEnabled;
}

- (NSString *) lastUpdatedKey {
    return [NSString stringWithFormat:kBLDataSourceLastUpdatedKey, NSStringFromClass([self class])];
}

@end

