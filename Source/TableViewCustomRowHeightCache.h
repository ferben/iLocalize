//
//  TableViewCustomRowHeightCache.h
//  iLocalize
//
//  Created by Jean on 4/26/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class TableViewCustom;

@interface TableViewCustomRowHeightCache : NSObject {
	NSMutableDictionary *rowHeightCache;
}
@property (weak) TableViewCustom *tableView;

+ (TableViewCustomRowHeightCache*)cacheForTableView:(TableViewCustom*)tableView;

- (NSNumber*)cachedHeightForRow:(int)row;
- (void)setCachedHeight:(float)height forRow:(int)row;

- (void)clearRowHeightCache;
- (void)clearRowHeightCacheAtRow:(int)row;

- (float)computeCachedRowHeight:(int)row;

@end
