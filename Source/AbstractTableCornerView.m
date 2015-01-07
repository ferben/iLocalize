//
//  AbstractTableCornerView.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractTableCornerView.h"

#import "ProjectWC.h"
#import "TableViewCustom.h"

@interface AbstractTableCornerView (PrivateMethods)
- (NSString*)viewNibName;
@end

@implementation AbstractTableCornerView

- (id)initWithFrame:(NSRect)r controller:(ProjectWC *)controller
{
	if (self = [super initWithFrame:r])
    {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [bundle loadNibNamed:[self viewNibName] owner:self topLevelObjects:nil];
		mMainWindowController = controller;
	}

    return self;
}

- (NSString*)viewNibName
{
	return NULL;
}

- (NSMenu*)popupMenu
{
	return mMenu;
}

- (IBAction)menuAction:(id)sender
{
}

@end
