//
//  FMEngine.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngine.h"

#import "FileController.h"
#import "FileModelContent.h"
#import "FileModel.h"

#import "EngineProvider.h"
#import "SynchronizeEngine.h"
#import "NibEngine.h"
#import "StringsEngine.h"

#import "StringEncodingTool.h"

#import "PreferencesLanguages.h"
#import "FileTool.h"
#import "Constants.h"

@implementation FMEngine

+ (id)engine
{
	return [[self alloc] init];
}

- (ProjectPrefs*)projectPrefs
{
	return [[self projectProvider] projectPrefs];
}

- (Console*)console
{
	return [[self projectProvider] console];
}

- (StringEncoding*)encodingForLanguage:(NSString*)language
{
	return [[PreferencesLanguages shared] defaultEncodingForLanguage:language];
}

- (StringEncoding*)encodingOfFile:(NSString*)file language:(NSString*)language
{
	return [StringEncodingTool encodingOfFile:file defaultEncoding:[self encodingForLanguage:language]];
}

- (SynchronizeEngine*)synchronizeEngine
{
	return [[[self projectProvider] engineProvider] synchronizeEngine];
}

- (StringsEngine*)stringsEngine
{
	return [StringsEngine engineWithConsole:[self console]];
}

- (NibEngine*)nibEngine
{
	return [NibEngine engineWithConsole:[self console]];
}

#pragma mark - subclass - 

- (FileModelContent*)fmDuplicateFileModelContent:(FileModelContent*)content emptyValue:(BOOL)emptyValue
{
	return [content copy];
}

- (void)fmLoadEncoding:(NSString*)file intoFileModel:(FileModel*)fileModel
{
	
}

- (void)fmLoadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
}

- (void)fmTranslateFileModel:(FileModel*)fileModel usingLocalizedFile:(NSString*)localizedFile
{
	
}

- (id)fmRebaseBaseFileController:(FileController*)baseFileController usingFile:(NSString*)file eolType:(int*)eolType
{
	return NULL;
}

- (void)fmRebaseFileContentWithContent:(id)content fileController:(FileController*)fileController
{
	// Note: used for base file only (and for localized file also but called from the next method).
	// by default, this method synchronize the data in memory (if any) with the new file. Otherwise, it synchronize only the date
	// because the content will be loaded before display).
	
	// Is file controller content in memory ?
	if([fileController hasModelContent]) {
		// Yes, reload the file content.
		[[self synchronizeEngine] synchronizeFromDisk:fileController];
	} else {
		// No, simply synchronize the date.
		[fileController setModificationDate:[[fileController absoluteFilePath] pathModificationDate]];
	}	
}

- (void)fmRebaseAndTranslateContentWithContent:(id)content fileController:(FileController*)fileController usingPreviousLayout:(BOOL)previousLayout
{
	// Note: used for localized file only. Depending on [self supportsContentTranslation], this method copy the base file to the localized file.
	// Then, if the file controller content is already in memory, it reloads the data from disk (so memory is in sync).
	// If the file controller content is not in memory, it simply synchronizes the file date (the content will be loaded later, just before display).

	// Copy the base file to the localized file. This overwrite the localized file. Subclass override this method to provide
	// a more "intelligent" way of rebasing a file (i.e. FMEngineStrings).
	
	if([self supportsContentTranslation]) {
		[[FileTool shared] copySourceFile:[fileController absoluteBaseFilePath]
							toReplaceFile:[fileController absoluteFilePath]
								  console:[self console]];		
		
		// Is file controller content in memory ?
		if([fileController hasModelContent]) {
			// Yes, reload the file content.
			[[self synchronizeEngine] synchronizeFromDisk:fileController];
		} else {
			// No, simply synchronize the date.
			[fileController setModificationDate:[[fileController absoluteFilePath] pathModificationDate]];
		}		
	}	
}

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
	
}

- (void)fmSaveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
	
}

- (BOOL)fmWillConvertFileController:(FileController*)fileController toEncoding:(StringEncoding*)encoding
{
	return NO;
}

#pragma mark -

- (BOOL)loadContentsOnlyWhenDisplaying
{
	// Used by subclass like FMEngineRTF where the content is only loaded at display time
	return NO;
}

- (BOOL)supportsStringEncoding
{
	// Used by subclass like FMEngineStrings to specify if they can encode their content using NSStringEncoding
	return NO;	
}

- (BOOL)supportsContentTranslation
{
	// Used by subclass like FMEngineStrings to specify if they support the merging/translation of content.
	// If the subclass returns YES, when rebasing, the localized file will be overwritten by the base file (because
	// the subclass will be able to translate the new rebased localized file with the information in memory).
	// If the subclass returns NO, when rebasing, the localized file won't be overwritten.
	return NO;
}

- (FileModelContent*)duplicateFileModelContent:(FileModelContent*)content emptyValue:(BOOL)emptyValue
{
	return [self fmDuplicateFileModelContent:content emptyValue:emptyValue];
}

- (void)loadEncoding:(NSString*)file intoFileModel:(FileModel*)fileModel
{
	[self fmLoadFile:file intoFileModel:fileModel];
}

- (void)loadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
	[self fmLoadFile:file intoFileModel:fileModel];
}

- (void)translateFileModel:(FileModel*)fileModel withLocalizedFile:(NSString*)localizedFile
{
	[self fmTranslateFileModel:fileModel usingLocalizedFile:localizedFile];
}

- (id)rebaseBaseFileController:(FileController*)baseFileController usingFile:(NSString*)file  eolType:(int*)eolType
{
	return [self fmRebaseBaseFileController:baseFileController usingFile:file eolType:eolType];
}

- (void)rebaseFileContentWithContent:(id)contents fileController:(FileController*)fileController
{
	if([fileController ignore]) return;
	if([fileController isLocal]) return;

	[self fmRebaseFileContentWithContent:contents fileController:fileController];
}

- (void)rebaseAndTranslateContentWithContent:(id)content fileController:(FileController*)fileController usingPreviousLayout:(BOOL)previousLayout
{
	if([fileController ignore]) return;
	if([fileController isLocal]) return;

	[self fmRebaseAndTranslateContentWithContent:content fileController:fileController usingPreviousLayout:previousLayout];
}

- (void)reloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
	if([fileController ignore]) return;
	if([fileController isLocal]) return;

	[self fmReloadFileController:fileController usingFile:file];
	[[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationEngineDidReload object:self];
}

- (void)saveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
	if([fileController ignore]) return;
	if([fileController isLocal]) return;
	
	// make sure the content has been loaded before writing it
	if([fileController modelContent]) {
		[self fmSaveFileController:fileController usingEncoding:encoding];
	}
}

- (BOOL)willConvertFileController:(FileController*)fileController toEncoding:(StringEncoding*)encoding
{
	if([fileController ignore]) return NO;
	if([fileController isLocal]) return NO;

	return [self fmWillConvertFileController:fileController toEncoding:encoding];
}


@end
