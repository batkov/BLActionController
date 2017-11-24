//
//  BLDataStructure.h
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

#import <Foundation/Foundation.h>
#import "BLDataKeys.h"
#import "BLDataObject.h"

@class BLBaseFetchResult;

@interface BLDataStructure : NSObject

+ (__nonnull instancetype) dataStructureWithFetchResult:(BLBaseFetchResult * _Nonnull) fetchResult;
+ (__nonnull instancetype) dataStructureWithFetchResult:(BLBaseFetchResult * _Nonnull) fetchResult sorting:(BLDataSorting) sorting;
+ (__nonnull instancetype) dataStructureWithFetchResult:(BLBaseFetchResult * _Nonnull) fetchResult sorting:(BLDataSorting) sorting block:(BLCustomSortingBlock _Nullable ) block;

- (void) processFetchResult:(BLBaseFetchResult *_Nonnull) fetchResult;

@property (nonatomic, assign, readonly) BLDataSorting sorting; // BLDataSortingCreatedAt by default
@property (nonatomic, copy, readonly, nullable) BLCustomSortingBlock customSortingBlock;
@property (nonatomic, copy, nullable) BLObjectBlock changedBlock;
#pragma mark - Table View conviniency methods
- (NSUInteger) sectionsCount;
- (NSUInteger) itemsCountForSection:(NSUInteger) section;
- (id _Nullable ) metadataForSection:(NSUInteger) section;
- (id <BLDataObject> _Nonnull) objectForIndexPath:(NSIndexPath * _Nonnull) indexPath;

#pragma mark - Data Source Methods
- (NSArray<id<BLDataObject>> *_Nonnull) processItems:(NSArray<id<BLDataObject>> *_Nonnull)items inSection:(NSUInteger) section;
- (BOOL) hasContent;
- (BOOL) removeItem:(id<BLDataObject> _Nonnull) item fromSection:(NSUInteger) section;
- (void) insertItem:(id<BLDataObject> _Nonnull) item toSection:(NSUInteger) section;
- (NSUInteger) dataSize;

- (NSIndexPath *_Nullable) indexPathForObject:(id <BLDataObject> _Nonnull) item;

#pragma mark -
- (void)enumerateObjectsUsingBlock:(void (^_Nonnull)(id <BLDataObject> _Nonnull obj, NSIndexPath * _Nonnull indexPath, BOOL * _Nonnull stop))block;

@end
