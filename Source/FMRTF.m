//
//  FMRTF.m
//  iLocalize3
//
//  Created by Jean on 27.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMRTF.h"
#import "FMManager.h"
#import "FMEngineRTF.h"

@implementation FMRTF

- (BOOL)builtIn
{
    return YES;
}

- (NSString*)name
{
    return NSLocalizedStringFromTable(@"RT/RTFD", @"LocalizableEditors", @"File Editor RTF");
}

- (NSImage*)fileImage
{
    return [NSImage imageNamed:@"FileIconRTF"];
}

- (Class)editorClass
{
    return NSClassFromString(@"FMEditorRTF");
}

- (Class)engineClass
{
    return [FMEngineRTF class];
}

- (void)load
{
    [[self manager] registerFileModule:self forFileExtension:@"rtf"];
    [[self manager] registerFileModule:self forFileExtension:@"rtfd"];
}

@end
