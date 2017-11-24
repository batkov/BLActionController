//
//  BLListDataSource.h
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

#import "BLInteractiveDataSource.h"
#import "BLDataStructure.h"
#import "BLBaseFetch.h"
#import "BLPaging.h"
#import "BLBaseFetchResult.h"
#import "BLBaseUpdate.h"

typedef NS_ENUM(NSInteger, BLOfflineStoragePolicy) {
    BLOfflineFirstPage,
    BLOfflineAllData,
    BLOfflineDoNotStore
};
typedef BLDataStructure* __nonnull(^BLDataStructureBlock)(BLBaseFetchResult * __nonnull fetchResult);
typedef BLDataSorting(^BLDataSortingBlock)(BLBaseFetchResult * __nonnull fetchResult);

@interface BLListDataSource : BLInteractiveDataSource

@property (nonatomic, strong, readonly, nullable) BLDataStructure * dataStructure;

@property (nonatomic, assign) BOOL pagingEnabled; // YES by default
@property (nonatomic, strong, readonly, nullable) BLPaging * paging;
@property (nonatomic, assign, readonly) BOOL canLoadMore; // YES by default
@property (nonatomic, assign) NSInteger defaultPageSize; // 25 by default

// BLOfflineFirstPage by default if 'update' is set
// BLOfflineDoNotStore by default if 'update' not set
@property (nonatomic, assign) BLOfflineStoragePolicy storagePolicy;

@property (nonatomic, copy, nullable) BLObjectBlock itemsChangedBlock;

@property (nonatomic, copy, nullable) BLDataStructureBlock dataStructureBlock; // Will return instance of BLDataStructure by default

// Both dataSortingBlock and customSortingBlock ignored if dataStructureBlock is set
// You need to provide own sorting into dataStructureBlock
@property (nonatomic, copy, nullable) BLDataSortingBlock dataSortingBlock; // BLDataSortingCreatedAt by default
@property (nonatomic, copy, nullable) BLCustomSortingBlock customSortingBlock; // You need to return BLDataSortingSortingCustom in dataSortingBlock id you want to use

/**
 If YES, will start loading next page right after previous page completed loading.
 Default is NO.
 */
@property (assign, nonatomic) BOOL autoAdvance;

- (__nonnull instancetype) init NS_UNAVAILABLE;
- (__nonnull instancetype) new NS_UNAVAILABLE;
- (__nonnull instancetype) initWithFetch:(id<BLBaseFetch> __nonnull) fetch NS_DESIGNATED_INITIALIZER;
- (__nonnull instancetype) initWithFetch:(id <BLBaseFetch> __nonnull) fetch update:(id <BLBaseUpdate> __nullable) update NS_DESIGNATED_INITIALIZER;

// Will start content loading if state allows
// Loaded content will be added as second page
- (BOOL) loadMoreIfPossible;

@end
