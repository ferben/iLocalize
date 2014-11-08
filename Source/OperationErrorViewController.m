//
//  OperationErrorViewController.m
//  iLocalize
//
//  Created by Jean Bovet on 3/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationErrorViewController.h"
#import "TableViewCustomCell.h"
#import "TableViewCustom.h"

@implementation OperationErrorViewController

@synthesize lastOperation;

- (id)init
{
	if(self = [super initWithNibName:@"OperationError"]) {
		items = [[NSMutableArray alloc] init];
		hasErrors = NO;
		self.lastOperation = NO;
		[self loadView];
	}
	return self;
}


- (BOOL)canGoBack
{
	// Note: disable go back for now. Enable it only for operations that can be rolled back or cancelled
	return NO;
}

- (BOOL)canContinue
{
	return YES;
	// Can always continue because some operations need to complete anyway because they don't support transaction that can be rolled back.
//	return lastOperation || !hasErrors;
}

- (NSString*)nextButtonTitle
{
	return NSLocalizedString(@"Continue", @"Continue Operation");
}

- (void)addErrors:(NSArray*)errors
{
	hasErrors = errors.count > 0;
	for(NSError *error in errors) {
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		info[@"type"] = @"error";
		info[@"description"] = [error userInfo][NSLocalizedDescriptionKey]?:[error description];
		[items addObject:info];
	}	
}

- (void)addWarnings:(NSArray*)warnings
{
	for(NSError *error in warnings) {
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		info[@"type"] = @"warning";
		info[@"description"] = [error userInfo][NSLocalizedDescriptionKey]?:[error description];
		[items addObject:info];
	}	
}

- (void)willShow
{
	if(hasErrors) {
		[infoField setStringValue:NSLocalizedString(@"The operation reported the following errors:", @"Errors Info Label")];		
	} else {
		[infoField setStringValue:NSLocalizedString(@"The operation reported the following warnings:", @"Warnings Info Label")];
	}

	[imageView setImage:[NSImage imageNamed:NSImageNameCaution]];

	[tableView sizeLastColumnToFit];
	
	[[tableView tableColumnWithIdentifier:@"description"] setDataCell:[TableViewCustomCell textCell]];
	[tableView reloadData];	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return items.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSDictionary *info = items[rowIndex];
	if([[aTableColumn identifier] isEqual:@"icon"]) {
		return [info[@"type"] isEqual:@"error"]?[NSImage imageNamed:@"_warning_red"]:[NSImage imageNamed:@"_warning"];
	} else {
		return info[@"description"];
	}
}

- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSDictionary *info = items[rowIndex];
	if([[aTableColumn identifier] isEqual:@"description"]) {
		TableViewCustomCell *cell = aCell;
		cell.foregroundColor = [NSColor blackColor];
		cell.value = info[@"description"];
	}
}

@end
