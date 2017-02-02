//
//  AZListSelectionView.m
//  iLocalize
//
//  Created by Jean Bovet on 3/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZListSelectionView.h"


@implementation AZListSelectionView

@synthesize elements;

+ (NSString*)selectedKey
{
	return @"_selected";
}

+ (NSString*)imageKey
{
	return @"_image";
}

- (void)reloadData
{
	[self.outlineView setDataSource:self];
	[self.outlineView setDelegate:self];
	[self.outlineView reloadData];
	[self.outlineView expandItem:nil expandChildren:YES];
}

- (NSInteger)stateOfElement:(id<AZListSelectionViewItem>)element
{
	return [[element objectForKey:[AZListSelectionView selectedKey]] boolValue] ? NSOnState : NSOffState;
}

- (void)setElement:(id<AZListSelectionViewItem>)element selection:(BOOL)selection
{
	[element setObject:@(selection) forKey:[AZListSelectionView selectedKey]];
}

- (NSInteger)rootState
{
	NSInteger state = NSOffState;
	if(elements.count > 0) {
		state = [self stateOfElement:elements[0]];
		for(int index=1; index<elements.count; index++) {
			if(state != [self stateOfElement:elements[index]]) {
				state = NSMixedState;
				break;
			}
		}		
	}
	return state;
}

- (NSArray*)selectedElements
{
	NSMutableArray *array = [NSMutableArray array];
	for(id<AZListSelectionViewItem> dic in elements) {
		if([[dic objectForKey:[AZListSelectionView selectedKey]] boolValue]) {
			[array addObject:dic];
		}
	}
	return array;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if(item == nil) {
		return 1;
	} else if ([item isKindOfClass:[AZListSelectionView class]]) {
		return elements.count;
	} else {
		return 0;
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item == nil) {
		return self;
	} else if([item isKindOfClass:[AZListSelectionView class]]) {
		return elements[index];
	} else {
		return nil;
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSInteger colIndex = [[outlineView tableColumns] indexOfObject:tableColumn];
    
	if (colIndex == 0)
    {
		if ([item isKindOfClass:[AZListSelectionView class]])
        {
			return [NSNumber numberWithInteger:[self rootState]];
		}
        else
        {
			return [NSNumber numberWithInteger:[self stateOfElement:item]];
		}			
	}
    else
    {
		if ([item isKindOfClass:[AZListSelectionView class]])
        {
			return nil;
		}
        else
        {
			return item[[tableColumn identifier]];
		}
	}
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSInteger state = [object intValue];
	BOOL selected = state == NSOnState || state == NSMixedState;
	if([item isKindOfClass:[AZListSelectionView class]]) {
		for(id<AZListSelectionViewItem> element in elements) {
			[self setElement:element selection:selected];			
		}
	} else {
		[self setElement:item selection:selected];
	}	
	[self.delegate elementsSelectionChanged:[self selectedElements].count == 0];
	[self reloadData];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [item isKindOfClass:[AZListSelectionView class]];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	int colIndex = [[outlineView tableColumns] indexOfObject:tableColumn];
	if(colIndex == 0) {
		if([item isKindOfClass:[AZListSelectionView class]]) {
			[cell setTitle:NSLocalizedString(@"All", @"All Selection Node")];
		} else {
			[cell setTitle:item[[tableColumn identifier]]];
			id image = item[[AZListSelectionView imageKey]];
			if([image isKindOfClass:[NSImage class]]) {
				[cell setImage:image];				
			}
		}		
	}
}

@end
