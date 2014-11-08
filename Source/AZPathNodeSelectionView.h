//
//  AZPathNodeSelectionView.h
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class AZPathNode;

/**
 This class handles a NSOutlineView to display a tree of AZPathNode that the user
 can select.
 */
@interface AZPathNodeSelectionView : NSObject<NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (weak) AZPathNode *rootPath;
@property (weak) NSOutlineView *outlineView;

- (void)selectAll;
- (void)selectRelativePaths:(NSArray*)paths;

- (BOOL)isAllSelected;
- (NSArray*)selectedRelativePaths;

- (void)refresh;

@end
