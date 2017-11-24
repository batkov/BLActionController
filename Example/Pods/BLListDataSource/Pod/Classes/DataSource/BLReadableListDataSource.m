//
//  BLReadableListDataSource.m
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

#import "BLReadableListDataSource.h"
#import <UIKit/UIKit.h>

@implementation BLReadableListDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupTimer];
    }
    return self;
}

#pragma mark -
- (BOOL) shouldSaveObject:(id<BLDataObject>) object {
    return NO; // For subclassing
}

#pragma mark -
- (void) setupTimer {
    __weak typeof(self) selff = self;
    __strong dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (!selff) {
            dispatch_suspend(timer);
            return;
        }
        
        if (selff.savingItems) {
            return;
        }
        
        NSMutableArray<id<BLDataObject>> * itemsToSave = [NSMutableArray array];
        for (int sectionIndex = 0; sectionIndex < [selff.dataStructure sectionsCount]; sectionIndex ++) {
            for (int row = 0; row < [selff.dataStructure itemsCountForSection:sectionIndex]; row ++) {
                id<BLDataObject> object = [selff.dataStructure objectForIndexPath:[NSIndexPath indexPathForRow:row inSection:sectionIndex]];
                
                if ([selff shouldSaveObject:object]) {
                    [itemsToSave addObject:object];
                }
            }
        }
        
        if ([itemsToSave count]) {
            selff.savingItems = itemsToSave;
            [self saveObjects:itemsToSave
                     callback:^(BOOL succeeded, NSError * _Nullable error) {
                         if (error) {
                             // TODO implement logging
                         }
                         selff.savingItems = nil;
                     }];
        }
        
    });
    dispatch_resume(timer);
}

- (void) saveObjects:(NSArray<id<BLDataObject>> *) objectsToSave callback:(BLBoolResultBlock)callback {
    // For subclasses
}

@end
