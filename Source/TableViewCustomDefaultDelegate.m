//
//  TableViewCustomDefaultDelegate.m
//  iLocalize
//
//  Created by Jean on 1/10/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "TableViewCustomDefaultDelegate.h"
#import "TableViewCustom.h"
#import "TableViewCustomCell.h"
#import "TableViewCustomRowHeightCache.h"

@interface PlaceholderInterface
- (void)customTableView:(TableViewCustom *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row;
@end

@implementation TableViewCustomDefaultDelegate

@synthesize tableView;
@synthesize childDelegate;

- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if([childDelegate respondsToSelector:@selector(customTableView:willDisplayCell:forTableColumn:row:)]) {
		[childDelegate customTableView:tableView willDisplayCell:cell forTableColumn:tableColumn row:row];		
	}	
}

- (BOOL)textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	if([childDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementString:)]) {
		return [childDelegate textView:tv shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
	} else {
		return YES;
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return [tableView isEnabled];
}

- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row
{
	NSNumber *cachedHeight = [[tableView rowHeightCache] cachedHeightForRow:row];
	
    if (cachedHeight)
    {
		return [cachedHeight floatValue];
	}
    else
    {
		return [[tableView rowHeightCache] computeCachedRowHeight:row];
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if([cell isKindOfClass:[NSButtonCell class]]) {
		[cell setEnabled:[tableView isEnabled]];
	}
	
	if([cell isKindOfClass:[NSTextFieldCell class]]) {
		[cell setTextColor:[tableView isEnabled]?[NSColor blackColor]:[NSColor lightGrayColor]];
	}
	
	if([childDelegate respondsToSelector:@selector(customTableView:willDisplayCell:forTableColumn:row:)]) {
		[childDelegate customTableView:tableView willDisplayCell:cell forTableColumn:tableColumn row:row];		
	}
}

- (void)tableViewColumnDidMove:(NSNotification *)aNotification
{
	// Needed because custom cell using custom view are not correctly updated
	// QUESTION WWDC
	[tableView setNeedsDisplay:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if([childDelegate respondsToSelector:@selector(tableViewSelectionDidChange:)]) {
		[childDelegate tableViewSelectionDidChange:aNotification];		
	}
}

- (void)tableViewDeleteSelectedRows:(NSTableView*)tv
{
	if([childDelegate respondsToSelector:@selector(tableViewDeleteSelectedRows:)]) {
		[childDelegate tableViewDeleteSelectedRows:tv];		
	}	
}

- (void)tableViewTextDidBeginEditing:(NSTableView*)tv columnIdentifier:(NSString*)identifier rowIndex:(NSInteger)rowIndex textView:(TextViewCustom*)textView
{
	if([childDelegate respondsToSelector:@selector(tableViewTextDidBeginEditing:columnIdentifier:rowIndex:textView:)]) {
		[childDelegate tableViewTextDidBeginEditing:tv columnIdentifier:identifier rowIndex:rowIndex textView:textView];
	}		
}

- (void)tableViewTextDidBeginEditing:(NSTableView*)tv columnIdentifier:(NSString*)identifier
{
	if([childDelegate respondsToSelector:@selector(tableViewTextDidBeginEditing:columnIdentifier:)]) {
		[childDelegate performSelector:@selector(tableViewTextDidBeginEditing:columnIdentifier:) withObject:self withObject:identifier];		
	}	
}

- (void)tableViewTextDidEndEditing:(NSTableView*)tv
{
	if([childDelegate respondsToSelector:@selector(tableViewTextDidEndEditing:)]) {
		[childDelegate tableViewTextDidEndEditing:tableView];		
	}		
}

- (void)tableViewTextDidEndEditing:(NSTableView*)tv textView:(TextViewCustom*)textView
{
	if([childDelegate respondsToSelector:@selector(tableViewTextDidEndEditing:textView:)]) {
		[childDelegate tableViewTextDidEndEditing:tableView textView:textView];		
	}		    
}

- (void)tableViewDidHitEnterKey:(NSTableView*)tv
{
	if([childDelegate respondsToSelector:@selector(tableViewDidHitEnterKey:)]) {
		[childDelegate tableViewDidHitEnterKey:tableView];		
	}			
}

#pragma mark Drag and Drop

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	NSLog(@"AAA");
	return YES;
}
@end
