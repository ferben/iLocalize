//
//  SaveAllWC.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SaveAllWC.h"
#import "FileController.h"

#import "TableViewCustom.h"
#import "FileCustomCell.h"
#import "FileTypeCustomCell.h"
#import "FileStatusCustomCell.h"

#import "PreferencesGeneral.h"

#define MODE_SAVE	1
#define MODE_RELOAD	2

@implementation SaveAllWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"SaveAll"]) {
		[mFilesTableView setDelegate:self];
		[[mFilesTableView tableColumnWithIdentifier:@"File"] setDataCell:[FileCustomCell cell]];
		[[mFilesTableView tableColumnWithIdentifier:@"Type"] setDataCell:[FileTypeCustomCell cell]];
		[[mFilesTableView tableColumnWithIdentifier:@"Status"] setDataCell:[FileStatusCustomCell cell]];		
	}
	return self;
}

- (void)setFileControllers:(NSArray*)controllers
{
	[mController removeObjects:[mController content]];
	[mController addObjects:controllers];
}

- (NSArray*)fileControllersToSave
{
	NSMutableArray *array = [NSMutableArray array];
	[[mFilesTableView selectedRowIndexes] enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
		[array addObject:[mController content][row]];
	}];
	return array;
}

- (void)setButton:(NSButton*)button title:(NSString*)title
{
    NSString *oldTitle = [button title];
    [button setTitle:title];
    if([title length] > [oldTitle length]) {
        [button sizeToFit];
		[[[self window] contentView] setNeedsDisplay:YES];
	}
}

- (void)updateInterface
{
	BOOL none = [mFilesTableView numberOfSelectedRows] == 0;
	[mDefaultAction setEnabled:!none];
	
	BOOL all = [mFilesTableView numberOfSelectedRows] == [[mController content] count];
    NSString *title = nil;
	if(all) {
		if(mMode == MODE_SAVE) {
			title = NSLocalizedString(@"Save All", nil);	
		} else {
			title = NSLocalizedString(@"Reload All", nil);
		}
	} else {
		if(mMode == MODE_SAVE) {
			title = NSLocalizedString(@"Save Selected", nil);	
		} else {
			title = NSLocalizedString(@"Reload Selected", nil);
		}
	}	
    [self setButton:mDefaultAction title:title];
}

- (void)setDisplaySave
{
	mMode = MODE_SAVE;
	[mTitle setStringValue:NSLocalizedString(@"Save Modified Files", nil)];
    [self setButton:mDontAction title:NSLocalizedString(@"Don't Save", nil)];
	[mCancelAction setHidden:NO];
	[self updateInterface];
}

- (void)setDisplayReload
{
	mMode = MODE_RELOAD;
	[mTitle setStringValue:NSLocalizedString(@"Reload Externally Modified Files", nil)];
    [self setButton:mDontAction title:NSLocalizedString(@"Don't Reload", nil)];
    [mCancelAction setHidden:YES];
	[self updateInterface];
}

- (BOOL)moveSave
{
	return mMode == MODE_SAVE;
}

- (BOOL)modeReload
{
	return mMode == MODE_RELOAD;
}

- (void)setActionFollow:(BOOL)follow
{
	[mCancelAction setHidden:!follow];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
	[self updateInterface];
}

- (NSColor*)customTableViewAlternateBackgroundColor
{
//	return [[PreferencesGeneral shared] tableViewAlternateBackgroundColor];
	return nil;
}

- (IBAction)cancel:(id)sender
{
	[self hideWithCode:SAVEALL_CANCEL];	
}

- (IBAction)dontSave:(id)sender
{
	[self hideWithCode:SAVEALL_DONT_SAVE];	
}

- (IBAction)saveAll:(id)sender
{
	[self hideWithCode:SAVEALL_SAVEALL];	
}

@end
