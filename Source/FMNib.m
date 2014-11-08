//
//  FMNib.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMNib.h"
#import "FMManager.h"
#import "FMEngineNib.h"
#import "FMControllerNib.h"

@implementation FMNib

- (BOOL)builtIn
{
	return YES;
}

- (NSString*)name
{
	return NSLocalizedStringFromTable(@"Nib/xib", @"LocalizableEditors", @"File Editor Nib");
}

- (NSImage*)fileImage
{
	return [NSImage imageNamed:@"FileIconNib"];
}

- (BOOL)supportsFlagLayout
{
	return YES;
}

- (Class)editorClass
{
	return NSClassFromString(@"FMEditorStrings");
}

- (Class)engineClass
{
	return [FMEngineNib class];
}

- (Class)controllerClass
{
	return [FMControllerNib class];
}

- (void)load
{
	[[self manager] registerFileModule:self forFileExtension:@"nib"];
	[[self manager] registerFileModule:self forFileExtension:@"xib"];
}

@end
