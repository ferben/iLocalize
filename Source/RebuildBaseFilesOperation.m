//
//  RebuildBaseFilesOperation.m
//  iLocalize3
//
//  Created by Jean on 12/10/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "RebuildBaseFilesOperation.h"
#import "OperationWC.h"
#import "PreferencesGeneral.h"
#import "ProjectWC.h"
#import "ImportRebaseBundleOp.h"

@implementation RebuildBaseFilesOperation

- (void)awake
{
	mFileControllers = NULL;
}


- (void)rebuildBaseFileControllers:(NSArray*)controllers
{
	mFileControllers = controllers;
	
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:NSLocalizedString(@"Rebuild", @"Rebuild Base File Alert")];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Rebuild Base File Alert")];
	[alert setMessageText:NSLocalizedString(@"Rebuild selected base files?", @"Rebuild Base File Alert")];
	[alert setInformativeText:NSLocalizedString(@"Do you really want to rebuild the selected base files? This will also update all localized files. This action cannot be undone.", @"Rebuild Base File Alert")];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert setShowsSuppressionButton:YES];
	[[alert suppressionButton] setTitle:NSLocalizedString(@"Keep localized nib layouts", @"Rebuild Base File Alert")];
	[alert beginSheetModalForWindow:[self projectWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(void*)CFBridgingRetain(self)];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	BOOL keepLayout = [[alert suppressionButton] state] == NSOnState;
	
	if(returnCode == NSAlertSecondButtonReturn) {
		return;
	}

	[self performSelector:@selector(performRebuild:) withObject:@(keepLayout) afterDelay:0];
}

- (void)performRebuild:(NSNumber*)keepLayout
{
	if([mFileControllers count] > 1) {
		[[self operation] setTitle:NSLocalizedString(@"Rebuilding files…", nil)];
		[[self operation] setCancellable:NO];
		[[self operation] setIndeterminate:NO];
		[[self operation] showAsSheet];		
	}
	
	[[self projectWC] fmEditorWillChange];
	
	[[self projectWC] disconnectInterface];
	
	ImportRebaseBundleOp *op = [ImportRebaseBundleOp operation];
	op.projectProvider = [self projectProvider];
	[op rebaseBaseFileControllers:mFileControllers keepLayout:[keepLayout boolValue]];	
	
	[[self projectWC] connectInterface];
    
    [[self operation] hide];
}

@end
