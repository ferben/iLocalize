//
//  SynchronizeEngine.m
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SynchronizeEngine.h"

#import "FMEngine.h"

#import "ProjectPrefs.h"

#import "FileController.h"
#import "FileModel.h"

#import "FileTool.h"

#import "Constants.h"
#import "Console.h"
#import "OperationWC.h"

@implementation SynchronizeEngine

- (void)synchronizeToDisk:(FileController*)fileController
{
    [[self console] addLog:[NSString stringWithFormat:@"File \"%@\" will be updated TO disk", [fileController absoluteFilePath]] class:[self class]];

    NSString *file = [fileController absoluteFilePath];
    
    if([file isPathExisting] == NO)
        [[FileTool shared] preparePath:file atomic:YES skipLastComponent:YES];
    
    FMEngine *fmEngine = [self fileModuleEngineForFile:file];
    if(fmEngine) {
        [fmEngine saveFileController:fileController usingEncoding:[fileController encoding]];        
    }
    
    [fileController setModificationDate:[file pathModificationDate]];
}

- (void)synchronizeToDiskIfNeeded:(FileController*)fileController
{
    [fileController updateStatus];
    if([fileController statusSynchToDisk]) {
        [self synchronizeToDisk:fileController];        
    }
}

- (void)synchronizeFromDisk:(FileController*)fileController
{
    [[self console] addLog:[NSString stringWithFormat:@"File \"%@\" will be updated FROM disk", [fileController absoluteFilePath]] class:[self class]];

    NSString *file = [fileController absoluteFilePath];
    FMEngine *fmEngine = [self fileModuleEngineForFile:file];
    if(fmEngine) {
        [fmEngine reloadFileController:fileController usingFile:file];
    }

    [fileController setModificationDate:[file pathModificationDate]];
    [self notifyProjectDidBecomeDirty];
}

- (void)synchronizeFromDiskIfNeeded:(FileController*)fileController
{
    [fileController updateStatus];
    if([fileController statusSynchFromDisk]) {
        [self synchronizeFromDisk:fileController];        
    }
}

- (void)synchronizeFileController:(FileController*)fileController
{
    [[self console] addLog:[NSString stringWithFormat:@"Synchronizing file \"%@\"", [fileController absoluteFilePath]] class:[self class]];
    
    [fileController updateStatus];
    if([fileController statusSynchFromDisk]) {
        [[self console] addLog:@"File will be updated FROM disk" class:[self class]];
        [self synchronizeFromDisk:fileController];        
    } else if([fileController statusSynchToDisk]) {
        [[self console] addLog:@"File will be updated TO disk" class:[self class]];
        [self synchronizeToDisk:fileController];        
    } else if([fileController statusSynchDone]) {
        [[self console] addLog:@"File is up-to-date." class:[self class]];        
    }
}

- (void)synchronizeFileControllers:(NSArray*)fileControllers
{
    [[self console] beginOperation:@"Synchronizing Files" class:[self class]];
    [[self operation] setMaxSteps:[fileControllers count]];
    
    NSEnumerator *enumerator = [fileControllers objectEnumerator];
    FileController *fileController;
    while((fileController = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        [[self operation] increment];
        [self synchronizeFileController:fileController];
    }
    [[self console] endOperation];
}

@end
