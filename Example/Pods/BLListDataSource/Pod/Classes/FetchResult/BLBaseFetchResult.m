//
//  BLBaseFetchResult.m
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

#import "BLBaseFetchResult+Subclass.h"
#import "BLDataKeys.h"

@implementation BLBaseFetchResult

+ (instancetype) fetchResultForObject:(id)object {
    BLBaseFetchResult * result = [[self alloc] init];
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray * items = object;
        if ([result validateItemsList:items]) {
            [result parseItemsList:items];
        }
    }
    return result;
}

+ (instancetype) fetchResultForLocalObject:(id)object {
    BLBaseFetchResult * result = [[self alloc] init];
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray * items = object;
        if ([result validateItemsList:items]) {
            [result parseItemsList:items];
        }
    }
    return result;
}

- (NSArray *) sections {
    return [NSArray arrayWithObject:self.items];
}

- (NSDictionary *) sectionsMetadata {
    return @{};
}

- (BOOL) validateItemsList:(id) itemsList {
    if (![itemsList isKindOfClass:[NSArray class]]) {
        self.lastError = [NSError errorWithDomain:BLErrorDomain code:BLErrorCoreWrongDataFormat
                                         userInfo:@{NSLocalizedDescriptionKey : @"Wrong data format"}];;
        return NO;
    }
    return YES;
}

- (BOOL) isValid {
    return self.items != nil;
}

- (void) parseItemsList:(NSArray *) array {
    self.items = [NSArray arrayWithArray:array];
}

#pragma mark -

- (void) setLocal {
    _local = YES;
}

@end
