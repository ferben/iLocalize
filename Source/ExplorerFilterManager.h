//
//  ExplorerSmartFilterManager.h
//  iLocalize3
//
//  Created by Jean on 19.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class Explorer;
@class ExplorerFilter;
@class ProjectDocument;

@interface ExplorerFilterManager : NSObject
{
    NSMutableArray       *mGlobalFilters;
    NSMutableDictionary  *mLocalFilters;
    
    NSMutableArray       *mExplorers;
}

+ (id)shared;

+ (NSArray *)defaultFilterNames;

- (NSString *)globalPath;

- (void)registerExplorer:(Explorer *)explorer;
- (void)unregisterExplorer:(Explorer *)explorer;

- (void)loadGlobalFilters;
- (NSArray *)globalFilters;

- (void)loadLocalFiltersForExplorer:(Explorer *)explorer;
- (NSMutableArray *)localFiltersForExplorer:(Explorer *)explorer;

- (BOOL)registerFilter:(ExplorerFilter *)filter explorer:(Explorer *)explorer;
- (void)removeFilter:(ExplorerFilter *)filter explorer:(Explorer *)explorer;
- (void)saveFilter:(ExplorerFilter *)filter explorer:(Explorer *)explorer;

@end
