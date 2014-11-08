//
//  ProjectMenuFile.m
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenuFile.h"
#import "ProjectController.h"
#import "ProjectWC.h"
#import "ProjectDocument.h"
#import "ProjectExplorerController.h"
#import "ProjectFilesController.h"

#import "FileController.h"
#import "OpenAndRevealOperation.h"
#import "SaveAllOperation.h"
#import "FileTool.h"

@implementation ProjectMenuFile

- (IBAction)createNewSmartFilter:(id)sender
{
	[[self projectExplorer] createNewFilter];
}

- (IBAction)openFilesInExternalEditor:(id)sender
{
	[[OpenAndRevealOperation operationWithProjectProvider:[self projectDocument]] openFileControllers:[[self projectFiles] selectedFileControllers]];
}

- (IBAction)openPreviousAndCurrent:(id)sender {
    FileController *current = [[[self projectFiles] selectedFileControllers] firstObject];
    FileController *currentBase = [current baseFileController];
    NSString *previousBase = [[self projectFiles] previousPathForFileController:currentBase];
    
    [[self projectDocument] openFileWithExternalEditor:[currentBase absoluteFilePath]];
    [[self projectDocument] openFileWithExternalEditor:previousBase];
    if (![current isBaseFileController]) {
        [[self projectDocument] openFileWithExternalEditor:[current absoluteFilePath]];        
    }
}

- (IBAction)diffPreviousAndCurrent:(id)sender {
    FileController *current = [[[self projectFiles] selectedFileControllers] firstObject];
    NSString *previous = [[self projectFiles] previousPathForFileController:current];
    
    [FileTool diffFiles:@[previous, [current absoluteFilePath]]];
}

- (IBAction)revealFilesInFinder:(id)sender
{
	[[OpenAndRevealOperation operationWithProjectProvider:[self projectDocument]] revealFileControllers:[[self projectFiles] selectedFileControllers]];
}

//- (IBAction)saveFile:(id)sender
//{
//	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] saveAll:[[self projectFiles] selectedFileControllers]
//																createIfNotExisting:YES];
//}

- (IBAction)saveDocument:(id)sender
{
	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] saveFilesWithoutConfirmation];
	[[self projectDocument] saveDocument:sender];
}

- (IBAction)reloadFile:(id)sender
{
	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] reloadAll:[self.projectWC selectedFileControllers]];	
}

- (IBAction)showWarning:(id)sender
{
	[[self projectFiles] showWarning:[[self.projectWC selectedFileControllers] firstObject]];
}

- (IBAction)filesColumnContextualMenuAction:(id)sender
{
	[[self projectFiles] showHideFilesTableColumn:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
	BOOL isFilesSelected = [[self.projectWC selectedFileControllers] count] > 0;
	BOOL isMultipleFilesSelected = [[self.projectWC selectedFileControllers] count] > 1;
	
	// OK, handle that here
	if(action == @selector(revealFilesInFinder:) || action == @selector(openFilesInExternalEditor:)
       || action == @selector(openPreviousAndCurrent:)) {
		return isFilesSelected;
	}
	
	if(action == @selector(saveAllFiles:)) {
		return [[[self.projectWC projectController] needsToBeSavedFileControllers] count] > 0;
	}
			
	if(action == @selector(showWarning:)) {
		return !isMultipleFilesSelected && [[[self.projectWC selectedFileControllers] firstObject] statusWarning];
	}

	return YES;
}

@end
