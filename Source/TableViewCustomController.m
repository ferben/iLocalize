//
//  TableViewCustomController.m
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableViewCustomController.h"


@implementation TableViewCustomController

- (id)initWithNibName:(NSString*)nibname
{
	if(self = [super init]) {
		[NSBundle loadNibNamed:nibname owner:self];
	}
	return self;
}

- (void)dealloc
{
	[mView release];
	[super dealloc];
}

- (NSView*)view
{
	return mView;
}

- (void)removeFromSuperView
{
	[[self view] removeFromSuperviewWithoutNeedingDisplay];
}

- (void)willDisplayCell:(NSCell*)cell
{
	
}

@end
