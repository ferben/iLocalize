//
//  TableViewCustomRowHeightCache.m
//  iLocalize
//
//  Created by Jean on 4/26/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "TableViewCustomRowHeightCache.h"
#import "TableViewCustom.h"

@implementation TableViewCustomRowHeightCache

+ (TableViewCustomRowHeightCache*)cacheForTableView:(TableViewCustom*)tableView
{
    TableViewCustomRowHeightCache *cache = [[TableViewCustomRowHeightCache alloc] init];
    cache.tableView = tableView;
    return cache;
}

- (id)init
{
    if(self = [super init]) {
        rowHeightCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSNumber *)cachedHeightForRow:(NSInteger)row
{
    return rowHeightCache[@(row)];            
}

- (void)setCachedHeight:(float)height forRow:(NSInteger)row
{
    rowHeightCache[@(row)] = @(height);    
}

- (void)clearRowHeightCache
{
    [rowHeightCache removeAllObjects];
}

- (void)clearRowHeightCacheAtRow:(NSInteger)row
{
    [rowHeightCache removeObjectForKey:@(row)];
}

- (float)computeCachedRowHeight:(NSInteger)row
{
    float height = [self.tableView computeHeightForRow:row];
    [self setCachedHeight:height forRow:row];
    return height;
}

@end
