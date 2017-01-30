//
//  ConsoleWC.m
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ConsoleWC.h"
#import "ProjectController.h"
#import "ProjectModel.h"
#import "Console.h"
#import "ConsoleItem.h"

@implementation ConsoleWC

- (id)initWithProjectProvider:(id<ProjectProvider>)projectProvider
{
	if(self = [super initWithWindowNibName:@"ProjectConsoleWindow"]) {
		mProjectProvider = projectProvider;
		mDisplayType = CONSOLE_ALL;
		mOperationArray = [[NSMutableArray alloc] init];
		mLogItemArray = [[NSMutableArray alloc] init];
		mLevelForItemDictionary = [[NSMutableDictionary alloc] init];
		mHierarchical = NO;
		[self window];
	}
	return self;
}


- (void)awakeFromNib
{
	[[self window] setTitle:[NSString stringWithFormat:@"%@ - Console", [[mProjectProvider projectModel] name]]];
	[mDeleteOldDays setIntValue:[[self console] deleteOldDays]];
}

- (Console*)console
{
	return [mProjectProvider console];
}

- (void)render:(id)item level:(int)level
{
	if (item == nil)
		item = [self console];
	else
    {
		if ([item isOperation])
			[mOperationArray addObject:item];
        
		[mLogItemArray addObject:item];
		mLevelForItemDictionary[[NSValue valueWithNonretainedObject:item]] = @(level);
	}

	NSUInteger i;
    
	for (i = 0; i < [item numberOfItemsOfType:mDisplayType]; i++)
    {
		[self render:[item itemOfType:mDisplayType atIndex:i] level:level + 1];
	}
}

- (void)refresh
{
	[mOperationArray removeAllObjects];
	[mLogItemArray removeAllObjects];
	[mLevelForItemDictionary removeAllObjects];
	
	[self render:nil level:-1];
	
	[mOperationTableView reloadData];
	[mLogTableView reloadData];
	[mOutlineView reloadData];
}

- (void)show
{
	[self showItems:self];
	[[self window] makeKeyAndOrderFront:self];
}

- (int)displayType
{
	return CONSOLE_ALL;
}

- (IBAction)hierarchical:(id)sender
{
	mHierarchical = [sender state] == NSOnState;
	[self refresh];
}

- (IBAction)showItems:(id)sender
{
	mDisplayType = CONSOLE_ALL;

	switch([mShowTypeButton indexOfSelectedItem]) {
		case 0: 
			mDisplayType = 1 << CONSOLE_LOG | 1 << CONSOLE_WARNING;
			mDisplayType |= 1 << CONSOLE_ERROR;
			break;
		case 1: 
			mDisplayType = 1 << CONSOLE_LOG;
			break;
		case 2: 
			mDisplayType = 1 << CONSOLE_WARNING;
			mDisplayType |= 1 << CONSOLE_ERROR;
			break;
	}
					
	[self refresh];
}

- (IBAction)deleteOldDays:(id)sender
{
	[[self console] setDeleteOldDays:[mDeleteOldDays intValue]];
	[mProjectProvider setDirty];
}

- (IBAction)refresh:(id)sender
{
	[self refresh];
}

- (IBAction)clearAll:(id)sender
{
	NSBeginAlertSheet(NSLocalizedString(@"Clear All Entries?", nil), NSLocalizedString(@"Clear", NULL),
					  NSLocalizedString(@"Cancel", NULL), NULL, [self window], self, nil,
					  @selector(removeAllSheetDidDismiss:returnCode:contextInfo:),
					  nil, NSLocalizedString(@"Are you sure you want to remove all entries in the Console? This action cannot be undone.", nil));
}

- (void)removeAllSheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertDefaultReturn) {
		[mProjectProvider setDirty];
		[[self console] removeAllItems];
		[self refresh];		
	}
}

- (IBAction)export:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel beginSheetModalForWindow:[self window]
                  completionHandler:^(NSInteger result) {
                      if(result != NSFileHandlingPanelOKButton)
                          return;	
                      
                      NSString *description = [[self console] description];
                      [description writeToFile:[[panel URL] path] atomically:YES encoding:[description smallestEncoding] error:nil];
                  }];
}

@end

@implementation ConsoleWC (TableView)

- (int)numberOfRowsInTableView:(NSTableView *)tv
{
	if(tv == mOperationTableView)
		return [mOperationArray count];
	else
		return [mLogItemArray count];
}

- (NSString*)spaceForItem:(id)item
{
	if(mHierarchical) {
		int level = [mLevelForItemDictionary[[NSValue valueWithNonretainedObject:item]] intValue];
		NSMutableString *s = [NSMutableString string];
		int i;
		for(i=0; i<level; i++)
			[s appendString:@"  "];
		return s;		
	} else
		return @"";
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if(tv == mOperationTableView) {
		id item = mOperationArray[rowIndex];
		return [NSString stringWithFormat:@"%@%@", [self spaceForItem:item], [item description]];
	} else {
		id item = mLogItemArray[rowIndex];
		return [NSString stringWithFormat:@"%@%@", [self spaceForItem:item], [item description]];
	}
}

- (void)tableView:(NSTableView *)tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if(tv == mLogTableView) {
		NSFont *font;
		id item = mLogItemArray[rowIndex];
		if([item isOperation]) {
			font = [NSFont fontWithName:@"Courier Bold" size:12];		
		} else {
			font = [NSFont fontWithName:@"Courier" size:12];		
		}
		[cell setFont:font];		
		[cell setTextColor:((int)[(ConsoleItem*)item type] & (1 << CONSOLE_WARNING | 1 << CONSOLE_ERROR)) > 0 ? [NSColor redColor]:[NSColor blackColor]];
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
	NSTableView *tv = [notif object];
    
	if (tv == mOperationTableView)
    {
		NSUInteger row = [mLogItemArray indexOfObject:mOperationArray[[mOperationTableView selectedRow]]];
        
		[mLogTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [mLogTableView scrollRowToVisible:row];
	}
    else
    {
		NSString *string = NULL;
		
		if ([mLogTableView selectedRow] >= 0)
			string = [mLogItemArray[[mLogTableView selectedRow]] fullDescription];
		
		[mDetailedTextView setString:string?string:@""];		
	}
}

#pragma mark Source

- (NSUInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if (item == NULL)
    {
		return [[self console] numberOfItemsOfType:mDisplayType];
	}
    else
    {
		return [item numberOfItemsOfType:mDisplayType];
	}
}

- (id)outlineView:(NSOutlineView *)ov child:(NSUInteger)index ofItem:(id)item
{
	if (item == NULL)
    {
		return [[self console] itemOfType:mDisplayType atIndex:index];
	}
    else
    {
		return [item itemOfType:mDisplayType atIndex:index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	return ([item numberOfItemsOfType:mDisplayType] > 0);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return [item description];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	NSString *string = NULL;
	
	if([mOutlineView selectedRow] >= 0) {
		id item = [mOutlineView selectedItem];
		string = [item textRepresentation];
	}
	
	[mDetailedTextView setString:string?string:@""];			
}

//- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
//{	
//	[cell setTitle:[item title]];
//	[(KNImageAndTextButtonCell *)cell setImage:[[item payload] icon]];
//}

@end
