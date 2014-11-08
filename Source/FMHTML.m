//
//  FMHTML.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMHTML.h"

#import "FMManager.h"
#import "FMEditorHTML.h"
#import "FMEngineHTML.h"
#import "FMControllerHTML.h"

@implementation FMHTML

- (BOOL)builtIn
{
	return YES;
}

- (NSString*)name
{
	return NSLocalizedStringFromTable(@"HTML", @"LocalizableEditors", @"File Editor HTML");
}

- (NSImage*)fileImage
{
	return [NSImage imageNamed:@"FileIconHTML"];
}

- (Class)editorClass
{
	return NSClassFromString(@"FMEditorHTML");
}

- (Class)engineClass
{
	return [FMEngineHTML class];
}

- (Class)controllerClass
{
	return [FMControllerHTML class];
}

- (void)load
{
	[[self manager] registerFileModule:self forFileExtension:@"htm"];
	[[self manager] registerFileModule:self forFileExtension:@"html"];
}

@end
