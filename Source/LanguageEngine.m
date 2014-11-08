//
//  LanguageEngine.m
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LanguageEngine.h"
#import "ModelEngine.h"
#import "ResourceFileEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "ProjectModel.h"
#import "FileModel.h"
#import "LanguageModel.h"

#import "LanguageTool.h"
#import "FileTool.h"

#import "Console.h"
#import "OperationWC.h"

@implementation LanguageEngine

- (void)ensureIgnoredFiles:(LanguageController*)lc
{	
	NSEnumerator *enumerator = [[lc fileControllers] objectEnumerator];
	FileController *fc;
	while((fc = [enumerator nextObject])) {
		[fc setIgnore:[[fc baseFileController] ignore]];
	}
}

- (void)copyEmptyFoldersToLanguage:(NSString*)language
{
	NSString *baseLanguage = [[[self projectController] baseLanguageController] language];
	NSString *sourcePath = [[self projectModel] projectSourceFilePath];
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:sourcePath];
	NSString *file;
	while ((file = [enumerator nextObject])) {
		file = [sourcePath stringByAppendingPathComponent:file];
		if([[FileTool languageOfPath:file] isEquivalentToLanguage:baseLanguage] && [file isPathDirectory] && ![file isPathPackage]) {
			NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:file error:nil];
			if(content && [content count] == 0) {
				// Empty folder				
				NSString *translatedFile = [FileTool translatePath:file toLanguage:language keepLanguageFormat:YES];
				[[self console] addLog:[NSString stringWithFormat:@"Copying empty folder \"%@\" to \"%@\"", file, translatedFile] class:[self class]];
				[[FileTool shared] copySourceFile:file
										   toFile:translatedFile
										  console:[self console]];

			}
		}
	}		
}

- (void)addLanguage:(NSString*)language
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Add language \"%@\"", language] class:[self class]];	
	[[self operation] setMaxSteps:[[[self projectController] baseLanguageController] numberOfFileControllers]];
	
	LanguageModel *languageModel = [[[self engineProvider] modelEngine] createLanguageModelForLanguage:language];
	[[self projectModel] addLanguageModel:languageModel];
	
	LanguageController *languageController = [LanguageController controller];
	[languageController setBaseLanguageModel:[[self projectModel] baseLanguageModel]];
	[languageController setLanguageModel:languageModel];
	
	[[self projectController] addLanguageController:languageController];	

	[self copyEmptyFoldersToLanguage:language];
	[self ensureIgnoredFiles:languageController];
	
	[[self console] endOperation];
	
	[self notifyProjectDidBecomeDirty];
	[self notifyProjectSelectLanguage:language];
}

- (void)addLanguage:(NSString*)language identical:(BOOL)identical layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists source:(BundleSource*)source
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Add language \"%@\" from source \"%@\"", language, source] class:[self class]];
		
	LanguageModel *languageModel = [[[self engineProvider] modelEngine] createLanguageModelForLanguage:language identical:identical layout:layout copyOnlyIfExists:copyOnlyIfExists source:source];
	[[self projectModel] addLanguageModel:languageModel];

	LanguageController *languageController = [LanguageController controller];
	[languageController setBaseLanguageModel:[[self projectModel] baseLanguageModel]];
	[languageController setLanguageModel:languageModel];
		
	[[self projectController] addLanguageController:languageController];	

	[self ensureIgnoredFiles:languageController];

	[[self console] endOperation];	
}

- (void)addLanguages:(NSArray*)languages identical:(BOOL)identical layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists source:(BundleSource*)source
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Add languages from source \"%@\"", source] class:[self class]];
	
	NSEnumerator *enumerator = [languages objectEnumerator];
	NSString *language;
	while((language = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
		[self addLanguage:language identical:identical layout:layout copyOnlyIfExists:copyOnlyIfExists source:source];
	}	
	
	[[self console] endOperation];
}

#pragma mark -

- (void)renameLanguage:(NSString*)source toLanguage:(NSString*)target
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Rename language \"%@\" to \"%@\"", source, target] class:[self class]];

	LanguageController *lc = [[self projectController] languageControllerForLanguage:source];	
	
	NSEnumerator *enumerator = [[lc fileControllers] objectEnumerator];
	FileController *fc;
	while((fc = [enumerator nextObject])) {
		NSString *path = [fc relativeFilePath];
		NSString *targetPath = [FileTool translatePath:path toLanguage:target];
		if(![path isEqualToString:targetPath]) {
			NSString *base = [[self projectModel] projectSourceFilePath];
			[[FileTool shared] copySourceFile:[base stringByAppendingPathComponent:path]
							  toFile:[base stringByAppendingPathComponent:targetPath]
							 console:[self console]];			
			[fc setRelativeFilePath:targetPath];
		}
	}	

	LanguageModel *languageModel = [[self projectModel] languageModelForLanguage:source];
	[languageModel setLanguage:target];

	// Trigger the change of the language popup menu entry in the project toolbar
	[lc willChangeValueForKey:@"displayLanguage"];
	[lc didChangeValueForKey:@"displayLanguage"];

	[[[self engineProvider] resourceFileEngine] removeFilesOfLanguages:[LanguageTool equivalentLanguagesWithLanguage:source]
																inPath:[[self projectModel] projectSourceFilePath]];

	[[self console] endOperation];	

	[self notifyProjectDidBecomeDirty];
}

#pragma mark -

- (void)removeLanguage:(NSString*)language
{
	[[self console] beginOperation:[NSString stringWithFormat:@"Remove language \"%@\"", language] class:[self class]];
	
	LanguageController *languageController = [[self projectController] languageControllerForLanguage:language];	
	LanguageModel *languageModel = [[self projectModel] languageModelForLanguage:language];

	[[self projectModel] removeLanguageModel:languageModel];
	[[self projectController] removeLanguageController:languageController];
	
	[[[self engineProvider] resourceFileEngine] removeFilesOfLanguages:[LanguageTool equivalentLanguagesWithLanguage:language]
																inPath:[[self projectModel] projectSourceFilePath]];
	
	[[self console] endOperation];	
	
	[self notifyProjectDidBecomeDirty];
}

@end
