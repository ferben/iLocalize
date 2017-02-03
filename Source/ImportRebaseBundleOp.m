//
//  RebaseEngine.m
//  iLocalize3
//
//  Created by Jean on 07.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportRebaseBundleOp.h"

#import "ResourceFileEngine.h"
#import "FileEngine.h"
#import "ModelEngine.h"

#import "FMEngine.h"

#import "ImportDiff.h"

#import "FileTool.h"
#import "LanguageTool.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "ProjectModel.h"
#import "FileModel.h"

#import "Constants.h"
#import "Console.h"
#import "OperationWC.h"

#import "Preferences.h"

@implementation ImportRebaseBundleOp

@synthesize usePreviousLayout=mUsePreviousLayout;
@synthesize importDiff=mImportDiff;

- (id)init
{
    if((self = [super init])) {
    }
    return self;
}


- (LanguageController*)baseLanguageController
{
    return [[self projectController] baseLanguageController];
}

- (NSString*)baseLanguage
{
    return [[self baseLanguageController] language];
}

- (NSString*)projectSourceFilePath
{
    return [[self projectModel] projectSourceFilePath];
}

- (void)setHistoryFilePath:(NSString*)path
{
    mHistoryFilePath = path;
}

- (NSString*)historyFilePath
{
    return mHistoryFilePath;
}

- (NSArray*)allFilesToDelete
{
    return [mImportDiff allFilesToDelete];
}

- (NSArray*)allFilesToAdd
{
    return [mImportDiff allFilesToAdd];
}

- (NSArray*)allFilesToUpdate
{
    return [mImportDiff allFilesToUpdate];
}

- (NSArray*)allFilesIdentical
{
    return [mImportDiff allFilesIdentical];
}

- (FileController*)baseFileControllerForRelativeFilePath:(NSString*)relativeFilePath
{
    return [[[self projectController] baseLanguageController] fileControllerWithRelativePath:relativeFilePath translate:YES];
}

#pragma mark -

- (void)purgeHistoryPath:(NSString*)path
{
    // The sortedContents array contains a list of absolute path of files/folders in increasing
    // order of modification date (from older to most recent)
    NSMutableDictionary *contents = [NSMutableDictionary dictionary];
    
    NSEnumerator *enumerator = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] objectEnumerator];
    NSString *name;
    while((name = [enumerator nextObject])) {
        NSString *file = [path stringByAppendingPathComponent:name];
        if([file isPathInvisible])
            continue;
        
        NSDate *date = [file pathModificationDate];        
        contents[file] = date;
    }
    
    NSArray *sortedContents = [contents keysSortedByValueUsingSelector:@selector(compare:)];
    int count = ([sortedContents count]+1)-[[Preferences shared] maximumNumberOfHistoryFiles];
    if(count > 0) {
        [[self console] addLog:@"Purging history folder" class:[self class]];
        int index;
        for(index = 0; index < count; index++) {
            NSString *file = sortedContents[index];
            [file removePathFromDisk];
            [[self console] addLog:[NSString stringWithFormat:@"Removed \"%@\"", file] class:[self class]];
        }        
    }
}

