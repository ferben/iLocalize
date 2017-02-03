//
//  FMEngineRTF.m
//  iLocalize3
//
//  Created by Jean on 27.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineRTF.h"

#import "FileController.h"

#import "FileModel.h"
#import "FileModelContent.h"

@implementation FMEngineRTF

- (BOOL)loadContentsOnlyWhenDisplaying
{
    return YES;
}

- (void)fmLoadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
    [[fileModel fileModelContent] setNonPersistentContent:YES];
    [[fileModel fileModelContent] setContent:[[NSAttributedString alloc] initWithPath:file documentAttributes:nil]];
}

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
    [self fmLoadFile:file intoFileModel:[fileController fileModel]];
}

- (void)fmSaveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
    NSAttributedString *as = [fileController modelContent];    
    NSString *file = [fileController absoluteFilePath];

    NSDictionary *dict = [[NSDictionary alloc] init];
    
    if([file isPathRTF])
        [[as RTFFromRange:NSMakeRange(0, [as length]) documentAttributes:dict] writeToFile:file atomically:NO];
    else if([file isPathRTFD])
        [[as RTFDFileWrapperFromRange:NSMakeRange(0, [as length]) documentAttributes:dict] writeToFile:file atomically:NO updateFilenames:NO];
}

@end
