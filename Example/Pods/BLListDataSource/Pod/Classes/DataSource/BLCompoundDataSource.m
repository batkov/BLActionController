//
//  BLCompoundDataSource.m
//  BLListDataSource
//
//  Created by Hariton Batkov on 12/12/17.
//

#import "BLCompoundDataSource.h"
#import "BLDataSource+Subclass.h"

@interface BLCompoundDataSource ()
@property (nonatomic, strong) NSArray<BLInteractiveDataSource *> * dataSources;
@end

@implementation BLCompoundDataSource

+(instancetype) dataSourceWith:(NSArray<BLInteractiveDataSource *> * __nonnull)dataSources {
    NSAssert([dataSources count] > 0, @"You need to provide nonempty array with data sources");
    for (BLInteractiveDataSource * dataSource in dataSources) {
        NSAssert(dataSource.state == BLDataSourceStateInit, @"All dataSources should be in init state");
        NSAssert(dataSource.stateChangedBlock == nil, @"All dataSources should not have stateChangedBlock");
        NSAssert(dataSource.errorBlock == nil, @"All dataSources should not have errorBlock");
    }
    
    BLCompoundDataSource * dataSource = [[BLCompoundDataSource alloc] init];
    dataSource.dataSources = dataSources;
    
    __weak typeof(dataSource) selff = dataSource;
    for (BLInteractiveDataSource * theDataSource in dataSources) {
        theDataSource.stateChangedBlock = ^(BLDataSourceState state) {
            BOOL hasLoading = NO;
            NSError * lastError = nil;
            for (BLInteractiveDataSource * ds in dataSources) {
                switch (ds.state) {
                    case BLDataSourceStateInit:
                        // We starting to load. Exit
                        return;
                    case BLDataSourceStateLoadContent:
                    case BLDataSourceStateRefreshContent:
                        hasLoading = YES;
                        break;
                    case BLDataSourceStateContent:
                    case BLDataSourceStateNoContent:
                        break;
                    case BLDataSourceStateError:
                        lastError = ds.lastError;
                        return;
                }
                switch (selff.state) {
                    case BLDataSourceStateLoadContent:
                    case BLDataSourceStateRefreshContent:
                        if (!hasLoading) {
                            [selff contentLoaded:lastError];
                        }
                        break;
                        
                    default:
                        break;
                }
            }
        };
        theDataSource.errorBlock = ^(NSError * _Nonnull error, int errorSource) {
            if (selff.errorBlock) {
                selff.errorBlock(error, errorSource);
            }
        };
    }
    
    return dataSource;
}

- (BOOL)hasContent {
    for (BLInteractiveDataSource * dataSource in self.dataSources) {
        if ([dataSource hasContent]) {
            return YES;
        }
    }
    return NO;
}

- (void)startContentLoading {
    [super startContentLoading];
    for (BLInteractiveDataSource * dataSource in self.dataSources) {
        [dataSource startContentLoading];
    }
}
- (void)startContentRefreshing {
    [super startContentRefreshing];
    for (BLInteractiveDataSource * dataSource in self.dataSources) {
        [dataSource startContentRefreshing];
    }
}

- (BOOL)canRefresh {
    for (BLInteractiveDataSource * dataSource in self.dataSources) {
        if (![dataSource canRefresh]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) refreshContentIfPossible {
    if ([self canRefresh]) {
        [self startContentRefreshing];
        return YES;
    }
    return NO;
}
@end
