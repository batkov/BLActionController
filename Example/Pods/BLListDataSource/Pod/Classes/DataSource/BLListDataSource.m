//
//  BLListDataSource.m
//  https://github.com/batkov/BLDataSource
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

#import "BLListDataSource+Subclass.h"
#import "BLSimpleListFetchResult.h"

#define kBLParseListDefaultPagingLimit 25


@implementation BLListDataSource

- (instancetype) initWithFetch:(id<BLBaseFetch>) fetch {
    if (self = [super initWithFetch:fetch]) {
        [self commonInit];
    }
    return self;
}

- (instancetype) initWithFetch:(id<BLBaseFetch>) fetch update:(id<BLBaseUpdate>) update {
    if (self = [super initWithFetch:fetch update:update]) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    self.storagePolicy = self.update ? BLOfflineFirstPage : BLOfflineDoNotStore;
    self.pagingEnabled = YES;
    self.autoAdvance = NO;
    self.defaultPageSize = kBLParseListDefaultPagingLimit;
}

- (BLPaging *) paging {
    if (!self.pagingEnabled) {
        return nil;
    }
    if (!_paging) {
        BLMutablePaging * paging = [BLMutablePaging new];
        paging.skip = 0;
        paging.limit = self.defaultPageSize;
        _paging = [BLPaging pagingFromPaging:paging];
    }
    return _paging;
}

- (BOOL) hasContent {
    return [self.dataStructure hasContent];
}

- (BOOL) shouldCleanContentBeforeProcessOnlineItems {
    if (!self.pagingEnabled) {
        return YES;
    }
    return self.paging && self.paging.skip == 0;
}

-(BOOL)shouldRemoveStoredItemsBeforeSavingNew {
    return self.storagePolicy == BLOfflineFirstPage && [self shouldCleanContentBeforeProcessOnlineItems];
}

- (void) updatePagingFlagsForListSize {
    if (!self.pagingEnabled) {
        return;
    }
    NSUInteger size = [self.dataStructure dataSize];
    self.canLoadMore = self.paging.skip + self.paging.limit <= size;
    BLMutablePaging * paging = [BLMutablePaging pagingFromPaging:self.paging];
    paging.skip = size;
    self.paging = paging;
}

- (void) cleanContent {
    self.dataStructure = nil;
}

- (void) resetData {
    self.canLoadMore = YES;
    self.paging = nil;
    self.dataStructure = nil;
}

- (void) loadNextPageIfNeeded {
    if (!self.canLoadMore)
        return;
    if (self.state != BLDataSourceStateContent)
        return;
    [self startContentRefreshing];
}

- (BOOL) shouldStoreFetchedData {
    if (self.storagePolicy == BLOfflineFirstPage) {
        return [self shouldCleanContentBeforeProcessOnlineItems];
    }
    return self.storagePolicy == BLOfflineAllData;
}

- (void) loadNextPageIfAutoAdvance {
    if (!self.autoAdvance) {
        return;
    }
    if (!self.pagingEnabled) {
        return;
    }
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [self loadNextPageIfNeeded];
    });
}

-(void)contentLoaded:(NSError *)error {
    [super contentLoaded:error];
    [self loadNextPageIfAutoAdvance];
}

- (BOOL) refreshContentIfPossible {
    NSAssert(self.state != BLDataSourceStateInit, @"We actually shouldn't be here");
    if (self.state == BLDataSourceStateLoadContent || self.state == BLDataSourceStateRefreshContent) {
        return NO;
    }
    self.paging = nil;
    [self startContentRefreshing];
    return YES;
}

- (BOOL) loadMoreIfPossible {
    NSAssert(self.state != BLDataSourceStateInit, @"We actually shouldn't be here");
    if (self.state != BLDataSourceStateContent) {
        return NO;
    }
    // We shouldn't check here for canLoadMore
    // Case user awaits for next item to appear
    // and swipe reload from bottom
    [self startContentRefreshing];
    return YES;
}

- (void) processFetchResult:(BLBaseFetchResult *) fetchResult {
    if (!self.dataStructure) {
        self.dataStructure = [self dataStructureFromFetchResult:fetchResult];
    } else {
        [self.dataStructure processFetchResult:fetchResult];
    }
    self.dataStructure.changedBlock = self.itemsChangedBlock;
    if (self.itemsChangedBlock) {
        self.itemsChangedBlock (self.dataStructure);
    }
    if (!fetchResult.isLocal) {
        // Update flags only if we fetching online data
        [self updatePagingFlagsForListSize];
    }
    [self loadNextPageIfAutoAdvance];
}

- (BLDataStructure *) dataStructureFromFetchResult:(BLBaseFetchResult *) fetchResult {
    if (self.dataStructureBlock) {
        NSAssert(self.dataSortingBlock == nil, @"dataSortingBlock is ignored if you are using dataStructureBlock");
        BLDataStructure * dataStructure = self.dataStructureBlock(fetchResult);
        NSAssert([dataStructure isKindOfClass:[BLDataStructure class]], @"Wrong class or nil");
        return dataStructure;
    }
    if (self.dataSortingBlock) {
        BLDataSorting sorting = self.dataSortingBlock(fetchResult);
        return [BLDataStructure dataStructureWithFetchResult:fetchResult
                                                     sorting:sorting
                                                       block:self.customSortingBlock];
    }
    return [BLDataStructure dataStructureWithFetchResult:fetchResult];
}

#pragma mark -
-(NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\nDataStructure: %@\nPaging: %@", [super debugDescription], [self.dataStructure debugDescription], [self.paging debugDescription]];
}

@end
