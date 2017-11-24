//
//  BLBaseFetchResult.h
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
#import "BLDataObject.h"

@class BLBaseFetchResult;
typedef BLBaseFetchResult*(^BLFetchResultBlock)(id object, BOOL isLocal);

@interface BLBaseFetchResult : NSObject

// Fetch result created from online data
+ (instancetype) fetchResultForObject:(id)object;
// Fetch result created from offline data
+ (instancetype) fetchResultForLocalObject:(id)object;

// Override it, if you're changing -sections or -items.
// self.items != nil by default
- (BOOL) isValid;

@property (nonatomic, strong, readonly) NSArray<id<BLDataObject>> * items;
@property (nonatomic, strong, readonly) NSError * lastError;

// Array with arrays
// @[@[item00, item01], @[item10, item11, item12]]
- (NSArray *) sections;

// Array with arrays
// @{0:@{some data}, 1:'some object'}
- (NSDictionary *) sectionsMetadata;

@end
