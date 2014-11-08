//
//  NSMenu+Extensions.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSMenu+Extensions.h"
#import "NSArray+Extensions.h"

@implementation NSMenu (iLocalize)

- (void)setMenuItemsState:(int)state
{
	[[self itemArray] setMenuItemsState:state];
}

- (void)setMenuItemState:(int)state atIndex:(int)index
{
	[[self itemArray][index] setState:state];
}

- (void)setMenuItemState:(int)state withTag:(int)tag
{
	NSEnumerator *enumerator = [[self itemArray] objectEnumerator];
	id object;
	while(object = [enumerator nextObject]) {
		if([object tag] == tag)
			[object setState:state];
	}
}

@end
