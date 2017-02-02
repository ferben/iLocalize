//
//  ProjectSideBar.m
//  iLocalize
//
//  Created by Jean on 12/2/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectExplorerController.h"

#import "ProjectDocument.h"
#import "ProjectController.h"
#import "ProjectWC.h"
#import "ProjectLabels.h"
#import "ProjectPrefs.h"

#import "Explorer.h"
#import "ExplorerItem.h"
#import "ExplorerFilter.h"
#import "ExplorerFilterEditor.h"
#import "ExplorerFilterManager.h"

#import "ImageAndTextCell.h"
#import "Constants.h"

@implementation ProjectExplorerController

static NSString *FILTER_DRAG_TYPE = @"ch.arizona-software.filter";

+ (ProjectExplorerController *)newInstance:(ProjectWC *)projectWC
{
	ProjectExplorerController *explorer = [[ProjectExplorerController alloc] initWithNibName:@"ProjectViewExplorer" bundle:nil];
	explorer.projectWC = projectWC;
	return explorer;
}

- (NSArray *)groupItems
{
	return [[self.projectWC explorer] rootItem].children;
}

- (ExplorerItem *)filtersGroupItem
{
	return [self groupItems][0];	
}

- (ExplorerItem *)searchGroupItem
{
	return [self groupItems][1];		
}

- (void)awakeFromNib
{	
	[self loadFiltersOrdering];
			
	[mSideBarOutlineView setTarget:self];
	[mSideBarOutlineView setDoubleAction:@selector(doubleClickOnOutlineView:)];	
	[mSideBarOutlineView registerForDraggedTypes:@[FILTER_DRAG_TYPE]];
	[mSideBarOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];

	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:NO];
	[[[mSideBarOutlineView tableColumns] firstObject] setDataCell:imageAndTextCell];	
		
	[[self.projectWC explorer] setDelegate:self];
	
	[mSideBarController setContent:[self groupItems]];
	[mSideBarOutlineView expandItem:nil expandChildren:YES];
	[self selectAllSource];
}


- (void)saveFiltersOrdering
{
	ExplorerItem *filterGroupItem = [self filtersGroupItem];
	NSMutableArray *files = [NSMutableArray array];
    
	for (ExplorerItem *item in filterGroupItem.children)
    {
		if ([item filter].file)
        {
			[files addObject:[item filter].file];			
		}
	}
    
	[self.projectWC projectPreferences].filterFiles = files;
}

- (void)loadFiltersOrdering
{
	ExplorerItem *filterGroupItem = [self filtersGroupItem];
	NSArray *files = [[self.projectWC projectPreferences] filterFiles];
	
    if (!files)
    {
		// There is no ordering defined yet in the project. Let's try to make one by using the names of the filters.		
		NSMutableArray *defaultFiles = [NSMutableArray array];
	
        for (NSString *defaultName in [ExplorerFilterManager defaultFilterNames])
        {
			for (ExplorerItem *item in filterGroupItem.children)
            {
				if ([item.filter.name isEqual:defaultName])
                {
					[defaultFiles addObject:item.filter.file];
				}
			}			
		}
        
		files = defaultFiles;
	}
    
	[filterGroupItem reorderByFilterFiles:files];
}

- (void)save
{
	// currently do nothing but might want to save the selected
	// filter at some point.
}

#pragma mark -

- (void)rearrange
{
	[mSideBarController rearrangeObjects];
}

- (NSArray *)selectedExplorerItems
{
	NSMutableArray *items = [NSMutableArray array];
    
	for (ExplorerItem *item in [mSideBarController selectedObjects])
    {
		if (!item.group)
        {
			[items addObject:item];	
		}
	}
    
	return items;
}

- (NSArray *)selectedFilters
{
    NSMutableArray *selected = [NSMutableArray array];
    
	for (ExplorerItem *item in [mSideBarController selectedObjects])
    {
		if (!item.group)
        {
            [selected addObject:[item filter]];
		}
	}
    
	return selected;
}

- (void)selectAllSource
{
	[mSideBarOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];	
}