- (BOOL)moveAppToHistoryFolder
{
    // Move the current application to the "History" folder
    
    [[self console] addLog:@"Archiving old application" class:[self class]];

    NSString *historyPath = [[self projectModel] projectHistoryFolderPath];
    
    [[FileTool shared] preparePath:historyPath
                            atomic:YES
                 skipLastComponent:NO];
    
    [self purgeHistoryPath:historyPath];
    
    NSString *sourceFile = [self projectSourceFilePath];
    NSString *historyAppName = [[[self projectModel] sourceName] stringByDeletingPathExtension];
    NSString *historyAppExt = [[[self projectModel] sourceName] pathExtension];
    NSString *historyAppVersion = [[self projectProvider] projectAppVersionString];
    
    NSString *historyAppFile;
    if([historyAppVersion length] > 0) {
        historyAppFile = [historyAppName stringByAppendingFormat:@" (%@).%@", historyAppVersion, historyAppExt];    
    } else {
        historyAppFile = [historyAppName stringByAppendingFormat:@".%@", historyAppExt];
    }
    NSString *targetFile = [historyPath stringByAppendingPathComponent:historyAppFile];
    
    // Rename the history app name if it already exists by incrementing a number
    int count = 0;
    while([targetFile isPathExisting]) {
        if([historyAppVersion length] > 0) {
            historyAppFile = [historyAppName stringByAppendingFormat:@" (%@) - %d.%@", historyAppVersion, ++count, historyAppExt];        
        } else {
            historyAppFile = [historyAppName stringByAppendingFormat:@" - %d.%@", ++count, historyAppExt];                    
        }
        targetFile = [historyPath stringByAppendingPathComponent:historyAppFile];
    }
        
    if([[FileTool shared] copySourceFile:sourceFile
                               toFile:targetFile
                              console:[self console]])
    {
        [self setHistoryFilePath:targetFile];
        [sourceFile removePathFromDisk];
        return YES;
    } else
        return NO;
}

- (BOOL)copySourceAppToProject:(NSString*)sourcePath
{
    // Copy the new source app inside the project and rename the project model's application name (it can be different for each
    // rebase if, for example, the version is included in the app name).
    
    [[self console] addLog:@"Copying new application to project" class:[self class]];
        
    [[self projectModel] setSourceName:[sourcePath lastPathComponent]];
        
    if([[FileTool shared] copySourceFile:sourcePath
                               toFile:[self projectSourceFilePath]
                              console:[self console]] == NO)
    {
        return NO;
    }
    
    // Update the path of each base language file because they could have changed (e.g. from "en" to "English")
    NSEnumerator *enumerator = [[[self baseLanguageController] fileControllers] objectEnumerator];
    FileController *fc;
    while((fc = [enumerator nextObject])) {
        @autoreleasepool {
            NSString *resolved = [FileTool resolveEquivalentFile:[fc absoluteFilePath]];
            [fc setRelativeFilePath:[[self projectModel] relativePathFromAbsoluteProjectPath:resolved]];
        }
    }
    
    // Remove all languages except the base language    
    NSArray *languages = [LanguageTool languagesInPath:sourcePath];
    NSArray *removeLanguages = [languages arrayOfObjectsNotInArray:[LanguageTool equivalentLanguagesWithLanguage:[self baseLanguage]]];
        
    [[[self engineProvider] resourceFileEngine] removeFilesOfLanguages:removeLanguages
                                                                inPath:[self projectSourceFilePath]];
    
    return YES;    
}

- (void)copyLocalizedFileControllers:(NSArray*)fcs usingExistingFiles:(NSSet*)allExistingFilesSet toLanguage:(NSString*)language
{
    // Perform the copy
    FileController *fc;
    for(fc in fcs) {
        @autoreleasepool {
        
            NSString *relativeBaseFilePath;
            if([fc isLocal]) {
                relativeBaseFilePath = [fc relativeFilePath];                        
            } else {
                relativeBaseFilePath = [[fc baseFileController] relativeFilePath];            
            }
            if([allExistingFilesSet containsObject:relativeBaseFilePath] || allExistingFilesSet == nil || [fc isLocal]) {
                // Convert the base file path to the localized file path by keeping the same language format as the 'language'
                NSString *relativeFilePath = [FileTool translatePath:relativeBaseFilePath toLanguage:language keepLanguageFormat:YES];

                // Resolve the history file as it might be from a different language style (i.e. "fr" instead of "French")
                NSString *historyFilePath = [FileTool resolveEquivalentFile:[[self historyFilePath] stringByAppendingPathComponent:relativeFilePath]];

                if([historyFilePath isPathExisting]) {
                    // Adjust the name of the source file to match the one in history. That way, we keep the format of the language that was previously
                    // used instead of matching the one from the base language
                    relativeFilePath = [FileTool translatePath:relativeFilePath toLanguage:[FileTool languageOfPath:historyFilePath]];

                    // Create the source file path
                    NSString *projectSourceFilePath = [[self projectSourceFilePath] stringByAppendingPathComponent:relativeFilePath];

                    // Update the file controller relative path
                    [fc setRelativeFilePath:relativeFilePath];
                    
                    // Copy the file from history to project
                    [[self console] addLog:[NSString stringWithFormat:@"Copy \"%@\" to \"%@\"", historyFilePath, projectSourceFilePath]  class:[self class]];
                    [[FileTool shared] copySourceFile:historyFilePath
                                               toFile:projectSourceFilePath
                                              console:[self console]];                
                }                
            }            
        
        }
    }        
}

