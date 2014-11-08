//
//  SaveAllOperation.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SaveAllOperation.h"
#import "SaveAllWC.h"
#import "OperationWC.h"

#import "Console.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "SynchronizeEngine.h"

#import "PreferencesGeneral.h"

@implementation SaveAllOperation

- (SaveAllWC*)saveAllWC
{
	return (SaveAllWC*)[self instanceOfAbstractWCName:@"SaveAllWC"];
}

- (void)saveAll:(NSArray*)files
{
    [self saveAll:files createIfNotExisting:NO];
}

- (void)saveAll:(NSArray*)files createIfNotExisting:(BOOL)createIfNotExisting
{
	if([files count]>1) {
		[[self operation] setTitle:NSLocalizedString(@"Saving modified files…", nil)];
		[[self operation] setCancellable:NO];
		[[self operation] setMaxSteps:[files count]];
		[[self operation] showAsSheet];		
	}
	    
	[[self console] beginOperation:@"Save Files" class:[self class]];
		
	for(FileController *fc in files) {
        NSString *file = [fc absoluteFilePath];
        [[self console] addLog:[NSString stringWithFormat:@"Saving \"%@\"", file] class:[self class]];
		[[self operation] increment];
		
        // Note: 3.1, if the file doesn't exist and createIfNotExisting is true, copy the base file before saving. This
        // resolve the problem when a file is not existing in a language (like a file in a framework) and then the localizer
        // decide to translate it anyway - this is the only way to create it.
        if(![file isPathExisting] && createIfNotExisting) {
            [[self console] addLog:[NSString stringWithFormat:@"Creating \"%@\"", file] class:[self class]];
            NSString *baseFile = [fc absoluteBaseFilePath];
			NSError *error = nil;
            if([[NSFileManager defaultManager] copyItemAtPath:baseFile toPath:file error:&error] == NO)
                [[self console] addError:[NSString stringWithFormat:@"Failed to copy %@", [baseFile lastPathComponent]]
							 description:[NSString stringWithFormat:@"Cannot copy file \"%@\" to file \"%@\" (%@)", baseFile, file, error]
								   class:[self class]];			
        }
        
        // Synchronize the file to the disk
		[[[self engineProvider] synchronizeEngine] synchronizeToDisk:fc];		
	}
	
	[[self console] endOperation];
	[[self operation] hide];
}

- (void)reloadAll:(NSArray*)files
{
	if([files count]>1) {
		[[self operation] setTitle:NSLocalizedString(@"Reload files…", nil)];
		[[self operation] setCancellable:NO];
		[[self operation] showAsSheet];		
	}
	
	[[self console] beginOperation:@"Reload Files" class:[self class]];

	FileController *fileController;
	for(fileController in files) {
		[[[self engineProvider] synchronizeEngine] synchronizeFromDisk:fileController];		
	}
	
	[[self projectProvider] rearrangeFilesController];
	
	[[self console] endOperation];
	[[self operation] hide];
}

#pragma mark -

- (void)saveFiles
{
	NSArray *fileControllers = [[self projectController] needsToBeSavedFileControllers];
	if([fileControllers count]) {
		[[self saveAllWC] setDidCloseSelector:@selector(performCheckAndSaveFiles) target:self];
		[[self saveAllWC] setFileControllers:fileControllers];
		[[self saveAllWC] setDisplaySave];
		[[self saveAllWC] setActionFollow:NO];
		[[self saveAllWC] showModal];			
	}
}

- (void)saveFilesWithoutConfirmation
{
	[self checkAndSaveFilesWithConfirmation:NO completion:nil];
}

- (void)checkAndSaveFilesWithConfirmation:(BOOL)confirmation completion:(dispatch_block_t)completion
{
	NSArray *fileControllers = [[self projectController] needsToBeSavedFileControllers];
	if([fileControllers count]) {
		if([[PreferencesGeneral shared] automaticallySaveModifiedFiles] || !confirmation) {
			[self saveAll:fileControllers];
            [self close];
            if (completion) completion();
		} else {
            [[self saveAllWC] setDidCloseCallback:completion];
			[[self saveAllWC] setDidCloseSelector:@selector(performCheckAndSaveFiles) target:self];
			[[self saveAllWC] setFileControllers:fileControllers];
			[[self saveAllWC] setDisplaySave];
			[[self saveAllWC] setActionFollow:NO];
			[[self saveAllWC] showModal];			
		}
	} else  {
        [self close];
        if (completion) completion();
	}
}

- (void)performCheckAndSaveFiles
{
	switch([[self saveAllWC] hideCode]) {
		case SAVEALL_SAVEALL:
			[self saveAll:[[self saveAllWC] fileControllersToSave]];
            [self close];
			break;
			
		case SAVEALL_DONT_SAVE:
            [self close];
			break;
			
		case SAVEALL_CANCEL:
            [self close];
			break;
	}
}

#pragma mark -

- (void)reloadFiles
{
	[self checkAndReloadFilesWithConfirmation:YES];
}

- (void)reloadFilesWithoutConfirmation
{
	[self checkAndReloadFilesWithConfirmation:NO];
}

- (void)checkAndReloadFilesWithConfirmation:(BOOL)confirmation
{
	NSArray *fileControllers = [[self projectController] needsToBeReloadedFileControllers];
	if([fileControllers count]) {
		if([[PreferencesGeneral shared] automaticallyReloadFiles] || !confirmation) {
			[self reloadAll:fileControllers];
            [self close];
		} else {
			[[self saveAllWC] setDidCloseSelector:@selector(performCheckAndReloadFiles) target:self];
			[[self saveAllWC] setFileControllers:fileControllers];
			[[self saveAllWC] setDisplayReload];
			[[self saveAllWC] setActionFollow:NO];
			[[self saveAllWC] showModal];							
		}
	} else 
        [self close];
}

- (void)performCheckAndReloadFiles
{
	switch([[self saveAllWC] hideCode]) {
		case SAVEALL_SAVEALL:
			[self reloadAll:[[self saveAllWC] fileControllersToSave]];
            [self close];
			break;
			
		case SAVEALL_DONT_SAVE:
            [self close];
			break;
			
		case SAVEALL_CANCEL:
            [self close];
			break;
	}
}

@end
