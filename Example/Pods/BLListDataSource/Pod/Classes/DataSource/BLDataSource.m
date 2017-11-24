//
//  BLDataSource.m
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

#import "BLDataSource.h"
#import "BLDataSource+Subclass.h"

@implementation BLDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = BLDataSourceStateInit;
    }
    return self;
}

- (BOOL)hasContent {
    return NO;
}

- (void)contentLoaded:(NSError *)error {
    if (error != nil) {
        self.lastError = error;
        if (self.errorBlock) {
            self.errorBlock(error, kBLErrorSourceDefault);
        }
        [self fail];
    } else if (self.hasContent) {
        [self success];
    } else {
        [self noContent];
    }
}

- (BOOL)canRefresh {
    return self.state == BLDataSourceStateError || self.state == BLDataSourceStateContent || self.state == BLDataSourceStateNoContent;
}


- (void)setState:(BLDataSourceState)state {
    switch (state) {
        case BLDataSourceStateInit:
            [NSException raise:NSInternalInconsistencyException format:@"Can't change state to init"];
            break;
        case BLDataSourceStateLoadContent:
            if (self.state != BLDataSourceStateInit) {
                [NSException raise:NSInternalInconsistencyException format:@"Can't change state to load from %ld", (long)self.state];
            }
            break;
        case BLDataSourceStateRefreshContent:
            if (self.state != BLDataSourceStateError && self.state != BLDataSourceStateContent && self.state != BLDataSourceStateNoContent) {
                [NSException raise:NSInternalInconsistencyException format:@"Can't change state to refresh from %ld", (long)self.state];
            }
            break;
        case BLDataSourceStateError:
        case BLDataSourceStateContent:
        case BLDataSourceStateNoContent:
            if (self.state != BLDataSourceStateLoadContent && self.state != BLDataSourceStateRefreshContent) {
                if (state == BLDataSourceStateNoContent && self.state == BLDataSourceStateContent) {
                    // Removing object case
                    break;
                }
                [NSException raise:NSInternalInconsistencyException format:@"Can't change state to %ld from %ld", (long)state, (long)self.state];
            }
            break;
    }
    
    _state = state;
    if (self.stateChangedBlock) {
        self.stateChangedBlock(self.state);
    }
    
    [self.delegate dataSource:self stateChanged:self.state];
}

- (void)startContentLoading {
    self.state = BLDataSourceStateLoadContent;
}

- (void)startContentRefreshing {
    self.state = BLDataSourceStateRefreshContent;
}

- (void)fail {
    self.state = BLDataSourceStateError;
}

- (void)success {
    self.state = BLDataSourceStateContent;
}

- (void)noContent {
    self.state = BLDataSourceStateNoContent;
}

@end
