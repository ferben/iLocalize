//
//  ReplaceLocalizedFilesOperation.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ReplaceLocalizedFilesOperation.h"
#import "OperationWC.h"
#import "PreferencesGeneral.h"

@implementation ReplaceLocalizedFilesOperation

- (void)awake
{
	mFileControllers = NULL;
}


- (void)replaceLocalizedFileControllersFromCorrespondingBase:(NSArray*)controllers
{
	mFileControllers = [controllers copy];
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:NSLocalizedString(@"Rebuild", @"Replace Localized File Alert")];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Replace Localized File Alert")];
	[alert setMessageText:NSLocalizedString(@"Rebuild selected localized files?", @"Replace Localized File Alert")];
	[alert setInformativeText:NSLocalizedString(@"Do you really want to rebuild the selected localized files with their corresponding base files? This action cannot be undone.", @"Replace Localized File Alert")];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setShowsSuppressionButton:YES];
	[[alert suppressionButton] setTitle:NSLocalizedString(@"Keep localized nib layouts", @"Replace Localized File Alert")];
	[alert beginSheetModalForWindow:[self projectWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(void*)CFBridgingRetain(self)];
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	BOOL keepLayout = [[alert suppressionButton] state] == NSOnState;
	
	if(returnCode == NSAlertSecondButtonReturn) {
		return;
	}	
	
	[self performSelector:@selector(performReplace:) withObject:@(keepLayout) afterDelay:0];
}

- (void)performReplace:(NSNumber*)keepLayout
{
	if([mFileControllers count] > 1) {
		[[self operation] setTitle:NSLocalizedString(@"Rebuilding localized files…", nil)];
		[[self operation] setCancellable:NO];
		[[self operation] setIndeterminate:NO];
		[[self operation] showAsSheet];		
	}
	
    [[self operationDispatcher] replaceLocalizedFileControllersWithCorrespondingBase:mFileControllers
                                                                          keepLayout:keepLayout
                                                                          completion:^(id results) {
                                                                              [[self operation] hide];
                                                                              [self close];
                                                                              
                                                                              if([[PreferencesGeneral shared] autoUpdateSmartFilters])
                                                                                  [self refreshListOfFiles];
                                                                          }];
}

@end
