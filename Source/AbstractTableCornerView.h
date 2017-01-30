//
//  AbstractTableCornerView.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableCornerViewCustom.h"

@class ProjectWC;

@interface AbstractTableCornerView : TableCornerViewCustom
{
	IBOutlet NSMenu  *mMenu;
	ProjectWC        *mMainWindowController;
}

- (id)initWithFrame:(NSRect)r controller:(ProjectWC *)controller;
- (IBAction)menuAction:(id)sender;

@end