- (void)copyLocalizedFiles
{
    // Copy all used localized files from "History" to project
    [[self console] beginOperation:@"Copying localized files" class:[self class]];
    
    // Make sure to copy only the existing files (because the deleted files are not yet reflected in the LanguageController, we might
    // copy files that do not exist in the new bundle)
    NSArray *allExistingFiles = [mImportDiff allExistingFiles];
    
    // Build a map of existing files equivalent path to speed up the lookup
    NSMutableSet *allExistingFilesSet = nil;
    if(allExistingFiles) {
        allExistingFilesSet = [[NSMutableSet alloc] init];
        for(id loopItem in allExistingFiles) {
            NSArray *equivalentPaths = [FileTool equivalentLanguagePaths:loopItem];
            [allExistingFilesSet addObjectsFromArray:equivalentPaths];
        }        
    }
            
    NSEnumerator *languagesEnumerator = [[[[self projectProvider] projectController] languageControllers] objectEnumerator];
    LanguageController *lc;
    while((lc = [languagesEnumerator nextObject])) {
        if([lc isBaseLanguage]) continue;
        
        NSString *language = [lc language];
        [self copyLocalizedFileControllers:[lc fileControllers] usingExistingFiles:allExistingFilesSet toLanguage:language];
    }        
    

    [[self console] endOperation];
}

#pragma mark -

- (void)processDeletedFileControllers
{
    // Delete file controllers from ProjectController only - not from the disk because they are already not existing (see preparation)
    
    NSArray *files = [self allFilesToDelete];
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Deleting %ld unused files", [files count]] class:[self class]];
    
    NSString *relativeFile;
    for(relativeFile in files) {
        [self progressIncrement];
        FileController *fc = [self baseFileControllerForRelativeFilePath:relativeFile];
        if(fc) {
            [[[self engineProvider] fileEngine] deleteFileController:fc removeFromDisk:NO];            
        } else {
            ERROR(@"Cannot delete file because base controller not found: %@", relativeFile);
        }

    }        
    
    [[self console] endOperation];
}

- (void)processNothingFileControllers
{
    // Process files that have not changed. Basically, we have to synchronize the date of the file because
    // the copy process could have changed them (but the file are identical otherwise they would be in the
    // mUpdatedBaseFileControllers array and not in mNothingBaseFileControllers!)
    
    NSArray *files = [self allFilesIdentical];

    NSString *relativeFile;
    for(relativeFile in files) {
        @autoreleasepool {

            NSEnumerator *languageEnumerator = [[[self projectController] languageControllers] objectEnumerator];
            LanguageController *lc;
            while((lc = [languageEnumerator nextObject])) {
                FileController *fileController = [lc fileControllerWithRelativePath:relativeFile translate:YES];
                [fileController setModificationDate:[[fileController absoluteFilePath] pathModificationDate]];
            }            
        
        }
    }                
}

