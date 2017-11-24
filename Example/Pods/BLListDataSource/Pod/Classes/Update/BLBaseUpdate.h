//
//  BLBaseUpdate.h
//  BLListDataSource
//
//  Created by Hariton Batkov on 11/18/17.
//

#import <Foundation/Foundation.h>
#import "BLBaseFetchResult.h"
#import "BLDataKeys.h"

@protocol BLBaseUpdate <NSObject>

- (void) storeItems:(BLBaseFetchResult *__nullable)fetchResult
      removeOldData:(BOOL)removeOldData
           callback:(BLBoolResultBlock __nonnull) callback;

- (void) saveNewObject:(id<BLDataObject> __nonnull)object callback:(BLIdResultBlock __nonnull)callback;
- (void) updateObject:(id<BLDataObject> __nonnull)object callback:(BLIdResultBlock __nonnull)callback;
- (void) deleteObject:(id<BLDataObject> __nonnull)object callback:(BLBoolResultBlock __nonnull)callback;
@end
