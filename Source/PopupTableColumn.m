//
//  PopupTableColumn.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PopupTableColumn.h"


@implementation PopupTableColumn

- (id)dataCellForRow:(NSInteger)row
{
	NSPopUpButtonCell *cell = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
	[cell setBordered:NO];
	// How to set the size of the pop-up ?
	// QUESTION WWDC
	[cell setControlSize:NSSmallControlSize];
	[cell addItemsWithTitles:[mDelegate popUpContentForRow:row]];
	return cell;	
}

@end