- (void)applySelectedFilters
{	
    NSArray *filters = [self selectedFilters];
    
    if (filters.count == 1)
    {
        ExplorerFilter *filter = [filters firstObject];		
        
        if (filter.stringContentMatching)
        {
            [self.projectWC showSearchView:filter];
        }
        else
        {
            [self.projectWC hideSearchView];
        }        
    }
    else
    {
        [self.projectWC hideSearchView];
    }
    
    // Combine the selected filters into a single predicate
    NSMutableArray *smartFilters = [NSMutableArray array];
    NSMutableArray *searchFilters = [NSMutableArray array];
    
    for (ExplorerFilter *filter in filters)
    {
        if (filter.predicate)
        {
            if (filter.stringContentMatching)
            {
                [searchFilters addObject:filter.predicate];
            }
            else
            {
                [smartFilters addObject:filter.predicate];                
            }
        }
    }
    
    // Note: the filters are ORed together and ANDed with the search filters
    NSPredicate *smartFiltersPredicate = nil;
    
    if (smartFilters.count > 0)
    {
        smartFiltersPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:smartFilters];        
    }

    NSPredicate *searchFiltersPredicate = nil;
    
    if (searchFilters.count > 0)
    {
        searchFiltersPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:searchFilters];        
    }

    NSPredicate *finalPredicate = nil;
    
    if (smartFiltersPredicate == nil && searchFiltersPredicate)
    {
        finalPredicate = searchFiltersPredicate;
    }
    else if (smartFiltersPredicate && searchFiltersPredicate == nil)
    {
        finalPredicate = smartFiltersPredicate;        
    }
    else if (smartFiltersPredicate && searchFiltersPredicate)
    {
        finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[smartFiltersPredicate, searchFiltersPredicate]];
    }
	
    [self.projectWC setExplorerPredicate:finalPredicate];
}

- (void)editFilter:(ExplorerFilter *)filter
{
	self.filterEditor = [[ExplorerFilterEditor alloc] init];
	[self.filterEditor setParentWindow:[self.projectWC window]];
	[self.filterEditor setController:self];
	
	self.filterEditor.explorer = [self.projectWC explorer];
	self.filterEditor.filter = filter;
	[self.filterEditor showAsSheet];
}

- (void)editItem:(ExplorerItem *)item
{
	if ([item editable])
    {
		[self editFilter:[item filter]];
	}	
}

- (void)explorerReopenFindDialog:(ExplorerItem *)item
{
	if (item)
    {
        // ExplorerFindFilter *ff = (ExplorerFindFilter*)[item filter];
        // [[FindOperation operationWithProjectProvider:[self.projectWC projectDocument]] findWithAttributes:[ff attributes]];
	}
}

- (void)explorerEditSelectedItem
{
	ExplorerItem *item = [[self selectedExplorerItems] firstObject];
    
	if (item)
    {
		[self editItem:item];
        
/*		if ([[item filter] isSmartFilter]) 
        {
			[self explorerEditSmartFilter:item];
		} 
        else 
        {
			[self explorerReopenFindDialog:item];
		}		
*/
	}
}

- (void)createNewFilterBasedOnFilter:(ExplorerFilter *)filter
{
	ExplorerFilter *nf = [ExplorerFilter filter];
	nf.name = filter.name;
	nf.predicate = filter.predicate;
	[self editFilter:nf];		
}

- (void)createNewFilter
{
	ExplorerFilter *filter = [ExplorerFilter filter];
	filter.name = NSLocalizedString(@"Untitled", nil);
  
	[self editFilter:filter];	
}

#pragma mark -

