//
//  NSOutlineView+Extensions.m
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSOutlineView+Extensions.h"


@implementation NSOutlineView (iLocalize)

- (id)selectedItem
{
	return [self itemAtRow:[self selectedRow]];	
}

- (NSArray*)selectedItems
{
	NSMutableArray *array = [NSMutableArray array];
	NSIndexSet *indexSet = [self selectedRowIndexes];
	NSUInteger index = [indexSet firstIndex];
	while(index != NSNotFound) {
		[array addObject:[self itemAtRow:index]];
		index = [indexSet indexGreaterThanIndex:index];
	}
	return array;
}

- (id)rootItemOfItem:(id)item
{
	int row = [self rowForItem:item];
	while([self levelForRow:row]>0)
		row--;	
	return [self itemAtRow:row];
}

@end
