//
//  BLDataObject.h
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

@protocol BLDataObject <NSObject>

// Unique string that differ this object from others
- (NSString* __nullable) objectId;

// Creation date
- (NSDate * __nullable) createdAt;

// Date of last update
- (NSDate * __nullable) updatedAt;

@optional
// If this object is some kind of proxy you can
// save original object / object by defining these methods
- (id __nonnull) objectToStore;
- (NSArray * __nonnull) objectsToStore;

// Return NO if object need to be fetched before use
// If not implemented consider 'isDataAvailable' as YES
- (BOOL) isDataAvailable;

// Return NO if object(or objects for conplex class) need to be fetched before use
// If not implemented consider 'isAllDataAvailable' as YES
- (BOOL) isAllDataAvailable;

// Similar to 'objectToStore' can customize object to be fetched
- (id __nonnull) objectToFetch;
- (NSArray * __nonnull) objectsToFetch;


@end
