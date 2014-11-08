//
//  FileEngine.m
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileEngine.h"
#import "ModelEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "ProjectModel.h"
#import "LanguageModel.h"
#import "FileModel.h"

#import "FileTool.h"
#import "Console.h"

#import "FMManager.h"

@implementation FileEngine

- (void)addFile:(NSString*)file language:(NSString*)language toRelativeTargetPath:(NSString*)relativeTargetPath
{
	NSString *destAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:relativeTargetPath];	
	NSString *destFile = [destAbsolutePath stringByAppendingPathComponent:[file lastPathComponent]];
	
	if([destFile isPathExisting]) {
		[[self console] addWarning:[NSString stringWithFormat:@"%@ already exists", [file lastPathComponent]]
					   description:[NSString stringWithFormat:@"File \"%@\" already exists in the project and cannot be added.", [file lastPathComponent]] 
							 class:[self class]];
	} else {
		[[FileTool shared] copySourceFile:file
								   toFile:destFile 
								  console:[self console]];
				
		FileModel *fm = [[[self engineProvider] modelEngine] createFileModelFromProjectFile:destFile];
		if(language) {
			[self addFileModel:fm toLanguage:language];
		} else {
			// FIX CASE 59: copy file to all languages
			[self addBaseFileModel:fm copyFile:YES];					
		}
	}
}

- (void)addFiles:(NSArray*)files language:(NSString*)language toRelativeTargetPath:(NSString*)relativeTargetPath
{	
	NSString *file;
	for(file in files) {
		[self addFile:file language:language toRelativeTargetPath:relativeTargetPath];
	}
}

- (void)addFiles:(NSArray*)files language:(NSString*)language toSmartPath:(NSString*)smartPath
{
	NSString *targetPath;
	if(language) {
		targetPath = [[[self projectController] relativePathForSmartPath:smartPath language:language] parentPath];
	} else {
		targetPath = [[[self projectController] relativeBaseLanguagePathForSmartPath:smartPath] parentPath];		
	}
	[self addFiles:files language:language toRelativeTargetPath:targetPath];
	
	[self notifyAllFileControllersDidChange];
	[self notifyProjectDidBecomeDirty];
}

#pragma mark -

- (void)addFileModel:(FileModel*)fm toLanguage:(NSString*)language
{	
	LanguageController *localizedLanguageController = [[self projectController] languageControllerForLanguage:language];
	FileController *fileController = [[FMManager shared] defaultControllerForFile:[fm filename]];		
	[fileController setFileModel:fm];
	[fileController setBaseFileModel:nil];
	[fileController setLocal:YES];
	[localizedLanguageController addFileController:fileController];
	[[localizedLanguageController languageModel] addFileModel:fm];					
	
	return;
	
	// old code
	// create the base file model and controller
//	LanguageController *baseLanguageController = [[self projectController] baseLanguageController];
//	FileModel *bfm = [FileModel modelWithRelativeFilePath:[fm relativeFilePath]];
//	[bfm setLocalPlaceholder:YES];
//
//	FileController *baseFileController = [[FMManager shared] defaultControllerForFile:[fm filename]];		
//	[baseFileController setFileModel:bfm];
//	[baseLanguageController addFileController:baseFileController];
//	[[baseLanguageController languageModel] addFileModel:bfm];
//	
//	// create the localized file model and controller
//	LanguageController *localizedLanguageController = [[self projectController] languageControllerForLanguage:language];
//	FileController *fileController = [[FMManager shared] defaultControllerForFile:[fm filename]];		
//	if(baseLanguageController != localizedLanguageController) {
//		[fileController setFileModel:fm];
//		[fileController setBaseFileModel:bfm];
//		[fileController setLocal:YES];
//		[localizedLanguageController addFileController:fileController];
//		[[localizedLanguageController languageModel] addFileModel:fm];					
//	} else {
//		[baseFileController setLocal:YES];
//	}
//
//	// create the placeholder for the other languages
//	for(LanguageController *lc in [[self projectController] languageControllers]) {		
//		if(lc == localizedLanguageController) continue;
//		if([lc isBaseLanguage]) continue;
//		
//		FileModel *fileModel = [FileModel modelWithRelativeFilePath:[fm relativeFilePath]];
//		[fileModel setLocalPlaceholder:YES];
//		[[lc languageModel] addFileModel:fileModel];					
//		
//		FileController *fileController = [[FMManager shared] defaultControllerForFile:[fileModel filename]];		
//		[fileController setFileModel:fileModel];			
//		[fileController setBaseFileModel:bfm];			
//		[lc addFileController:fileController];			
//	}
}

- (NSArray*)addBaseFileModel:(FileModel*)baseFileModel copyFile:(BOOL)copyFile
{
	NSMutableArray *fcs = [NSMutableArray array];
	LanguageController *baseLanguageController = [[self projectController] baseLanguageController];

	FileController *fileController = [[FMManager shared] defaultControllerForFile:[baseFileModel filename]];		
	[fileController setBaseFileModel:baseFileModel];
	[fileController setFileModel:baseFileModel];
		
	[[baseLanguageController languageModel] addFileModel:baseFileModel];
	[baseLanguageController addFileController:fileController];
	[fcs addObject:fileController];
		
	NSEnumerator *enumerator = [[[self projectController] languageControllers] objectEnumerator];
	LanguageController *languageController;
	while(languageController = [enumerator nextObject]) {
		if(languageController == baseLanguageController)
			continue;
		
		FileModel *fileModel = [[[self engineProvider] modelEngine] createFileModelForLanguage:[languageController language] 
																			   sourceFileModel:baseFileModel
																					  copyFile:copyFile];
						
		FileController *fileController = [[FMManager shared] defaultControllerForFile:[baseFileModel filename]];		
		[fileController setBaseFileModel:baseFileModel];
		[fileController setFileModel:fileModel];

		[[languageController languageModel] addFileModel:fileModel];
		[languageController addFileController:fileController];
		
		[fcs addObject:fileController];
	}	
	
	return fcs;
}

#pragma mark -

- (void)deleteFileController:(FileController*)fileController removeFromDisk:(BOOL)removeFromDisk
{
	if([fileController isLocal]) {
		[[self console] addLog:[NSString stringWithFormat:@"Deleting \"%@\"", [fileController absoluteFilePath]] class:[self class]];
		[[fileController parent] deleteFileController:fileController removeFromDisk:removeFromDisk];
		return;
	}
	
	NSString *relativePath = [[fileController relativeFilePath] copy];
	
	NSEnumerator *enumerator = [[[self projectController] languageControllers] objectEnumerator];
	LanguageController *languageController;
	while(languageController = [enumerator nextObject]) {
		FileController *localizedFileController = [languageController fileControllerWithRelativePath:relativePath translate:YES];
		[[self console] addLog:[NSString stringWithFormat:@"Deleting \"%@\"", [localizedFileController absoluteFilePath]] class:[self class]];
		[languageController deleteFileController:localizedFileController removeFromDisk:removeFromDisk];
	}
}

- (void)deleteFileControllers:(NSArray*)fileControllers
{
	FileController *fileController;
	for(fileController in fileControllers) {
		[self deleteFileController:fileController removeFromDisk:YES];
	}
	
	[self notifyAllFileControllersDidChange];
	[self notifyProjectDidBecomeDirty];
}

@end
