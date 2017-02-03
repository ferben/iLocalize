//
//  FMEngineTXT.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineTXT.h"

#import "FileController.h"

#import "FileModel.h"
#import "FileModelContent.h"

#import "ProjectPrefs.h"

#import "StringEncodingTool.h"

@implementation FMEngineTXT

- (BOOL)loadContentsOnlyWhenDisplaying
{
    return YES;
}

- (BOOL)supportsStringEncoding
{
    return YES;
}

- (void)fmLoadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
    NSString *content;    
    if([fileModel hasEncoding]) {
        content = [StringEncodingTool stringWithContentOfFile:file encoding:[fileModel encoding]];
    } else {
        StringEncoding* encoding;
        content = [StringEncodingTool stringWithContentOfFile:file encodingUsed:&encoding defaultEncoding:[self encodingForLanguage:[fileModel language]]];
        [fileModel setEncoding:encoding];
        [fileModel setHasEncoding:YES];
    }
    
    [[fileModel fileModelContent] setNonPersistentContent:YES];
    [[fileModel fileModelContent] setContent:content];
}

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
    [self fmLoadFile:file intoFileModel:[fileController fileModel]];
}

- (void)fmSaveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
    NSData *content = NULL;
    
    if([[fileController filename] isPathplist]) {
        content = [[fileController modelContent] dataUsingEncoding:NSUTF8StringEncoding];        
    } else {
        content = [StringEncodingTool encodeString:[fileController modelContent]
                               toDataUsingEncoding:encoding];        
    }
    
    [content writeToFile:[fileController absoluteFilePath] atomically:NO];
}

@end
