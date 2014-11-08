//
//  FMStrings.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMStrings.h"
#import "FMManager.h"
#import "FMEngineStrings.h"
#import "FMControllerStrings.h"

@implementation FMStrings

- (BOOL)builtIn
{
	return YES;
}

- (NSString*)name
{
	return NSLocalizedStringFromTable(@"Strings", @"LocalizableEditors", @"File Editor Strings");
}

- (NSImage*)fileImage
{
	return [NSImage imageNamed:@"FileIconTXT"];
}

- (Class)editorClass
{
	return NSClassFromString(@"FMEditorStrings");
}

- (Class)engineClass
{
	return [FMEngineStrings class];
}

- (Class)controllerClass
{
	return [FMControllerStrings class];
}

- (void)load
{
	[[self manager] registerFileModule:self forFileExtension:@"strings"];
}

@end