- (void)processNewRelativeSourceFiles
{
    // Add new file controllers to ProjectController only
    
    NSArray *files = [self allFilesToAdd];
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Adding %ld new files", [files count]] class:[self class]];
    
    for(NSString *relativeFile in files) {
        @autoreleasepool {

            [self progressIncrement];
            [[self console] addLog:[NSString stringWithFormat:@"Adding file (controller only) \"%@\"", relativeFile] class:[self class]];

            FileModel *baseFileModel = [[[self engineProvider] modelEngine] createFileModelFromProjectFile:[[self projectSourceFilePath] stringByAppendingPathComponent:relativeFile]];
            NSArray *fcs = [[[self engineProvider] fileEngine] addBaseFileModel:baseFileModel copyFile:YES];
            
            for(FileController *fc in fcs) {
                [fc setStatusUpdateAdded:YES];
            }            
        
        }
    }        
    
    [[self console] endOperation];
}

#pragma mark -

- (FMEngine*)fileModuleEngineForFile:(NSString*)file
{
    return [self.projectProvider fileModuleEngineForFile:file];
}

- (void)processRebaseBaseFileController:(FileController*)baseFileController withContent:(id)content languageController:(LanguageController*)languageController
{
    FileController *fileController = [languageController fileControllerWithRelativePath:[baseFileController relativeFilePath] translate:YES];
    if(fileController == NULL) {
        [[self console] addError:[NSString stringWithFormat:@"FileController not found for %@", [[baseFileController relativeFilePath] lastPathComponent]]
                     description:[NSString stringWithFormat:@"Cannot find FileController for relative path \"%@\"", [baseFileController relativeFilePath]] 
                           class:[self class]];
        return;
    }
    
    if([fileController ignore]) {
        return;
    }
    
    // Base language: simply replace old content by the new one
    // Localized language(s): replace the old content by the new one and translate as possible
        
    [[self console] beginOperation:[NSString stringWithFormat:@"Language \"%@\", rebase file \"%@\"", [languageController language], [baseFileController absoluteFilePath]] class:[self class]];

    if([languageController isBaseLanguage]) {
        [[self fileModuleEngineForFile:[fileController filename]] rebaseFileContentWithContent:content 
                                                                                fileController:fileController];        
    } else {
        // FIX CASE 43 - do not rebase a localized file that does not exist because it will display unnecessary error message in the console for the user
        if([[fileController absoluteFilePath] isPathExisting]) {
            [[self fileModuleEngineForFile:[fileController filename]] rebaseAndTranslateContentWithContent:content 
                                                                                            fileController:fileController 
                                                                                       usingPreviousLayout:mUsePreviousLayout];                            
        }
    }

    [fileController setStatusUpdateUpdated:YES];
    
    [[self console] endOperation];
}

- (void)processRebaseBaseFileController:(FileController*)baseFileController usingFile:(NSString*)file
{
    int eolType = -1;
    id content = [[self fileModuleEngineForFile:file] rebaseBaseFileController:baseFileController usingFile:file eolType:&eolType];
    [[baseFileController fileModel] setEOLType:eolType];
    
    // Rebase all languages
    NSEnumerator *enumerator = [[[self projectController] languageControllers] objectEnumerator];
    LanguageController *languageController;
    while((languageController = [enumerator nextObject])) {
        [self processRebaseBaseFileController:baseFileController 
                                  withContent:content
                           languageController:languageController];
    }
}

- (void)processUpdateFileControllers
{
    NSArray *files = [self allFilesToUpdate];

    [[self console] beginOperation:[NSString stringWithFormat:@"Updating %ld files", [files count]] class:[self class]];
    
    [files enumerateObjectsWithOptions:NSEnumerationConcurrent
                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSString *relativeFile = obj;
                                @autoreleasepool {
                                    [self progressIncrement];
                                    [self processRebaseBaseFileController:[self baseFileControllerForRelativeFilePath:relativeFile]
                                                                usingFile:[[self projectSourceFilePath] stringByAppendingPathComponent:relativeFile]];                                
                                }
                            }];
    
//    NSEnumerator *enumerator = [files objectEnumerator];
//    NSString *relativeFile;
//    while((relativeFile = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//
//        [[self operation] increment];
//                
//        [self processRebaseBaseFileController:[self baseFileControllerForRelativeFilePath:relativeFile]
//                                    usingFile:[[self projectSourceFilePath] stringByAppendingPathComponent:relativeFile]];
//        
//        [pool release];
//    }        
    
    [[self console] endOperation];
}

