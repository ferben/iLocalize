//
//  ModelEngine.m
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ModelEngine.h"

#import "FMEngine.h"
#import "NibEngine.h"

#import "ProjectModel.h"
#import "LanguageModel.h"
#import "FileModel.h"
#import "FileModelContent.h"
#import "StringModel.h"
#import "StringsContentModel.h"

#import "FileTool.h"
#import "LanguageTool.h"

#import "Console.h"
#import "OperationWC.h"

#import "ImportFilesConflict.h"

#import "PreferencesLocalization.h"
#import "Constants.h"

@implementation ModelEngine

/*
 Note: only for localized language, not base language (which is created by the NewProjectEngine)
 */

- (LanguageModel *)createLanguageModelForLanguage:(NSString *)language
{
	return [self createLanguageModelForLanguage:language identical:NO layout:NO copyOnlyIfExists:NO source:NULL];
}

- (NSMutableSet *)relativeFilesOfLanguage:(NSString *)language path:(NSString *)path
{
	NSMutableSet *set = [NSMutableSet set];
    
	if (path != nil)
    {
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString *relativeFilePath;
        
		while ((relativeFilePath = [enumerator nextObject]))
        {
			NSString *file = [path stringByAppendingPathComponent:relativeFilePath];
            
			if ([[FileTool shared] isFileAtomic:file])
				[enumerator skipDescendents];
			
			if ([[relativeFilePath lastPathComponent] isEqualToString:@"Resources Disabled"])
				[enumerator skipDescendents];
			
			if ([file isValidResourceFile] && [[LanguageTool languageOfFile:relativeFilePath] isEquivalentToLanguage:language])
            {
				// The relative file path must begin with /.... it is the way the model expect it
				if (![relativeFilePath hasPrefix:@"/"])
                {
					relativeFilePath = [NSString stringWithFormat:@"/%@", relativeFilePath];
				}
                
				[set addObject:relativeFilePath];				
			}
		}		
	}
    
	return set;
}

/* The identical flag is used to know if the external source path is the same version as the base language (in this case, we copy
all the localized from the external path) or not (in this case, we use the base language file and perform an update on each of them)
*/

