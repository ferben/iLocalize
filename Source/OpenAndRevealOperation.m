//
//  OpenAndRevealOperation.m
//  iLocalize3
//
//  Created by Jean on 02.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OpenAndRevealOperation.h"
#import "SaveAllOperation.h"

#import "ProjectController.h"
#import "FileController.h"

#import "FileTool.h"
#import "NibEngine.h"

@interface NSArray (OpenAndRevealOperation)
- (BOOL)needToSaveToDisk;
@end

@implementation NSArray (OpenAndRevealOperation)

- (BOOL)needToSaveToDisk
{
    NSEnumerator *enumerator = [self objectEnumerator];
    FileController *fc;
    while(fc = [enumerator nextObject]) {
        if([fc statusSynchToDisk])
            return YES;
    }
    return NO;
}

@end

@interface OpenAndRevealOperation (PrivateMethods)
- (void)setFileControllers:(NSArray*)fileControllers;
- (void)open;
- (void)openFiles;
- (BOOL)needsToBeSaved;
- (void)synchronize;
@end

@implementation OpenAndRevealOperation

- (void)awake
{
    mFileControllers = NULL;
}


- (void)openFileControllers:(NSArray*)fileControllers
{
    if([fileControllers count]) {
        [self setFileControllers:fileControllers];
        if([fileControllers needToSaveToDisk])
            [[SaveAllOperation operationWithProjectProvider:[self projectProvider]] checkAndSaveFilesWithConfirmation:YES completion:^{
                [self open];
            }];
        else
            [self open];
    }
}

- (void)revealFileControllers:(NSArray*)fileControllers
{
    FileController *controller;
    for(controller in fileControllers) {
        [FileTool revealFile:[controller absoluteFilePath]];
    }
}

- (void)setFileControllers:(NSArray*)fileControllers
{
    mFileControllers = fileControllers;
}

- (void)open
{   
    [self openFiles];
    [self close];
}

- (void)openFiles
{
    FileController *fc;
    for(fc in mFileControllers) {
        [[self projectProvider] openFileWithExternalEditor:[fc absoluteFilePath]];
    }
}

@end