#pragma mark -


- (void)rebaseUsingSourcePath:(NSString*)sourcePath
{        
    [[self console] beginOperation:[NSString stringWithFormat:@"Rebase project using source \"%@\" (use previous layout = %d)", sourcePath, mUsePreviousLayout] class:[self class]];
    
    [self setOperationName:NSLocalizedString(@"Archiving Current Bundle…", @"Rebase Operation")];
    
    if(![self moveAppToHistoryFolder])
        goto end;
    
    [self setOperationName:NSLocalizedString(@"Copying Source to Project…", @"Rebase Operation")];
    
    if(![self copySourceAppToProject:sourcePath])
        goto end;
    
    [self copyLocalizedFiles];
    
    // How the number of max steps is computed ?
    // processDeletedFileControllers:        [mImportDiff allFilesToDelete]
    // processNewRelativeSourceFiles:        [mImportDiff allFilesToAdd]
    // processUpdateFileControllers:        [mImportDiff allFilesToUpdate]
    
    [self setOperationName:NSLocalizedString(@"Updating Project…", @"Rebase Operation")];
    [self setProgressMax:[[self allFilesToDelete] count]+[[self allFilesToAdd] count]+[[self allFilesToUpdate] count]];
    
    [[self projectProvider] setUndoManagerEnabled:NO];
    @try {
        [self processDeletedFileControllers];
        [self processNothingFileControllers];
        [self processNewRelativeSourceFiles];
        [self processUpdateFileControllers];        
    }
    @finally {
        [[self projectProvider] setUndoManagerEnabled:YES];
    }
    
end:
    [[self console] endOperation];
    
    [self notifyProjectDidBecomeDirty];
}

- (void)rebaseFileController:(FileController*)fileController usingFile:(NSString*)file
{
    FileController *baseFileController = [[self projectController] correspondingBaseFileControllerForFileController:fileController];
    if(baseFileController == NULL)
        return;
    
    if([fileController ignore]) 
        return;
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Rebase file \"%@\" using source \"%@\" (usePreviousLayout = %d)", [baseFileController relativeFilePath], file, mUsePreviousLayout] class:[self class]];
    
    [[FileTool shared] copySourceFile:file
                        toReplaceFile:[baseFileController absoluteFilePath]
                              console:[self console]];
    
    [self processRebaseBaseFileController:baseFileController
                                usingFile:file];
    
    [[self console] endOperation];
}

- (void)rebaseFileControllers:(NSArray*)fileControllers usingCorrespondingFiles:(NSArray*)files
{
    [[self console] beginOperation:[NSString stringWithFormat:@"Rebase %lu files", [files count]] class:[self class]];
    [self setProgressMax:[files count]];
    
    unsigned index;
    for(index=0; index<[fileControllers count]; index++) {
        FileController *fc = fileControllers[index];
        if([fc ignore]) continue;
        
        [self progressIncrement];
        [self rebaseFileController:fc
                         usingFile:files[index]];
    }
    [[self console] endOperation];
    
    [self notifyProjectDidBecomeDirty];
}

- (void)rebaseBaseFileControllers:(NSArray*)fileControllers keepLayout:(BOOL)layout
{
    NSMutableArray *files = [NSMutableArray array];
    FileController *fc;
    for(fc in fileControllers) {
        NSString *file = [fc absoluteFilePath];
        NSString *tempFile = [FileTool generateTemporaryFileNameWithExtension:[file pathExtension]];
        [[FileTool shared] copySourceFile:file
                            toReplaceFile:tempFile
                                  console:[self console]];
        [files addObject:tempFile];
    }
    [self setUsePreviousLayout:layout];
    [self rebaseFileControllers:fileControllers usingCorrespondingFiles:files];
}

#pragma mark -

- (BOOL)needsDisconnectInterface
{
    return YES;
}

- (void)execute
{
    [self rebaseUsingSourcePath:self.importDiff.source];    
}

@end