- (void)selectExplorerFilter:(ExplorerFilter *)filter
{
	ExplorerItem *item;
    
	if (filter == nil)
    {
		item = [[self.projectWC explorer] allItem];
	}
    else
    {
		item = [[self.projectWC explorer] itemForFilter:filter];

        // If the filter is temporary, make sure to assign it again to the item
		// because its predicate might have changed.
		if (filter.temporary)
        {
			item.filter = filter;
		}
	}
    
	NSAssert1(item != nil, @"ExplorerItem not found for filter %@", filter);	
		
	NSIndexPath *indexPath = [[self.projectWC explorer].rootItem indexPathOfItem:item];
	NSAssert1(indexPath != nil, @"indexPath not found for item %@", item);
		
	if ([[mSideBarController selectionIndexPath] isEqual:indexPath])
    {
		[self applySelectedFilters];		
	}
    else
    {
		[mSideBarController setSelectionIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark ExplorerDelegate

- (void)explorerItemDidAdd:(ExplorerItem *)item
{
	[self rearrange];
}

- (void)explorerItemDidChange:(ExplorerItem *)item
{
	NSArray *indexPaths = [mSideBarController selectionIndexPaths];
	[self rearrange];
	[mSideBarController setSelectionIndexPaths:indexPaths];
}

- (void)explorerItemDidRemove:(ExplorerItem *)item
{
	[mSideBarOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	[self rearrange];
}

#pragma mark -

- (void)doubleClickOnOutlineView:(id)sender
{
	[self explorerEditSelectedItem];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notif
{
	[self applySelectedFilters];		
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return [[item representedObject] group];		
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
	return ![[item representedObject] group];		
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	[cell setImage:[[item representedObject] image]];
}

- (void)outlineViewDeleteSelectedRows:(NSOutlineView *)olv
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"ProjectExplorerControllerDeleteFiltersTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextDelete",@"Alerts",nil)];   // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];   // 2nd button
    
    // show alert
    [alert beginSheetModalForWindow:[self.projectWC window] completionHandler:^(NSModalResponse alertReturnCode)
    {
        [[alert window] orderOut:self];
         
        if (alertReturnCode == NSAlertFirstButtonReturn)
        {
            for (ExplorerItem *item in [self selectedExplorerItems])
            {
                if ([item deletable])
                {
                    [[self.projectWC explorer] deleteItem:item];
                }
            }
        }
    }];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)ite
{
	return NO;
}

#pragma mark Drag and Drop

- (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex 
{	
	NSPasteboard *pboard = [info draggingPasteboard];
	
    if ([[pboard types] containsObject:FILTER_DRAG_TYPE])
    {
		// Don't drag over a nil item
		if (item == nil)
        {
			return NSDragOperationNone;
		}
		
		// Don't drag on the Search Group Title
		if ([item representedObject] == [self searchGroupItem])
        {
			return NSDragOperationNone;			
		}

		// Get the proposed item row index
		NSInteger proposedItemRow = [mSideBarOutlineView rowForItem:item];
		
        // Don't drag over any items that are part of the SEARCH group
		if (proposedItemRow > [self filtersGroupItem].children.count)
        {
			return NSDragOperationNone;						
		}

		// Don't drag on the FILTERS group
		if (proposedItemRow == 0)
        {
			return NSDragOperationNone;
		}
		
		// If the drag is located on an item, redirect to drop after this item.
		if (childIndex == -1)
        {
			id redirectedItem = [mSideBarOutlineView itemAtRow:0];
			NSInteger redirectedIndex = proposedItemRow;
			[ov setDropItem:redirectedItem dropChildIndex:redirectedIndex];			
		}
		
        return NSDragOperationMove;
	}
    else
    {
		return NSDragOperationNone;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
	NSPasteboard *pboard = [info draggingPasteboard];
    
	if ([[pboard types] containsObject:FILTER_DRAG_TYPE])
    {
		NSArray *files = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:FILTER_DRAG_TYPE]];
		[[self filtersGroupItem] moveFiltersIdentifiedByFiles:files toChildIndex:index];
		[self saveFiltersOrdering];
		[outlineView setNeedsDisplay:YES];
	
        return YES;
	}
    else
    {
		return NO;
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
	NSMutableArray *files = [NSMutableArray array];
	
    for (id node in items)
    {
		ExplorerItem *item = [node representedObject];
		NSString *file = [item filter].file;
		if(file == NULL) continue;
		[files addObject:file];
	}
	
    if (files.count > 0)
    {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:files];
		[pboard declareTypes:@[FILTER_DRAG_TYPE] owner:self];
		[pboard setData:data forType:FILTER_DRAG_TYPE];	
	
        return YES;
	}
    else
    {
		return NO;
	}

}

@end
