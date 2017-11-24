//
//  BLDataKeys.h
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
@protocol BLDataObject;

typedef NS_ENUM(NSInteger, BLDataSourceState) {
    BLDataSourceStateInit,
    BLDataSourceStateLoadContent,
    BLDataSourceStateError,
    BLDataSourceStateContent,
    BLDataSourceStateNoContent,
    BLDataSourceStateRefreshContent,
};

// When BLDataSource 'lastError' changed 'errorBlock' will be triggered with BLErrorSourceDefault
static const NSInteger kBLErrorSourceDefault = 0;

// When BLInteractionDataSource offline call failed, but it won't affect overal state of DataSource
static const NSInteger kBLErrorSourceOfflineRequest = 10;

typedef void (^BLIdResultBlock)(_Nullable id object, NSError *_Nullable error);
typedef void (^BLBoolResultBlock)(BOOL result, NSError *_Nullable error);
typedef void (^BLErrorBlock)(NSError *_Nonnull error, int errorSource);
typedef void (^BLObjectBlock)(_Nullable id object);
typedef void(^BLDataSourceStateBlock)(BLDataSourceState state);

typedef NS_ENUM(NSInteger, BLErrorCore) {
    BLErrorCoreWrongDataFormat = -100501
};
static NSString * const __nonnull BLErrorDomain = @"BLListDataSource";


#pragma mark - Sorting
typedef NS_ENUM(NSUInteger, BLDataSorting) {
    BLDataSortingUpdatedAt,
    BLDataSortingUpdatedAtReverse,
    BLDataSortingCreatedAt,
    BLDataSortingCreatedAtReverse,
    BLDataSortingSortingCustom,
    BLDataNoSorting,
};
typedef NSArray<id<BLDataObject>>*_Nonnull(^BLCustomSortingBlock)(NSArray<id<BLDataObject>>* _Nonnull array);
