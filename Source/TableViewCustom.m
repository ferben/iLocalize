//
//  TableViewCustom.m
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableViewCustom.h"
#import "TableViewCustomCell.h"
#import "TableViewCustomDefaultDelegate.h"
#import "TableViewCustomRowHeightCache.h"
#import "TextViewCustom.h"

#import "PreferencesWC.h"

@interface PlaceholderInterface
- (NSMenu *)customTableViewContextualMenu:(TableViewCustom*)tv row:(NSInteger)row column:(NSInteger)column;
@end

@implementation TableViewCustom

@synthesize rowHeightCache;

- (id)initWithCoder:(NSCoder *)coder 
{ 
	if ((self = [super initWithCoder:coder]))
    {
		mDefaultDelegate = [[TableViewCustomDefaultDelegate alloc] init];
		mDefaultDelegate.tableView = self;
		[super setDelegate:mDefaultDelegate];
		rowHeightCache = [TableViewCustomRowHeightCache cacheForTableView:self];
		cachedSize = NSZeroSize;
		inRefreshRowHeight = NO;
        editingRow = editingColumn = -1;
	} 
	
    return self;
} 

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	mDefaultDelegate = nil;
}

- (void)awakeFromNib
{
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewColumnDidMove:) name:NSTableViewColumnDidMoveNotification object:nil];	
}

#pragma mark -

- (void)setSortDescriptorKey:(NSString*)key columnIdentifier:(NSString*)identifier
{
	NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
	[[self tableColumnWithIdentifier:identifier] setSortDescriptorPrototype:descriptor];						
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	if(!enabled) {
		[self deselectAll:self];		
	}
}

- (void)setDelegate:(id)delegate
{
	mDefaultDelegate.childDelegate = delegate;
}

#pragma mark -

- (void)setMouseDownTrigger:(BOOL)flag
{
	mMouseDownTrigger = flag;
}

- (BOOL)mouseDownTrigger
{
	return mMouseDownTrigger;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[self setMouseDownTrigger:NO];
	[super mouseDown:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *keyString = [theEvent charactersIgnoringModifiers];
	unichar   keyChar = [keyString characterAtIndex:0];
	
	switch (keyChar)
	{
		case 0177: // Delete Key
		case NSDeleteFunctionKey:
		case NSDeleteCharFunctionKey:
			if ( [self selectedRow] >= 0) {
				[mDefaultDelegate tableViewDeleteSelectedRows:self];
			}
			break;
            
            // Avoid editing the table when the tab/shift-tab is detected.
            // The custom table view will handle the tab/shift-tab from its nstextview
            // in case the editing is in place
//        case NSTabCharacter:
//        case NSBackTabCharacter:
//            [[self window] selectKeyViewFollowingView:self];
//            break;
		default:
			[super keyDown:theEvent];
	}
}

#pragma mark -

- (NSMenu *)menuAtRow:(NSInteger)row column:(NSInteger)column
{
	id childDelegate = mDefaultDelegate.childDelegate;
    
	if ([childDelegate respondsToSelector:@selector(customTableViewContextualMenu:)])
		return [childDelegate performSelector:@selector(customTableViewContextualMenu:) withObject:self];
	else if([childDelegate respondsToSelector:@selector(customTableViewContextualMenu:row:column:)])
		return [childDelegate customTableViewContextualMenu:self row:row column:column];
	else
		return [super menu];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger row = [self rowAtPoint:mouseLoc];
	NSInteger column = [self columnAtPoint:mouseLoc];
	
	NSMenu *menu = [self menuAtRow:row column:column];
	
    if (menu)
    {
		if (row >= 0)
        {
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:[self allowsMultipleSelection]];			
		}
		
        [[self window] makeFirstResponder:self];
		return menu;		
	}
    else
		return nil;			
}

#pragma mark -

- (float)computeHeightForRow:(NSInteger)row
{	
	CGFloat height = [self rowHeight];
    
	// iterate over all the columns to determine the maximum height this row should have
	for (NSTableColumn *column in [self tableColumns])
    {
		if ([column isHidden])
            continue;
        
		id cell = [column dataCellForRow:row];
	
        if ([cell isKindOfClass:[TableViewCustomCell class]])
        {
			// ask the child delegate to prepare the cell for display
			[mDefaultDelegate customTableView:self willDisplayCell:cell forTableColumn:column row:row];
			height = MAX(height, [cell heightForWidth:[column width] defaultHeight:17]);		
		}
	}
    
	return height;
}

