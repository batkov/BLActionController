//
//  BLFetchDataSource.h
//  BLListDataSource
//
//  Created by Hariton Batkov on 10/26/17.
//

#import "BLInteractiveDataSource.h"

@interface BLFetchDataSource : BLInteractiveDataSource

// 15 second by default. How long till we reload data. Set -1 to disable reload
@property (nonatomic, assign) NSTimeInterval defaultFetchDelay;

// 5 second by default. How long till we reload data if error occurred. Set -1 to disable reload
@property (nonatomic, assign) NSTimeInterval defaultErrorFetchDelay;

@property (nonatomic, strong, readonly, nullable) id fetchedObject;
@property (nonatomic, copy, nullable) BLObjectBlock fetchedObjectChanged;

// Default YES
// If YES will stop auto-refresh when app gone to background
// and start again if delay conditions are met
@property (nonatomic, assign) BOOL respectBackgroundMode;

@end