- (LanguageModel *)createLanguageModelForLanguage:(NSString *)language
                                        identical:(BOOL)identical
                                           layout:(BOOL)layout
                                 copyOnlyIfExists:(BOOL)copyOnlyIfExists
                                           source:(BundleSource *)source
{
	// Reset the "Apply to all" effect of the conflict resolver for each language (see PowerPoint structure file if changes need to be done)
	[ImportFilesConflict reset];
	
	LanguageModel *languageModel = [LanguageModel model];
	[languageModel setLanguage:language];

	// Keep track of the local files (i.e. only present in the localized langugage)
	NSMutableSet *localFiles = [NSMutableSet set];
    
    // todo
    for (NSString *path in @[])
    {
        // [source sourcePaths])
        for (NSString *relativeFile in [self relativeFilesOfLanguage:language path:path])
        {
            // Note: relativeFile is relative to the path.
            // If path=/Users/bovet/Development/ArizonaSoftware/software/graphclick/main/ThresholdUnit
            // relative files will be:
            //      "/French.lproj/Description.strings",
            //      "/French.lproj/InfoPlist.strings"
            // We must convert that relative file to be relative to the source path and not path.
            // => /ThresholdUnit/French.lproj/Description.strings
            
            NSString *delta = [path stringByRemovingPrefix:source.sourcePath];
            [localFiles addObject:[delta stringByAppendingPathComponent:relativeFile]];
        }
    }
	    
    NSArray *fileModels = [[[self projectModel] baseLanguageModel] fileModels];
    
    [fileModels enumerateObjectsWithOptions:CONCURRENT_OP_OPTIONS usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FileModel *baseFileModel = obj;

        if ([[self operation] shouldCancel])
        {
            *stop = YES;
            return;
        }
        
		[[self operation] increment];
        
		FileModel *fileModel = NULL;
        
		if (source)
        {
			// Source available			
		 	if (identical)
            {
				// If the source language is identical (same version) as the base language, copy the source language file
				fileModel = [self createFileModelForLanguage:language
											 sourceFileModel:baseFileModel
                                            copyOnlyIfExists:copyOnlyIfExists
                                     translateFromSourcePath:source.sourcePath];				
			}
            else
            {
				// Otherwise, copy the base language file and perform an update
				fileModel = [self createFileModelForLanguage:language
											 sourceFileModel:baseFileModel
													  layout:layout
                                            copyOnlyIfExists:copyOnlyIfExists
										updateFromSourcePath:source.sourcePath];							
			}
		}
        else
        {
			// No source available, create from base file model (and copy the base file to the localized path)
			fileModel = [self createFileModelForLanguage:language
										 sourceFileModel:baseFileModel
												copyFile:YES];
		}
        
        @synchronized(self)
        {
            // remove from the local files array the files that are already in the base language
            for (NSString *eqPath in [FileTool equivalentLanguagePaths:[fileModel relativeFilePath]])
            {
                [localFiles removeObject:eqPath];
            }
            
            [languageModel addFileModel:fileModel];            
        }
    }];
	
	// Create now the "local" localized files: that is, files that are in the localized language but not in the base language.	
	for (NSString *relativeFile in localFiles)
    {
		NSString *sourceAbsolutePath = [source.sourcePath stringByAppendingPathComponent:relativeFile];
		NSString *targetAbsolutePath = [[[self projectModel] projectSourceFilePath] stringByAppendingPathComponent:relativeFile];
		
		[[self console] addLog:[NSString stringWithFormat:@"Copy local file \"%@\" to \"%@\"", sourceAbsolutePath, targetAbsolutePath] class:[self class]];
				
		[[FileTool shared] preparePath:targetAbsolutePath 
								atomic:YES
					 skipLastComponent:YES];
		
		[[FileTool shared] copySourceFile:sourceAbsolutePath
							toReplaceFile:targetAbsolutePath
								  console:[self console]];
							
		FileModel *fm = [self createFileModelFromProjectFile:[[self projectModel] absoluteProjectPathFromRelativePath:relativeFile]];
		[fm setLocal:YES];
		[languageModel addFileModel:fm];
	}
	
	return languageModel;
}

#pragma mark -

/*	Create a file model based on a file (and its content).
	Side-effet:	-
*/

- (FileModel *)createFileModelFromProjectFile:(NSString *)file
{
	FileModel *fileModel = [FileModel modelWithRelativeFilePath:[[self projectModel] relativePathFromAbsoluteProjectPath:file]];
	
	FMEngine *engine = [self fileModuleEngineForFile:file];
	
	if ([engine loadContentsOnlyWhenDisplaying])
    {
		[engine loadEncoding:file intoFileModel:fileModel];
	}
    else
    {
		[engine loadFile:file intoFileModel:fileModel];		
	}
    
	[fileModel setModificationDate:[file pathModificationDate]];
	
	return fileModel;
}

/*	Create a copy of a file model for another language and copy the corresponding file.
	Side-effet:	-
    Called from: self
*/

- (FileModel *)createFileModelForLanguage:(NSString*)language sourceFileModel:(FileModel*)sourceFileModel
{	
	// Create the new file model with a translated path
	NSString *relativeFilePath = [FileTool translatePath:[sourceFileModel relativeFilePath] toLanguage:language keepLanguageFormat:YES];
	FileModel *fileModel = [FileModel modelWithRelativeFilePath:relativeFilePath];
	[fileModel setFormat:[sourceFileModel format]];
    
	BOOL emptyValue = ![[NSUserDefaults standardUserDefaults] boolForKey:@"autoFillTranslationWithBaseForNewLanguage"];
	FMEngine *engine = [self fileModuleEngineForFile:relativeFilePath];
    
	if(engine)
		[fileModel setFileModelContent:[engine duplicateFileModelContent:[sourceFileModel fileModelContent] emptyValue:emptyValue]];
	else
		[fileModel setFileModelContent:[[sourceFileModel fileModelContent] copy]];
    
	return fileModel;
}