- (void)rowsHeightChanged
{
	[rowHeightCache clearRowHeightCache];
	[self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self numberOfRows])]];
}

- (void)rowsHeightChangedForRow:(NSInteger)row
{
	if (row < 0 || row >= [self numberOfRows])
    {
		[self rowsHeightChanged];
	}
    else
    {
		[rowHeightCache clearRowHeightCacheAtRow:row];
		[self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];			
	}
}

- (void)selectedRowsHeightChanged
{
	[self rowsHeightChangedForRow:[self selectedRow]];
}

- (void)refreshRowHeights
{
	// avoid doing a refresh within another refresh (e.g. didEndLiveResize call this method which will
	// trigger setFrameSize when invoking noteHeightOfRowsWithIndexesChanged).
	if (inRefreshRowHeight)
        return;
	
    inRefreshRowHeight = YES;
	
	NSRect visibleRect = [self visibleRect];
	NSPoint upperPoint = visibleRect.origin;
	NSPoint bottomPoint = NSMakePoint(visibleRect.origin.x, visibleRect.origin.y + visibleRect.size.height);
	
	NSInteger bottomRow = [self rowAtPoint:bottomPoint];
	NSInteger upperRow = [self rowAtPoint:upperPoint];
	
	[self rowsHeightChanged];	
		
	// scroll the bottom first and then the upper row to make sure the upper line is correctly
	// presented at the top of the view
	[self scrollRowToVisible:bottomRow];
	[self scrollRowToVisible:upperRow];	
	
	inRefreshRowHeight = NO;
}

- (void)performRefreshRowHeights
{
	if([self inLiveResize]) return;
	
	NSSize fSize = [self frame].size;
	if(fSize.height == 0) return;
	
	if(!NSEqualSizes(cachedSize, fSize)) {
		cachedSize = fSize;
		[self refreshRowHeights];
	}
	/*
	if([[self window] isVisible]) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshRowHeights) object:nil];
		[self performSelector:@selector(refreshRowHeights) withObject:nil afterDelay:0];	
	} else {
		[self refreshRowHeights];
	}
	 */
}

- (void)viewDidEndLiveResize
{
	[super viewDidEndLiveResize];
	[self performRefreshRowHeights];
}

- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
	[self performRefreshRowHeights];
}

- (void)makeSelectedRowVisible
{
	NSInteger selectedRow = [self selectedRow];
	
    if (selectedRow < 0)
        return;
	
	NSScrollView *sv = (NSScrollView*)[self superview];
	NSRange r = [self rowsInRect:[sv visibleRect]];
	NSInteger scrollRow = selectedRow;
	
    if (r.length > 0 && (selectedRow <= r.location+1 || selectedRow >= r.location+r.length-1))
    {
		if (selectedRow <= r.location)
        {
			scrollRow = MAX(selectedRow - r.length / 2, 0);
		}
        else
        {
			scrollRow = MIN(selectedRow + r.length / 2, [self numberOfRows]-1);
		}
	}

    [self scrollRowToVisible:scrollRow];
}
	   
/*- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
	BOOL retval = NO;
#warning if enter is used, ignore that
	if (commandSelector == @selector(insertNewline:)) {
		retval = YES;
		[fieldEditor insertNewlineIgnoringFieldEditor:nil];
	}
	return retval;
}*/

//- (void)textDidChange:(NSNotification *)aNotification
//{
//	// do nothing
//}

