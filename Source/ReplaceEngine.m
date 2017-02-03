//
//  ReplaceEngine.m
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ReplaceEngine.h"
#import "SynchronizeEngine.h"
#import "NibEngine.h"
#import "CheckEngine.h"

#import "FileController.h"
#import "FileModel.h"
#import "FileModelContent.h"

#import "FileTool.h"

#import "Console.h"
#import "OperationWC.h"

@implementation ReplaceEngine

- (void)replaceLocalizedFileControllersWithCorrespondingBase:(NSArray*)fileControllers keepLayout:(BOOL)layout
{
    [[self console] beginOperation:@"Replacing localized files with corresponding base" class:[self class]];    
    [[self operation] setMaxSteps:[fileControllers count]];
    
    NSEnumerator *enumerator = [fileControllers objectEnumerator];
    FileController *fileController;
    while((fileController = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        [[self operation] increment];
        [self replaceLocalizedFileControllerAndCheckAgainWithCorrespondingBase:fileController keepLayout:layout];
    }
    
    [[self console] endOperation];
    
    [self notifyProjectDidBecomeDirty];
}

- (void)replaceLocalizedFileControllerAndCheckAgainWithCorrespondingBase:(FileController*)fileController keepLayout:(BOOL)layout
{
    NSString *baseFile = [fileController absoluteBaseFilePath];
    NSString *localizedFile = [fileController absoluteFilePath];
    
    if([baseFile isEqualToString:localizedFile]) {
        [[self console] addError:[NSString stringWithFormat:@"Failed to replace %@", [localizedFile lastPathComponent]]
                     description:[NSString stringWithFormat:@"Cannot replace file \"%@\" with itself", localizedFile]
                           class:[self class]];
    } else {
        [[self console] addLog:[NSString stringWithFormat:@"Replacing \"%@\" by \"%@\"", localizedFile, baseFile] class:[self class]];
        
        [self replaceLocalizedFileControllerWithCorrespondingBase:fileController keepLayout:layout];
        
        /* Check the file again */
        [[[self engineProvider] checkEngine] checkFileController:fileController];
    }
}

- (void)replaceLocalizedFileControllerWithCorrespondingBase:(FileController*)fileController keepLayout:(BOOL)layout
{
    NSString *baseFile = [fileController absoluteBaseFilePath];
    NSString *localizedFile = [fileController absoluteFilePath];

    [[FileTool shared] preparePath:localizedFile atomic:YES skipLastComponent:NO];
    
    /* Nib file: optionaly keep the layout */
    if(layout && [localizedFile isPathNib]) {
        /* Backup the localized to file to a temporary file */
        NSString *tempFile = [FileTool generateTemporaryFileNameWithExtension:[localizedFile pathExtension]];
        [[FileTool shared] copySourceFile:localizedFile
                            toReplaceFile:tempFile
                                  console:[self console]];            
        
        /* Copy the base file to the localized file */
        [[FileTool shared] copySourceFile:baseFile
                            toReplaceFile:localizedFile
                                  console:[self console]];            
        
        /* Translate the new localized file */
        [[NibEngine engineWithConsole:[self console]] translateNibFile:localizedFile 
                                                usingLayoutFromNibFile:tempFile 
                                                     usingStringModels:[[[fileController fileModel] fileModelContent] stringsContent]];
        
        [tempFile removePathFromDisk];
    } else {
        [[FileTool shared] copySourceFile:baseFile
                            toReplaceFile:localizedFile
                                  console:[self console]];            
    }

    if([localizedFile isPathStrings] || [localizedFile isPathNib])
        [[[self engineProvider] synchronizeEngine] synchronizeToDisk:fileController];
    else
        [[[self engineProvider] synchronizeEngine] synchronizeFromDisk:fileController];
    
    if([localizedFile isPathNib])
        [fileController setStatusCheckLayout:YES];    
}

@end