/* Return a modified path by looking at the following:
   1) If the legacy language path exists on the disk, it is used
   2) Otherwise, if the iso language path exists on the disk, it is used
   3) Otherwise, the original path is returned (untouched)
 
 */
+ (NSString *)resolvePath:(NSString*)path forDefaultLanguage:(NSString*)language
{
	NSString *legacyLanguage = [language legacyLanguage];
    
	if (legacyLanguage)
    {
		NSString *translatedPath = [FileTool translatePath:path toLanguage:[language legacyLanguage] keepLanguageFormat:NO];
		NSString *lproj = [FileTool languageFolderPathOfPath:translatedPath];
        
		if ([lproj isPathExisting])
        {
			return translatedPath;
		}			
	}	
	
	NSString *isoLanguage = [language isoLanguage];
    
	if (isoLanguage)
    {
		NSString *translatedPath = [FileTool translatePath:path toLanguage:[language legacyLanguage] keepLanguageFormat:NO];
		NSString *lproj = [FileTool languageFolderPathOfPath:translatedPath];
        
		if ([lproj isPathExisting])
        {
			return translatedPath;
		}			
	}	
	
	return path;
}

/*	Create a copy of a file model for another language and copy the underlying file (from inside the project).
	Side-effet:	file is copied on disk
    Called from: self, FileEngine
 */
- (FileModel *)createFileModelForLanguage:(NSString*)language sourceFileModel:(FileModel*)sourceFileModel copyFile:(BOOL)copyFile
{
	FileModel *fileModel = [self createFileModelForLanguage:language sourceFileModel:sourceFileModel];

    if (copyFile)
    {
		// Create the source path
		NSString *sourceRelativePath = [sourceFileModel relativeFilePath];
		NSString *sourceAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:sourceRelativePath];
		
		// Create the target path
		NSString *targetRelativePath = [FileTool translatePath:sourceRelativePath toLanguage:language keepLanguageFormat:NO];
		NSString *targetAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:targetRelativePath];
		
		// Let's see if the path already exists with the legacy version of it
		targetAbsolutePath = [ModelEngine resolvePath:targetAbsolutePath forDefaultLanguage:language];
		targetRelativePath = [[self projectModel] relativePathFromAbsoluteProjectPath:targetAbsolutePath];		
				
		[[self console] addLog:[NSString stringWithFormat:@"Copy file \"%@\" to \"%@\" (%@)", sourceAbsolutePath, targetAbsolutePath, language] class:[self class]];

		[[FileTool shared] preparePath:targetAbsolutePath 
								atomic:YES
					 skipLastComponent:YES];
		
		[[FileTool shared] copySourceFile:sourceAbsolutePath
							toReplaceFile:targetAbsolutePath
								  console:[self console]];
		
		[fileModel setRelativeFilePath:targetRelativePath];
		[fileModel setModificationDate:[targetAbsolutePath pathModificationDate]];	
	}
    
	return fileModel;
}

