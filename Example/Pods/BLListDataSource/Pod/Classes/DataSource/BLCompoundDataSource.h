//
//  BLCompoundDataSource.h
//  BLListDataSource
//
//  Created by Hariton Batkov on 12/12/17.
//

#import "BLInteractiveDataSource.h"

@interface BLCompoundDataSource : BLDataSource

/**
 @param `dataSources` array of `BLInteractiveDataSource` in init state.
 @return newly created `BLCompoundDataSource`
 */
+(instancetype _Nonnull) dataSourceWith:(NSArray<BLInteractiveDataSource *> * __nonnull)dataSources;

/**
 Calls `refreshContentIfPossible` on each dataSource
*/
- (BOOL) refreshContentIfPossible;

@property (nonatomic, strong, readonly, nonnull) NSArray<BLInteractiveDataSource *> * dataSources;

@end
