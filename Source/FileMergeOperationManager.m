//
//  FileMergeOperationManager.m
//  iLocalize
//
//  Created by Jean Bovet on 6/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "FileMergeOperationManager.h"
#import "FileOperationManager.h"
#import "FileTool.h"

@implementation FileMergeOperationManager

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


+ (FileMergeOperationManager*)manager
{
    return [[self alloc] init];
}

- (BOOL)isLocalizedFile:(NSString*)a identicalToFile:(NSString*)b
{
    a = [FileTool resolveEquivalentFile:a];
    b = [FileTool resolveEquivalentFile:b];
    
    return [a isPathContentEqualsToPath:b];
}

- (BOOL)discoverMergeableFiles:(NSMutableArray*)mergeableFiles inTarget:(NSString*)target usingProjectFiles:(NSArray*)projectFiles projectSource:(NSString*)source errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler
{
    [mergeableFiles removeAllObjects];

    __block BOOL success = YES;
    FileOperationManager *fileOpManager = [FileOperationManager manager];
    NSMutableArray *targetFiles = [NSMutableArray array];
    if([fileOpManager enumerateDirectory:target files:targetFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        if(handler) {
            handler(url, error);
        } else {
            ERROR(@"Error while enumerating the directory: %@ at %@", error, url);            
        }
        success = NO;
        return NO;
    }]) {
        for(NSString *projectFile in projectFiles) {

            // Find out which project file has a correspondant in the project, and if so, make sure it is different from it.
            NSString *candidateFile = nil;
            if([targetFiles containsObject:projectFile]) {
                candidateFile = projectFile;
            } else {
                // Try all the variant of the language, if this file has a language
                for(NSString *variantFile in [FileTool equivalentLanguagePaths:projectFile]) {
                    if([targetFiles containsObject:variantFile]) {
                        candidateFile = variantFile;
                        break;
                    }
                }                
            }
            
            if(candidateFile) {
                // Make sure the file is not identical to its target
                NSString *absoluteProjectFile = [source stringByAppendingPathComponent:candidateFile];
                NSString *absoluteTargetFile = [target stringByAppendingPathComponent:candidateFile];
                if(![self isLocalizedFile:absoluteProjectFile identicalToFile:absoluteTargetFile]) {
                    [mergeableFiles addObject:candidateFile];
                }
            } else {
                // File is not in the target, but we will merge it because it comes from the project
                [mergeableFiles addObject:projectFile];
            }
        }
    }
    return success;
}

- (void)mergeProjectFiles:(NSArray*)projectFiles projectSource:(NSString*)source inTarget:(NSString*)target errorHandler:(BOOL (^)(NSError *error))handler progressHandler:(void (^)(NSString *source, NSString *target))progress
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    for(NSString *pf in projectFiles) {
        NSString *absoluteProjectFile = [source stringByAppendingPathComponent:pf];
        absoluteProjectFile = [FileTool resolveEquivalentFile:absoluteProjectFile];
        
        NSString *absoluteTargetFile = [target stringByAppendingPathComponent:pf];
        absoluteTargetFile = [FileTool resolveEquivalentFile:absoluteTargetFile];
        if(![absoluteTargetFile isPathExisting]) {
            // skip files that cannot be found in the target
            LOG_DEBUG(@"Skip because file doesn't not exist in target: %@", absoluteProjectFile);
            continue;
        }
        
        if([absoluteTargetFile removePathFromDisk]) {
            NSError *error = nil;
            if(![fm copyItemAtPath:absoluteProjectFile toPath:absoluteTargetFile error:&error]) {
                if(handler) {
                    handler(error);
                }
            }
        }
        
        if(progress) {
            progress(absoluteProjectFile, absoluteTargetFile);
        }
    }
}

@end