- (FileModel *)createFileModelForLanguage:(NSString *)language
                          sourceFileModel:(FileModel *)sourceFileModel
                         copyOnlyIfExists:(BOOL)copyOnlyIfExists
                  translateFromSourcePath:(NSString *)sourcePath
{
	NSString *sourceRelativePath = [sourceFileModel relativeFilePath];
	NSString *sourceAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:sourceRelativePath];

    NSString *targetRelativePath = [FileTool translatePath:sourceRelativePath toLanguage:language keepLanguageFormat:YES];
	NSString *targetAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:targetRelativePath];	
	
	NSString *localizedSourceFile = [FileTool resolveEquivalentFile:[sourcePath stringByAppendingPathComponent:targetRelativePath]];

	// use the language format of the source	
	targetAbsolutePath = [FileTool translatePath:targetAbsolutePath toLanguage:[FileTool languageOfPath:localizedSourceFile]];
    
	// change the file format if the file already exists in another format
	targetAbsolutePath = [FileTool resolveEquivalentFile:targetAbsolutePath];
		
	BOOL createFromBaseLanguage = NO;
	
	if ([localizedSourceFile isPathExisting] == NO)
    {
        if (copyOnlyIfExists)
        {
            localizedSourceFile = nil;            
        }
        else
        {
            [[self console] addLog:[NSString stringWithFormat:@"Non-existent localized source file \"%@\"", localizedSourceFile] class:[self class]];
            [[self console] addLog:[NSString stringWithFormat:@" -> Will copy instead from \"%@\"", sourceAbsolutePath] class:[self class]];
            localizedSourceFile = sourceAbsolutePath;
			createFromBaseLanguage = YES;
        }
	}
	
    if (localizedSourceFile)
    {
        [[self console] addLog:[NSString stringWithFormat:@"Copy file \"%@\" to \"%@\"", localizedSourceFile, targetAbsolutePath] class:[self class]];
        
        [[FileTool shared] preparePath:targetAbsolutePath 
                                atomic:YES
                     skipLastComponent:YES];
        
        [[FileTool shared] copySourceFile:localizedSourceFile
                            toReplaceFile:targetAbsolutePath
                                  console:[self console]];        
    }
	
	FileModel *fileModel = [self createFileModelForLanguage:language sourceFileModel:sourceFileModel usingLocalizedFile:targetAbsolutePath];
	
	// FIX CASE 36
	if (createFromBaseLanguage && ([[fileModel filename] isPathNib] || [[fileModel filename] isPathStrings]))
    {
		/* Make sure that if a localized is created from the base language we mark each string as to be checked
		otherwise we will end up with base strings marked as translated which is not what the translator expect
		*/
		NSEnumerator *enumerator = [[[fileModel fileModelContent] stringsContent] stringsEnumerator];
		StringModel *sm;
        
		while ((sm = [enumerator nextObject]))
        {
			[sm setStatus:(1 << STRING_STATUS_TOCHECK)];
		}		
	}
	
	// Update the relative file path to the one actually existing on the disk
	[fileModel setRelativeFilePath:[[self projectModel] relativePathFromAbsoluteProjectPath:targetAbsolutePath]];
	[fileModel setModificationDate:[targetAbsolutePath pathModificationDate]];
    
	return fileModel;
}

