//
//  FMTXT.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMTXT.h"

#import "FMManager.h"
#import "FMEditorTXT.h"
#import "FMEngineTXT.h"
#import "FMControllerTXT.h"

@implementation FMTXT

- (BOOL)builtIn
{
	return YES;
}

- (NSString*)name
{
	return NSLocalizedStringFromTable(@"Text", @"LocalizableEditors", @"File Editor Text");
}

- (NSImage*)fileImage
{
	return [NSImage imageNamed:@"FileIconTXT"];
}

- (Class)editorClass
{
	return NSClassFromString(@"FMEditorTXT");
}

- (Class)engineClass
{
	return [FMEngineTXT class];
}

- (Class)controllerClass
{
	return [FMControllerTXT class];
}

- (void)load
{
	[[self manager] registerFileModule:self forFileExtension:@"xml"];
	[[self manager] registerFileModule:self forFileExtension:@"plist"];
	[[self manager] registerFileModule:self forFileExtension:@"txt"];
	[[self manager] registerFileModule:self forFileExtension:@"text"];
	[[self manager] registerFileModule:self forFileExtension:@"css"];
	[[self manager] registerFileModule:self forFileExtension:@"js"];
}

@end
