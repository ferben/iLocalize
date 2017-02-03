//
//  RebaseEngineDiff.m
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportBundlePreviewOp.h"
#import "ResourceFileEngine.h"
#import "BundleSource.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "FileTool.h"
#import "LanguageTool.h"
#import "NibEngine.h"

#import "ImportDiff.h"

#include <libkern/OSAtomic.h>

@implementation ImportBundlePreviewOp

@synthesize sourcePath;
@synthesize importDiff;

- (id)init
{
    if ((self = [super init]))
    {
        mFilesToAdd = [[NSMutableArray alloc] init];
        mFilesToUpdate = [[NSMutableArray alloc] init];
        mFilesToDelete = [[NSMutableArray alloc] init];
        mFilesIdentical = [[NSMutableArray alloc] init];
    }
    
    return self;
}


- (NSString *)baseLanguage
{
    return [[self projectController] baseLanguage];
}

- (NSArray *)getAllSourceRelativeFiles
{
    // Build the list of all files (relative path) in the base language of the source
    
    NSMutableArray *files = [NSMutableArray array];
    
    ResourceFileEngine *rfe = [ResourceFileEngine engine];
    [rfe parseFiles:[sourcePath sourceFiles]];
    
    NSEnumerator *enumerator = [[rfe filesOfLanguage:[[self projectController] baseLanguage]] objectEnumerator];
    NSString *absoluteSourceFile;
    
    while ((absoluteSourceFile = [enumerator nextObject]))
    {
        [files addObject:[absoluteSourceFile stringByRemovingPrefix:sourcePath.sourcePath]];
    }
    
    return files;    
}

- (BOOL)shouldUpdateProjectFile:(NSString *)relativeProjectFile sourceFile:(NSString *)relativeSourceFile
{
    NSString *projectAbsoluteFile = [[self projectController] absoluteProjectPathFromRelativePath:relativeProjectFile];
    NSString *sourceAbsoluteFile = [sourcePath.sourcePath stringByAppendingPathComponent:relativeSourceFile];
    
    // Check first by using a binary comparison if the files are identical.
    if ([projectAbsoluteFile isPathContentEqualsToPath:sourceAbsoluteFile])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSArray *)filesToAdd
{
    return mFilesToAdd;
}

- (NSArray *)filesToUpdate
{
    return mFilesToUpdate;
}

- (NSArray *)filesToDelete
{
    return mFilesToDelete;    
}

- (NSArray *)filesIdentical
{
    return mFilesIdentical;
}

- (BOOL)needsToRebase
{
    return ([[self filesToAdd] count]+[[self filesToUpdate] count]+[[self filesToDelete] count]) > 0;
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Analyzing Bundle for Changes…", nil)];

    [mFilesToAdd removeAllObjects];
    [mFilesToUpdate removeAllObjects];
    [mFilesToDelete removeAllObjects];
    [mFilesIdentical removeAllObjects];
    
    // Build the list of all kinds of files using the project controller's list of files and the source files
    NSArray *allSourceRelativeFiles = [self getAllSourceRelativeFiles];
    [mFilesToAdd addObjectsFromArray:allSourceRelativeFiles];
    
    NSArray *fcs = [[[self projectController] baseLanguageController] fileControllers];
    NSUInteger total = [fcs count];
    __block int32_t executed = 0;
    [self setOperationProgress:0];

    [fcs enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FileController *projectBaseFileController = obj;

        // Skip local file
        if ([projectBaseFileController isLocal])
            return;
        
        NSString *projectRelativeBaseFile = [projectBaseFileController relativeFilePath];    
        
        NSString *sp;
        
        for (sp in [FileTool equivalentLanguagePaths:projectRelativeBaseFile])
        {
            if ([allSourceRelativeFiles containsObject:sp])
                break;
        }
        
        if (sp)
        {
            // File exists in the source... now see if the file needs to be updated
            if ([self shouldUpdateProjectFile:projectRelativeBaseFile sourceFile:sp])
            {
                // File should be updated
                @synchronized(self)
                {
                    [mFilesToUpdate addObject:sp];
                }
            }
            else
            {
                // File is identical
                @synchronized(self)
                {
                    [mFilesIdentical addObject:projectRelativeBaseFile];
                }
            }
            
            // The file exists in the project, so it doesn't count as a "new" file
            @synchronized(self)
            {
                [mFilesToAdd removeObject:sp];
            }
        }
        else
        {
            // File doesn't exist in the source, it has to be deleted
            @synchronized(self)
            {
                [mFilesToDelete addObject:projectRelativeBaseFile];
            }
        }            
        
        
        int32_t current = OSAtomicAdd32(1, &executed);
        [self setOperationProgress:(float)current/total];
        
        *stop = [self cancel];
    }];
    
    // Make sure to update the import diff
    [importDiff clear];        
    [importDiff setSource:[self sourcePath].sourcePath];            
    [importDiff addFilesToAdd:[self filesToAdd]];
    [importDiff addFilesToDelete:[self filesToDelete]];
    [importDiff addFilesToUpdate:[self filesToUpdate]];
    [importDiff addFilesIdentical:[self filesIdentical]];        
}

- (BOOL)cancellable
{
    return YES;
}

@end