- (FileModel *)createFileModelForLanguage:(NSString*)language
                          sourceFileModel:(FileModel*)sourceFileModel
                                   layout:(BOOL)layout
                         copyOnlyIfExists:(BOOL)copyOnlyIfExists
                     updateFromSourcePath:(NSString*)sourcePath
{
	NSString *sourceRelativePath = [sourceFileModel relativeFilePath];
	NSString *sourceAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:sourceRelativePath];
	
	NSString *targetRelativePath = [FileTool translatePath:sourceRelativePath toLanguage:language keepLanguageFormat:YES];
	NSString *targetAbsolutePath = [[self projectModel] absoluteProjectPathFromRelativePath:targetRelativePath];

	NSString *localizedSourceFile = [FileTool resolveEquivalentFile:[sourcePath stringByAppendingPathComponent:targetRelativePath]];
	
	// use the language format of the source	
	targetAbsolutePath = [FileTool translatePath:targetAbsolutePath toLanguage:[FileTool languageOfPath:localizedSourceFile]];

    // change the file format if the file already exists in another format
	targetAbsolutePath = [FileTool resolveEquivalentFile:targetAbsolutePath];
	
	// First copy the base language file to the localized language
    if (    (copyOnlyIfExists && [localizedSourceFile isPathExisting])
         || !copyOnlyIfExists
       )
    {
        [[self console] addLog:[NSString stringWithFormat:@"Copy file \"%@\" to \"%@\"", sourceAbsolutePath, targetAbsolutePath] class:[self class]];
        
        [[FileTool shared] preparePath:targetAbsolutePath 
                                atomic:YES
                     skipLastComponent:YES];
        
        [[FileTool shared] copySourceFile:sourceAbsolutePath
                            toReplaceFile:targetAbsolutePath
                                  console:[self console]];				
        
        // Try to translate from the external source path if the file engine can do that. Otherwise
        // we have to rely on the preferences to see what to do: do nothing, replace with external or ask user
        
        FMEngine *engine = [self fileModuleEngineForFile:targetAbsolutePath];
        
        if ([engine supportsContentTranslation])
        {
            [[self console] addLog:[NSString stringWithFormat:@"Translate using file \"%@\"", localizedSourceFile] class:[self class]];
            
            if ([localizedSourceFile isPathExisting] == NO)
            {
                [[self console] addWarning:[NSString stringWithFormat:@"%@ does not exist", [localizedSourceFile lastPathComponent]]
							   description:[NSString stringWithFormat:@"Localized source file \"%@\" does not exist", localizedSourceFile] 
									 class:[self class]];
                
                localizedSourceFile = targetAbsolutePath;
            }
        }
        else if ([localizedSourceFile isPathExisting])
        {
            if ([ImportFilesConflict resolveConflictBetweenProjectFile:targetAbsolutePath
                                                       andImportedFile:localizedSourceFile
                                                              provider:[self projectProvider]] == RESOLVE_USE_IMPORTED_FILE)
            {
                [[self console] addLog:[NSString stringWithFormat:@"Replace non-translatable file \"%@\" by \"%@\"",
                                        targetAbsolutePath, localizedSourceFile]
                                 class:[self class]];
                
                [[FileTool shared] copySourceFile:localizedSourceFile
                                    toReplaceFile:targetAbsolutePath
                                          console:[self console]];
            }
        }        
    }

	FileModel *fileModel = [self createFileModelForLanguage:language sourceFileModel:sourceFileModel usingLocalizedFile:localizedSourceFile];
    
	// Update the relative file path to the one actually existing on the disk
	[fileModel setRelativeFilePath:[[self projectModel] relativePathFromAbsoluteProjectPath:targetAbsolutePath]];
	[fileModel setModificationDate:[targetAbsolutePath pathModificationDate]];
	
	if (    [localizedSourceFile isPathExisting]
         && [[self fileModuleEngineForFile:targetAbsolutePath] supportsContentTranslation]
         && [localizedSourceFile isEqualToString:targetAbsolutePath] == NO
       )
    {
		// Mark the file to be synchronized to disk if it was a strings, nib or any supported content translation file
		// and if the localized source file was different from the target absolute path (they may be equal if the localized file
		// doesn't exist)
		[fileModel setStatus:(1 << FILE_STATUS_SYNCH_TO_DISK)];
		
		// Optionaly apply the localized layout if the user wants
		if (layout && [targetAbsolutePath isPathNib])
        {
			[[NibEngine engineWithConsole:[self console]] translateNibFile:targetAbsolutePath 
													usingLayoutFromNibFile:localizedSourceFile 
														 usingStringModels:[[fileModel fileModelContent] stringsContent]];					
		}
	}
	
	return fileModel;
}

#pragma mark -

- (void)translateFileModel:(FileModel*)fileModel withLocalizedFile:(NSString*)localizedFile
{
	[[self fileModuleEngineForFile:localizedFile] translateFileModel:fileModel withLocalizedFile:localizedFile];
}

- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel usingLocalizedFile:(NSString *)localizedFile
{
	FileModel *fileModel = [self createFileModelForLanguage:language sourceFileModel:sourceFileModel];
    
	// FIX CASE 38
	if ([localizedFile isPathExisting])
    {
		[self translateFileModel:fileModel withLocalizedFile:localizedFile];		
	}
    
	return fileModel;
}

@end
