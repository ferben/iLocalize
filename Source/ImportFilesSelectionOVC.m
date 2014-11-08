//
//  ImportFilesSelectionOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportFilesSelectionOVC.h"
#import "ImportFilesSettings.h"

@implementation ImportFilesSelectionOVC

@synthesize settings;

- (id)init
{
	if(self = [super initWithNibName:@"ImportFilesSelection"]) {
	}
	return self;
}

- (BOOL)canContinue
{
	return [[filesController content] count] > 0;
}

- (void)willShow
{
	NSArray *filePaths = (self.arguments)[@"importFilesPaths"];
	if(filePaths) {
		for(NSString *file in filePaths) {
			[[filesController content] addObject:@{@"file": file}];			
		}
	} else {
		for(NSString *file in self.settings.files) {
			[[filesController content] addObject:@{@"file": file}];
		}		
	}
	
	[filesController rearrangeObjects];
}

- (void)willContinue
{
	NSMutableArray *files = [NSMutableArray array];
	[[filesController content] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dic = obj;
		[files addObject:dic[@"file"]];
	}];
	self.settings.files = files;
}

- (IBAction)addFiles:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setMessage:NSLocalizedString(@"Select one or more files", @"Update Project With Files")];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];
	[panel beginWithCompletionHandler:^(NSInteger result) {
		if(result == NSFileHandlingPanelOKButton) {
			[[panel URLs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSURL *file = obj;
				[filesController addObject:@{@"file": [file path]}];
			}];
			[filesController rearrangeObjects];
			[self stateChanged];
		}
	}];
}

- (IBAction)removeFiles:(id)sender
{
	[filesController removeObjects:[filesController selectedObjects]];
	[self stateChanged];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSString *path = [filesController arrangedObjects][rowIndex][@"file"];
	[aCell setImage:[[NSWorkspace sharedWorkspace] iconForFile:path]];
}

@end
