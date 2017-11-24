//
//  BLPaging.m
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

#import "BLPaging.h"

@interface BLPaging ()
@property (nonatomic, assign) NSInteger skip;
@property (nonatomic, assign) NSInteger limit;
@end

@implementation BLPaging

+ (instancetype) pagingFromPaging:(BLPaging *) paging {
    BLPaging * newPaging = [self new];
    newPaging.skip = paging.skip;
    newPaging.limit = paging.limit;
    return newPaging;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ [%li : %li]", [super description], (long)self.skip, (long)self.limit];
}

@end

@implementation BLMutablePaging

- (void) setSkip:(NSInteger)skip {
    [super setSkip:skip];
}

- (void) setLimit:(NSInteger)limit {
    [super setLimit:limit];
}

@end
