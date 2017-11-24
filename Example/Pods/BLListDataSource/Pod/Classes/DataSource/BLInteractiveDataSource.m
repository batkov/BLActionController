//
//  BLInteractiveDataSource.m
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

#import "BLInteractiveDataSource.h"
#import "BLInteractiveDataSource+Subclass.h"
#import "BLSimpleListFetchResult.h"

@implementation BLInteractiveDataSource

- (instancetype) initWithFetch:(id <BLBaseFetch>) fetch update:(id <BLBaseUpdate>) update {
    NSAssert(fetch, @"You need to provide fetch");
    if (self = [super init]) {
        self.fetch = fetch;
        self.update = update;
        [self interactiveDataSourceCommonInit];
    }
    return self;
}

- (instancetype) initWithFetch:(id<BLBaseFetch>) fetch {
    NSAssert(fetch, @"You need to provide fetch");
    if (self = [super init]) {
        self.fetch = fetch;
        [self interactiveDataSourceCommonInit];
    }
    return self;
}

- (void) interactiveDataSourceCommonInit {
    self.fetchMode = BLFetchModeOnlineOffline;
    self.fetchResultBlock = ^(id object, BOOL isLocal) {
        if (isLocal) {
            return [BLSimpleListFetchResult fetchResultForLocalObject:object];
        }
        return [BLSimpleListFetchResult fetchResultForObject:object];
    };
}

- (BOOL) failIfNeeded:(NSError *)error {
    if (error) {
        [self contentLoaded:error];
        return YES;
    }
    return NO;
}

#pragma mark -

- (void) startContentLoading {
    [super startContentLoading];
    if (self.fetchMode != BLFetchModeOfflineOnly) {
        [self fetchOfflineData:NO];
    }
    [self runRequest];
}

- (void) startContentRefreshing {
    [super startContentRefreshing];
    [self runRequest];
}

- (void) runRequest {
    if (self.fetchMode == BLFetchModeOfflineOnly) {
        [self fetchOfflineData:YES];
        return;
    }
    [self.fetch fetchOnline:[self paging]
                   callback:[self createOnlineResultBlock]];
}

- (BLIdResultBlock) createOnlineResultBlock {
    return ^(id object, NSError * error){
        if ([self failIfNeeded:error])
            return;
        BLBaseFetchResult * fetchResult = [self createFetchResultFor:object];
        if (![fetchResult isValid]) {
            [self contentLoaded:fetchResult.lastError];
            return;
        }
        [self onlineItemsLoaded:fetchResult];
    };
}

- (void) onlineItemsLoaded:(BLBaseFetchResult *) fetchResult {
    if ([self shouldCleanContentBeforeProcessOnlineItems]) {
        [self cleanContent];
    }
    if ([self shouldStoreFetchedData]) {
        [self storeItems:fetchResult];
    }
    [self processFetchResult:fetchResult];
    [self contentLoaded:nil];
}

- (BOOL) shouldStoreFetchedData {
    return self.update != nil;
}

- (BOOL) shouldCleanContentBeforeProcessOnlineItems {
    return YES;
}

- (BOOL) shouldRemoveStoredItemsBeforeSavingNew {
    return YES;
}

- (BLPaging *) paging {
    return nil;
}

- (void) cleanContent {
    
}

- (void) processFetchResult:(BLBaseFetchResult * __nullable) fetchResult {
    
}

- (void) storeItems:(BLBaseFetchResult *) fetchResult {
    NSAssert(self.update, @"You need to provide 'update' to store something");
    __weak typeof(self) selff = self;
    [self.update storeItems:fetchResult
              removeOldData:[self shouldRemoveStoredItemsBeforeSavingNew]
                   callback:^(BOOL result, NSError * _Nullable error) {
                       if (selff.storedBlock) {
                           selff.storedBlock(error);
                       }
                   }];
}

- (BOOL) refreshContentIfPossible {
    NSAssert(self.state != BLDataSourceStateInit, @"We actually shouldn't be here");
    if (self.state == BLDataSourceStateLoadContent)
        return NO;
    if (self.state == BLDataSourceStateRefreshContent)
        return NO;
    [self startContentRefreshing];
    return YES;
}

- (void)fetchOfflineData:(BOOL) refresh {
    if (self.fetchMode == BLFetchModeOnlineOnly) {
        return; // Offline disabled
    }
    __weak typeof(self) selff = self;
    [self.fetch fetchOffline:^(id  _Nullable object, NSError * _Nullable error) {
        BOOL goingToCallContentLoaded = refresh;
        if (error) {
            if (self.errorBlock && !goingToCallContentLoaded) {
                self.errorBlock(error, kBLErrorSourceOfflineRequest);
            }
        } else if (![selff hasContent] || refresh) {
            if (selff.fetchMode == BLFetchModeOfflineOnly) {
                [selff cleanContent];
            }
            BLBaseFetchResult * result = [selff createFetchResultForLocalObject:object];
            [selff processFetchResult:result];
        }
        if (goingToCallContentLoaded) {
            [selff contentLoaded:error];
        }
    }];
}

#pragma mark -
- (BLBaseFetchResult * __nonnull) createFetchResultFor:(id)object {
    if (self.fetchResultBlock) {
        return self.fetchResultBlock(object, NO);
    }
    return nil; // For subclassing
}

- (BLBaseFetchResult * __nonnull) createFetchResultForLocalObject:(id)object {
    if (self.fetchResultBlock) {
        return self.fetchResultBlock(object, YES);
    }
    return nil; // For subclassing
}


#pragma mark -
-(NSString *)debugDescription {
    NSString * fetchMode = @"OnlineAndOffline";
    if (self.fetchMode == BLFetchModeOnlineOnly) {
        fetchMode = @"Online";
    } else if (self.fetchMode == BLFetchModeOfflineOnly) {
        fetchMode = @"Offline";
    }
    return [NSString stringWithFormat:@"%@\nMode: %@\nFetch: %@\nUpdate: %@", [super debugDescription], fetchMode, [self.fetch debugDescription], [self.update debugDescription]];
}
@end

@implementation BLInteractiveDataSource (FetchObject)

- (void) fecthObject:(id<BLDataObject> __nonnull) object callback:(BLIdResultBlock __nonnull)callback {
    switch (self.fetchMode) {
        case BLFetchModeOnlineOnly:
            [self.fetch fetchOfflineObject:object callback:callback];
            break;
        case BLFetchModeOnlineOffline:
            [self.fetch fetchOnlineObject:object callback:callback];
        case BLFetchModeOfflineOnly:
            [self.fetch fetchOfflineObject:object callback:callback];
            break;
    }
}

@end
