//
//  BLInteractiveDataSource.h
//
// Copyright (c) 2017 Hariton Batkov
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

#import "BLDataSource.h"
#import "BLDataKeys.h"
#import "BLBaseFetch.h"
#import "BLBaseUpdate.h"

typedef void (^BLItemsStoredBlock)(NSError * __nullable error);

@interface BLInteractiveDataSource : BLDataSource

@property (nonatomic, assign) BLFetchMode fetchMode; // BLFetchModeOnlineOffline by default
@property (nonatomic, strong, readonly, nonnull) id<BLBaseFetch> fetch;
@property (nonatomic, strong, readonly, nullable) id<BLBaseUpdate> update;

@property (nonatomic, copy, nullable) BLFetchResultBlock fetchResultBlock; // Will return results from BLSimpleListFetchResult by default
@property (nonatomic, copy, nullable) BLItemsStoredBlock storedBlock; // Called after all objects stored

- (__nonnull instancetype) init NS_UNAVAILABLE;
- (__nonnull instancetype) new NS_UNAVAILABLE;
- (__nonnull instancetype) initWithFetch:(id <BLBaseFetch> __nonnull) fetch NS_DESIGNATED_INITIALIZER;
- (__nonnull instancetype) initWithFetch:(id <BLBaseFetch> __nonnull) fetch update:(id <BLBaseUpdate> __nullable) update NS_DESIGNATED_INITIALIZER;

- (BOOL) refreshContentIfPossible;
@end


@interface BLInteractiveDataSource (FetchObject)

// Will ask 'fetch' for object data
// if 'fetchMode' is online and offline callback will be called twice
- (void) fecthObject:(id<BLDataObject> __nonnull) object callback:(BLIdResultBlock __nonnull)callback;

@end