- (void)textDidEndEditing:(NSNotification *)notif
{
	[mDefaultDelegate tableViewTextDidEndEditing:self];
	
	if (![Utils isOSTigerAndBelow])
    {
		// Fix for Leopard to get the same editing behavior than in Tiger
		if ([[notif userInfo][@"NSTextMovement"] intValue] == NSReturnTextMovement)
        {
			NSInteger row = [self editedRow] + 1;
			NSInteger col = [self editedColumn];
		
            NSMutableDictionary *ui = [NSMutableDictionary dictionaryWithDictionary:[notif userInfo]];
			ui[@"NSTextMovement"] = @(NSDownTextMovement);
			notif = [NSNotification notificationWithName:[notif name] object:[notif object] userInfo:ui];
			[super textDidEndEditing:notif];
			
            if (row < [self numberOfRows])
            {
				[self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
				[self editColumn:col row:row withEvent:nil select:YES];
			}
		}
        else
        {
			[super textDidEndEditing:notif];
		}			
	}
    else
    {
		[super textDidEndEditing:notif];		
	}
}

#pragma mark -

- (void)editColumn:(NSInteger)columnIndex row:(NSInteger)rowIndex withEvent:(NSEvent *)theEvent select:(BOOL)select
{
	editingRow = rowIndex;
	editingColumn = columnIndex;
	NSRect frame = [self frameOfCellAtColumn:columnIndex row:rowIndex];
	
    if (textView == nil)
    {
		textView = [[TextViewCustom alloc] initWithFrame:frame];
		textView.drawBorder = YES;
		[textView setAutoresizingMask:NSViewNotSizable];
		[textView setVerticallyResizable:NO];
		[textView setHorizontallyResizable:NO];
		[textView setDelegate:self];
		[textView setCustomDelegate:self];
		[[self superview] addSubview:textView positioned:NSPositionBefore relativeTo:self];
		[textView setAllowsUndo:YES];
		[[self window] makeFirstResponder:textView];
	}
    else
    {
		textView.frame = frame;
	}

	if (select)
    {
		[textView selectAll:self];
	}
	
    NSString *columnIdentifier = [[self tableColumns][[self columnAtPoint:frame.origin]] identifier];
	[mDefaultDelegate tableViewTextDidBeginEditing:self columnIdentifier:columnIdentifier rowIndex:rowIndex textView:textView];
}

- (BOOL)abortEditing
{
    if(textView) {
        [[self window] makeFirstResponder:nil];
    }
    return [super abortEditing];
}

- (void)textViewResigned:(TextViewCustom*)tvc
{
    [mDefaultDelegate tableViewTextDidEndEditing:self textView:textView];
    
	// As stated by Apple, we need to remove all the actions when the text view resigns.
	// See http://developer.apple.com/library/ios/#documentation/cocoa/Conceptual/UndoArchitecture/Articles/AppKitUndo.html%23//apple_ref/doc/uid/20000213-73931	
	[[textView undoManager] removeAllActions];
	[tvc removeFromSuperview];
	textView = nil;
    editingColumn = -1;
}

- (BOOL)textViewKeyPressed:(NSEvent*)event
{
	BOOL processed = NO;
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
	if(([event modifierFlags] & NSAlternateKeyMask) > 0) {
		return NO;
	}
    
	if(c == NSTabCharacter || c == NSBackTabCharacter) {
		int direction = c == NSBackTabCharacter ? -1 : 1;
		int columnIndex = editingColumn+direction;
		NSArray *columns = [self tableColumns];		
		while(columnIndex != editingColumn) {
			if(columnIndex >= (int)[columns count]) {
				columnIndex = 0;
			}
			if(columnIndex < 0) {
				columnIndex = [columns count]-1;
			}
			NSTableColumn *column = columns[columnIndex];
			if([column isEditable] && ![column isHidden]) {
				break;
			}
			columnIndex += direction;
		}
		if(columnIndex != editingColumn) {
			// resign first so we can edit the next cell
			[[self window] makeFirstResponder:nil];
			[self editColumn:columnIndex row:editingRow withEvent:nil select:YES];
		}
        // always processed because tab should always jump to next column
        processed = YES;			
	}
	return processed;
}

- (void)textViewDidHitEnterKey:(TextViewCustom*)tv
{
	[mDefaultDelegate tableViewDidHitEnterKey:self];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	// Invalidate the row height upon modification
	[self rowsHeightChangedForRow:editingRow];
	
	// This is invoked by the custom text view each time a character is typed. We resize
	// the text zone to fit the cell. If the cell height changes because a new line is added,
	// this will take care of it automatically :-)
	NSRect frame = [self frameOfCellAtColumn:editingColumn row:editingRow];
	textView.frame = frame;
}

- (BOOL)textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	return [mDefaultDelegate textView:tv shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
}

// replacement for deprecated -(NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch (context)
    {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationCopy | NSDragOperationMove | NSDragOperationLink;
            
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationEvery;
    }
}

#pragma mark -

/* Needs to override this method in order to allow cross-application drag and drop */
/*
- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if(isLocal)
		return [super draggingSourceOperationMaskForLocal:isLocal];
	else
		return NSDragOperationCopy | NSDragOperationMove | NSDragOperationLink;
}
*/

- (void)flagsChanged:(NSEvent *)theEvent
{
	if([[self delegate] respondsToSelector:@selector(tableViewModifierFlagsChanged:)])
		[[self delegate] performSelector:@selector(tableViewModifierFlagsChanged:) withObject:theEvent];
}

@end

