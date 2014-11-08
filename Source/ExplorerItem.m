//
//  ExplorerItem.m
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerItem.h"
#import "ExplorerFilter.h"
#import "ExplorerFilter.h"

@implementation ExplorerItem

@synthesize all;
@synthesize group;
@synthesize children=_children;

+ (ExplorerItem*)itemWithTitle:(NSString*)title
{
	ExplorerItem *item = [[self alloc] init];
	[item setTitle:title];
	return item;
}

+ (ExplorerItem*)groupItemWithTitle:(NSString*)title
{
	ExplorerItem *item = [[self alloc] init];
	item.group = YES;
	[item setTitle:title];
	return item;
}

- (id)init
{
	if((self = [super init])) {
		mTitle = NULL;
		mImage = NULL;
		mSelectable = YES;
		mDeletable = YES;
		mEditable = YES;
		mFilter = NULL;
		all = NO;
		group = NO;
		_children = [[NSMutableArray alloc] init];
	}
	return self;
}


- (id)copyWithZone:(id)zone
{
	return self;
}

- (void)setImage:(NSImage*)image
{
	mImage = image;
}

- (NSImage*)image
{
	return mImage;
}

- (void)setSelectable:(BOOL)flag
{
	mSelectable = flag;
}

- (BOOL)selectable
{
	return mSelectable;
}

- (void)setDeletable:(BOOL)flag
{
	mDeletable = flag;
}

- (BOOL)deletable
{
	return mDeletable;
}

- (void)setEditable:(BOOL)flag
{
	mEditable = flag;
}

- (BOOL)editable
{
	return mEditable;
}

- (void)setFilter:(ExplorerFilter*)filter
{
	mFilter = filter;
}

- (ExplorerFilter*)filter
{
	return mFilter;
}

- (void)setTitle:(NSString*)title
{
	if(self.group) {
		mTitle = title;		
	} else {
		mFilter.name = title;		
	}
}

- (NSString*)title
{
	if(self.group) {
        return mTitle;
	} else {
		return [[NSBundle mainBundle] localizedStringForKey:mFilter.name value:mFilter.name table:@"LocalizableFilters"];
	}
}

- (void)addChild:(ExplorerItem*)child
{
	[self willChangeValueForKey:@"children"];
	[_children addObject:child];
	[self didChangeValueForKey:@"children"];
}

- (void)removeChild:(ExplorerItem*)child
{
	[self willChangeValueForKey:@"children"];
	[_children removeObject:child];
	[self didChangeValueForKey:@"children"];
}

- (void)removeItem:(ExplorerItem*)item
{
	for(ExplorerItem *c in self.children) {
		if(c == item) {
			[self removeChild:c];
			break;
		} else {
			[c removeItem:item];
		}
	}	
}

- (ExplorerItem*)itemForFilter:(ExplorerFilter*)filter
{
	if([mFilter isEqual:filter]) return self;
	
	for(ExplorerItem *item in self.children) {
		ExplorerItem *found = [item itemForFilter:filter];
		if(found) return found;
	}
	return nil;
}

- (NSIndexPath*)indexPathOfItem:(ExplorerItem*)item
{
	for(ExplorerItem *c in self.children) {
		NSIndexPath *indexPath = [c indexPathOfItem:item];
		if(indexPath) {
			NSIndexPath *firstIndexPath = [NSIndexPath indexPathWithIndex:[self.children indexOfObject:c]];			
			for(int i=0; i<[indexPath length]; i++) {
				firstIndexPath = [firstIndexPath indexPathByAddingIndex:[indexPath indexAtPosition:i]];
			}
			return firstIndexPath;
		} else {
			if([c isEqualTo:item]) {
				return [NSIndexPath indexPathWithIndex:[self.children indexOfObject:c]];
			}					
		}
	}
	return nil;
}

- (void)moveFiltersIdentifiedByFiles:(NSArray*)files toChildIndex:(int)childIndex
{
	[self willChangeValueForKey:@"children"];

	NSMutableArray *filters = [NSMutableArray array];
	for(NSString *file in files) {
		for(int index=0; index<_children.count; index++) {
			ExplorerItem *item = _children[index];
			if([[item filter].file isEqual:file]) {
				[filters addObject:item];
				[_children removeObjectAtIndex:index];
				if(index < childIndex) {
					childIndex--;
				}
				index--;
			}			
		}
	}

	for(ExplorerItem *item in filters) {
		[_children insertObject:item atIndex:childIndex++];
	}

	[self didChangeValueForKey:@"children"];	
}

- (void)reorderByFilterFiles:(NSArray*)files
{
	[self willChangeValueForKey:@"children"];
	
	NSMutableArray *orderedItems = [NSMutableArray array];
	for(NSString *file in files) {
		for(int index=0; index<_children.count; index++) {
			ExplorerItem *item = _children[index];
			if([[item filter].file isEqual:file]) {
				[orderedItems addObject:item];
				[_children removeObjectAtIndex:index];
				index--;
			}			
		}
	}
	
	// all unmatched items are put at the end
	for(ExplorerItem *item in _children) {
		[orderedItems addObject:item];
	}
		
	[_children removeAllObjects];
	[_children addObjectsFromArray:orderedItems];
	
	// Always put the All filter at the beginning
	ExplorerItem *allItem = nil;
	for(ExplorerItem *item in _children) {
		if(item.all) {
			allItem = item;
			break;
		}
	}
	if(allItem) {
		[_children removeObject:allItem];
		[_children insertObject:allItem atIndex:0];
	}
	
	[self didChangeValueForKey:@"children"];	
}

- (NSString*)description
{
	return [self title];
}

@end
