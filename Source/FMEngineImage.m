//
//  FMEngineImage.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineImage.h"

#import "FileController.h"

#import "FileModel.h"
#import "FileModelContent.h"

@implementation FMEngineImage

- (BOOL)loadContentsOnlyWhenDisplaying
{
    return YES;
}

- (void)fmLoadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
    [[fileModel fileModelContent] setNonPersistentContent:YES];
    [[fileModel fileModelContent] setContent:[[NSData alloc] initWithContentsOfFile:file]];
}

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
    [self fmLoadFile:file intoFileModel:[fileController fileModel]];
}

@end
