//
//  FMEngineNib.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineNib.h"
#import "FMStringsExtensions.h"

#import "FileController.h"

#import "FileModel.h"

#import "StringsEngine.h"
#import "NibEngine.h"

#import "FileTool.h"
#import "Console.h"

@implementation FMEngineNib

// Override FMEngineStrings
- (AbstractStringsEngine*)stringModelsOfFile:(NSString*)file encodingUsed:(StringEncoding**)encoding defaultEncoding:(StringEncoding*)defaultEncoding
{
	NibEngine *engine = [self nibEngine];
	[engine parseStringModelsOfNibFile:file];	
	return engine;	
}

// Override FMEngineStrings
- (AbstractStringsEngine*)stringModelsOfFile:(NSString*)file defaultEncoding:(StringEncoding*)defaultEncoding
{
	NibEngine *engine = [self nibEngine];
	[engine parseStringModelsOfNibFile:file];	
	return engine;
}

// Override FMEngineStrings
- (AbstractStringsEngine*)stringModelsOfFile:(NSString*)file usingEncoding:(StringEncoding*)encoding
{
	NibEngine *engine = [self nibEngine];
	[engine parseStringModelsOfNibFile:file];	
	return engine;
}

#pragma mark -

- (BOOL)supportsStringEncoding
{
	return NO;
}

- (BOOL)supportsContentTranslation
{
	return YES;
}

- (void)fmRebaseAndTranslateContentWithContent:(id)content fileController:(FileController*)fileController usingPreviousLayout:(BOOL)previousLayout
{
	// Translate first all string models that are already existing in the localized language
	
	[self fmRebaseTranslateContentWithContent:content fileController:fileController];
	
	// And then replace the string models
	
	[super fmRebaseFileContentWithContent:content fileController:fileController];	
	
	// If required, update also the layout using the base file as reference
	
	NSString *localizedFile = [fileController absoluteFilePath];
	NSString *baseFile = [fileController absoluteBaseFilePath];
	
	if(previousLayout) {		
		// How does it works ?
		// 1) copy the localized file (localizedFile) to a temporary file (previousLocalizedFile)
		// 2) replace the localized file (localizedFile) by the base file (baseFile - which is a new rebased file)
		// 3) translate the localized file (localizedFile) using the previous localized file layout (previousLocalizedFile)
		
		[[self console] addLog:[NSString stringWithFormat:@"Translate file (using previous layout) \"%@\"", localizedFile] class:[self class]];
		
		NSString *previousLocalizedFile = [FileTool generateTemporaryFileNameWithExtension:[localizedFile pathExtension]];			
		
		[[FileTool shared] copySourceFile:localizedFile
							toReplaceFile:previousLocalizedFile
								  console:[self console]];
		
		[[FileTool shared] copySourceFile:baseFile
							toReplaceFile:localizedFile
								  console:[self console]];
		
		[[self nibEngine] translateNibFile:localizedFile
					usingLayoutFromNibFile:previousLocalizedFile
						 usingStringModels:content];
		
		[previousLocalizedFile removePathFromDisk];		
	} else {
		// Replace localized file by the corresponding base file and translate it (ignoring any previous layout)
		[[FileTool shared] copySourceFile:baseFile
							toReplaceFile:localizedFile
								  console:[self console]];
		
		[[self nibEngine] translateNibFile:localizedFile
						 usingStringModels:content];		
		
		// FIX CASE 19 (mark layout as to be checked if it has been reset by the base language)
		[fileController setStatusCheckLayout:YES];
	}

	// FIX CASE 70: nibtool doesn't change the modification date itself
	[[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate: [NSDate date]}
									 ofItemAtPath:localizedFile error:nil];
	[fileController setModificationDate:[localizedFile pathModificationDate]];		
}

#pragma mark -

- (void)fmSaveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
	NSString *file = [fileController absoluteFilePath];

	// Note: in 3.0.1, don't copy the file if it doesn't exist because it should always be existing on the disk
	/*if([file isPathExisting] == NO) {
		if([[NSFileManager defaultManager] copyPath:baseFile toPath:file handler:nil] == NO)
			[[self console] addError:[NSString stringWithFormat:@"Cannot copy file \"%@\" to file \"%@\"", baseFile, file] class:[self class]];			
	}*/
	
	// We don't use a previous layout here because we are only synchronizing the localized language,
	// not rebasing the project!
	[[self nibEngine] translateNibFile:file usingStringModels:[[[fileController fileModel] fileModelContent] stringsContent]];	
	
	// FIX CASE 70: nibtool doesn't change the modification date itself
	[[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate: [NSDate date]}
									 ofItemAtPath:file error:nil];
}

@end
