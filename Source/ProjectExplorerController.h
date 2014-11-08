//
//  ProjectSideBar.h
//  iLocalize
//
//  Created by Jean on 12/2/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ExplorerDelegate.h"

@class ProjectWC;

@class ExplorerItem;
@class ExplorerFilter;
@class ExplorerFilterEditor;

@interface ProjectExplorerController : NSViewController <ExplorerDelegate> {
@public
	IBOutlet NSTreeController		*mSideBarController;
	IBOutlet NSOutlineView			*mSideBarOutlineView;
	
	ExplorerFilter					*_lastSelectedFilter;
}

@property (assign) ProjectWC *projectWC;
@property (nonatomic, strong) ExplorerFilterEditor *filterEditor;

+ (ProjectExplorerController*)newInstance:(ProjectWC*)projectWC;

- (void)saveFiltersOrdering;
- (void)loadFiltersOrdering;

- (void)save;

- (NSArray*)selectedExplorerItems;

- (void)rearrange;
- (void)selectAllSource;
- (void)applySelectedFilters;

- (void)selectExplorerFilter:(ExplorerFilter*)filter;

/**
 Returns an array of ExplorerFilter that are selected.
 */
- (NSArray*)selectedFilters;

- (void)createNewFilterBasedOnFilter:(ExplorerFilter*)filter;
- (void)createNewFilter;

@end
