//
//  Explorer.m
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Explorer.h"
#import "ExplorerItem.h"
#import "ExplorerFilterManager.h"

#import "ProjectModel.h"
#import "Constants.h"

@implementation Explorer

@synthesize rootItem=_rootItem;

- (id)init
{
	if(self = [super init]) {
		self.rootItem = [ExplorerItem itemWithTitle:@"root"];
		[self.rootItem addChild:[ExplorerItem groupItemWithTitle:NSLocalizedString(@"FILTERS", @"Explorer List Node")]];
		[self.rootItem addChild:[ExplorerItem groupItemWithTitle:NSLocalizedString(@"RECENT SEARCHES", @"Explorer List Node")]];
		
		mDelegate = NULL;
		[[ExplorerFilterManager shared] registerExplorer:self];
	}
	return self;
}

- (void)dealloc
{
	[[ExplorerFilterManager shared] unregisterExplorer:self];
}

#pragma mark -

- (void)setDelegate:(id)delegate
{
	mDelegate = delegate;
}

- (ExplorerItem*)allItem
{
	ExplorerItem *parent = (self.rootItem.children)[0];
	return [parent.children firstObject];
}

#pragma mark -

- (void)addSourceItem:(ExplorerItem*)item
{
//	ExplorerItem *parent = [self.rootItem.children objectAtIndex:0];
//	[parent addChild:item];
}

- (void)addFilterItem:(ExplorerItem*)item
{
	ExplorerItem *parent = (self.rootItem.children)[0];
	[parent addChild:item];
}

- (void)addRecentItem:(ExplorerItem*)item
{
	ExplorerItem *parent = (self.rootItem.children)[1];
	[item setEditable:NO];
	[parent addChild:item];
}

- (void)addExplorerFilter:(ExplorerFilter*)filter
{
	ExplorerItem *item = [ExplorerItem itemWithTitle:[filter name]];
	if(filter.temporary) {
		[item setImage:[NSImage imageNamed:@"find"]];		
	} else {
		[item setImage:[NSImage imageNamed:@"NSFolderSmart"]];
	}
	[item setFilter:filter];
	if(filter.temporary) {
		[self addRecentItem:item];
	} else {
		[self addFilterItem:item];		
	}
}

- (ExplorerItem*)itemForFilter:(ExplorerFilter*)filter
{
	return [self.rootItem itemForFilter:filter];
}

- (BOOL)createSmartFilter:(ExplorerFilter*)filter
{
	BOOL created = [[ExplorerFilterManager shared] registerFilter:filter explorer:self];
	[[ExplorerFilterManager shared] saveFilter:filter explorer:self];
	return created;
}

- (void)deleteItem:(ExplorerItem*)item
{
	if(![item deletable]) {
		NSLog(@"Attempt to delete non-deletable item %@", item);
		return;
	}

	[[ExplorerFilterManager shared] removeFilter:item.filter explorer:self];
}

#pragma mark -

- (void)revalidateFindStringWrappersForStringController:(StringController*)sc
{
	/*
	ExplorerItem *item;
	for(item in mFilters) {
		id candidate = [item filter];
		if([candidate isKindOfClass:[ExplorerFindFilter class]]) {
			[candidate revalidateFindStringWrappersForStringController:sc];
		}
	}
	 */
}

- (void)removeFindStringWrappersForStringController:(StringController*)sc
{
	/*
	ExplorerItem *item;
	for(item in mFilters) {
		id candidate = [item filter];
		if([candidate isKindOfClass:[ExplorerFindFilter class]]) {
			[candidate removeFindStringWrappersForStringController:sc];
		}
	}
	 */
}

- (void)rebuild
{
	[[ExplorerFilterManager shared] loadLocalFiltersForExplorer:self];
	
	// The "All" filter
	ExplorerItem *item = [ExplorerItem itemWithTitle:NSLocalizedString(@"All", @"Explorer list node")];
	[item setImage:[NSImage imageNamed:@"Global"]];
	[item setEditable:NO];
	[item setDeletable:NO];
	item.all = YES;
	
	ExplorerFilter *filter = [ExplorerFilter filter];
	filter.name = NSLocalizedString(@"All", @"Explorer list node");
	filter.local = YES;
	[item setFilter:filter];

//	[self addSourceItem:item];
	[self addFilterItem:item];
		
	// Add the global filters	
	for(ExplorerFilter *filter in [[ExplorerFilterManager shared] globalFilters]) {
		[self addExplorerFilter:filter];		
	}
	
	// Add the local filters	
	for(ExplorerFilter *filter in [[ExplorerFilterManager shared] localFiltersForExplorer:self]) {
		[self addExplorerFilter:filter];		
	}
}

#pragma mark -

// Invoked by ExplorerFilterManager
- (void)explorerFilterDidAdd:(ExplorerFilter*)filter
{
	ExplorerItem *item = [self itemForFilter:filter];
	if(!item) {
		[self addExplorerFilter:filter];		
		item = [self itemForFilter:filter];
		LogAssert1(item != nil, @"ExplorerItem not found for filter %@", filter);	
	}
	
	[mDelegate explorerItemDidAdd:item];
}

// Invoked by ExplorerFilterManager
- (void)explorerFilterDidChange:(ExplorerFilter*)filter
{
	ExplorerItem *item = [self itemForFilter:filter];
	LogAssert1(item != nil, @"ExplorerItem not found for filter %@", filter);	
	
	[mDelegate explorerItemDidChange:item];
}

// Invoked by ExplorerFilterManager
- (void)explorerFilterDidRemove:(ExplorerFilter*)filter
{
	ExplorerItem *item = [self itemForFilter:filter];
	LogAssert1(item != nil, @"ExplorerItem not found for filter %@", filter);	

	[self.rootItem removeItem:item];

	[mDelegate explorerItemDidRemove:item];
}

@end
