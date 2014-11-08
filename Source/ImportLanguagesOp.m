//
//  ImportEngine.m
//  iLocalize3
//
//  Created by Jean on 14.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportLanguagesOp.h"
#import "LanguageEngine.h"
#import "SynchronizeEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"

#import "Console.h"
#import "OperationWC.h"
#import "ImportFilesConflict.h"
#import "FileController.h"
#import "FileTool.h"
#import "FMEngine.h"
#import "NibEngine.h"
#import "FileModel.h"
#import "FileModelContent.h"

@implementation ImportLanguagesOp

@synthesize languages;
@synthesize identical;
@synthesize layouts;
@synthesize copyOnlyIfExists;
@synthesize sourcePath;

#pragma mark Update Engine

- (void)updateFileController:(FileController*)fileController layout:(BOOL)layout usingFile:(NSString*)file resolveConflict:(BOOL)resolveConflict
{	
	if([fileController ignore]) return;
	
	file = [FileTool resolveEquivalentFile:file];
	
	// FIX IL-196: ignore non-existing file in source
	if(![file isPathExisting]) {
		[[self console] addLog:[NSString stringWithFormat:@"Skip updating file \"%@\" because \"%@\" does not exist.", [fileController relativeFilePath], file] 
                         class:[self class]];
		return;
	}
	
	[[self console] beginOperation:[NSString stringWithFormat:@"Update file \"%@\" using \"%@\"", [fileController relativeFilePath], file] class:[self class]];		
	
	FMEngine *engine = [self.projectProvider fileModuleEngineForFile:file];
	if([engine supportsContentTranslation]) {
		// FIX CASE 40 - if the localized file does not exist, copy the one from the base language so the update will work completely
		if(![fileController isBaseFileController] && ![[fileController absoluteFilePath] isPathExisting]) {
			[[FileTool shared] copySourceFile:[fileController absoluteBaseFilePath]
								toReplaceFile:[fileController absoluteFilePath]
									  console:[self console]];				
		}
		
		[[self.projectProvider fileModuleEngineForFile:file] reloadFileController:fileController usingFile:file];
		
		if(layout && [file isPathNib]) {
			// Used when updating a nib file. We have also to update the layout (i.e. the translator has updated the same version layout
			// and the programmer wants to update its project to the latest modification of the translator)
			
			[[NibEngine engineWithConsole:[self console]] translateNibFile:[fileController absoluteFilePath] 
													usingLayoutFromNibFile:file 
														 usingStringModels:[[[fileController fileModel] fileModelContent] stringsContent]];
		}
		
		// Synchronize from disk to make sure we have the latest data
		[[[self engineProvider] synchronizeEngine] synchronizeFromDiskIfNeeded:fileController];
		
		// Synchronize back to disk (should never be used but leave it here in case of)
		[[[self engineProvider] synchronizeEngine] synchronizeToDiskIfNeeded:fileController];
	} else if(resolveConflict) {
		if([ImportFilesConflict resolveConflictBetweenProjectFile:[fileController absoluteFilePath] andImportedFile:file provider:[self projectProvider]] == RESOLVE_USE_IMPORTED_FILE) {		
			[[FileTool shared] copySourceFile:file
								toReplaceFile:[fileController absoluteFilePath]
									  console:[self console]];	
			[fileController setModificationDate:[[fileController absoluteFilePath] pathModificationDate]];
			[[self.projectProvider fileModuleEngineForFile:file] reloadFileController:fileController usingFile:[fileController absoluteFilePath]];
		}
	}
	
	[[self console] endOperation];
}

- (void)updateFileController:(FileController*)fileController layout:(BOOL)layout resolveConflict:(BOOL)resolveConflict
{
	[self updateFileController:fileController 
						layout:layout
					 usingFile:[sourcePath stringByAppendingPathComponent:[fileController relativeFilePath]]
			   resolveConflict:resolveConflict];
}

- (void)updateLanguageController:(LanguageController*)languageController layout:(BOOL)layout resolveConflict:(BOOL)resolveConflict
{
	NSEnumerator *enumerator = [[languageController fileControllers] objectEnumerator];
	FileController *fileController;
	while((fileController = [enumerator nextObject]) && ![self cancel]) {
		[self progressIncrement];
		[self updateFileController:fileController layout:layout resolveConflict:resolveConflict];
	}	
}

- (void)updateLanguage:(NSString*)language layout:(BOOL)layout resolveConflict:(BOOL)resolveConflict
{
	// Reset the "Apply to all" effect of the conflict resolver for each language (see PowerPoint structure file if changes need to be done)
	[ImportFilesConflict reset];
	
	[[self console] beginOperation:[NSString stringWithFormat:@"Update language \"%@\" using source \"%@\"", language, sourcePath] class:[self class]];
	
	[self updateLanguageController:[[self projectController] languageControllerForLanguage:language] 
							layout:layout
				   resolveConflict:resolveConflict];
	
	[[self console] endOperation];
}

- (void)updateFileControllers:(NSArray*)fileControllers layout:(BOOL)layout usingCorrespondingFiles:(NSArray*)files resolveConflict:(BOOL)resolveConflict
{
	// Reset the "Apply to all" effect of the conflict resolver for each language (see PowerPoint structure file if changes need to be done)
	[ImportFilesConflict reset];

	[[self console] beginOperation:[NSString stringWithFormat:@"Update %ld files", [files count]] class:[self class]];
	[self setProgressMax:[files count]];
	
	unsigned index;
	for(index=0; index<[fileControllers count]; index++) {
		[self progressIncrement];
		[self updateFileController:fileControllers[index]
							layout:layout
						 usingFile:files[index]
				   resolveConflict:resolveConflict];
	}
	[[self console] endOperation];
	
	[self notifyProjectDidBecomeDirty];
}

#pragma mark Synchronize 

- (void)synchronizeFileControllersToDiskFromLanguage:(NSString*)language
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Synchronizing \"%@\"", language] class:[self class]];

	LanguageController *lc = [[self projectController] languageControllerForLanguage:language];
	for(FileController *fc in [lc fileControllersToSynchToDisk]) {
        [[[self engineProvider] synchronizeEngine] synchronizeToDisk:fc];				
	}
	
	[[self console] endOperation];
}

#pragma mark Operation

- (BOOL)needsDisconnectInterface
{
	return YES;
}

/*  identical = true if imported path is the same version has the project
	layouts = true if imported path nib files layout have to be imported
 */
- (void)execute
{
	[self setProgressMax:[[[self projectController] baseLanguageController] numberOfFileControllers]*[languages count]];
	
	[self setOperationName:NSLocalizedString(@"Updating Project…", @"Rebase Operation")];

	[[self console] beginOperation:[NSString stringWithFormat:@"Import from source \"%@\"", sourcePath] class:[self class]];
	
	for(NSString *language in languages) {
		if([[self projectController] isLanguageExisting:language]) {
			// Import existing language (update) - resolve conflict only if not identical (otherwise, don't handle conflicting files)
			[self updateLanguage:language layout:layouts resolveConflict:!identical];
		} else {
			// Add new language
			[[[self engineProvider] languageEngine] addLanguage:language identical:identical layout:layouts copyOnlyIfExists:copyOnlyIfExists source:[BundleSource sourceWithPath:sourcePath]];
		}
		
		[self synchronizeFileControllersToDiskFromLanguage:language];
	}
	
	[[self console] endOperation];
	
	[self notifyProjectDidBecomeDirty];
}

@end
