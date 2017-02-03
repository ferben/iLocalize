//
//  TableViewCustomRowHeightCache.h
//  iLocalize
//
//  Created by Jean on 4/26/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class TableViewCustom;

@interface TableViewCustomRowHeightCache : NSObject
{
    NSMutableDictionary *rowHeightCache;
}
@property (weak) TableViewCustom *tableView;

+ (TableViewCustomRowHeightCache *)cacheForTableView:(TableViewCustom *)tableView;

- (NSNumber *)cachedHeightForRow:(NSInteger)row;
- (void)setCachedHeight:(float)height forRow:(NSInteger)row;

- (void)clearRowHeightCache;
- (void)clearRowHeightCacheAtRow:(NSInteger)row;

- (float)computeCachedRowHeight:(NSInteger)row;

@end
