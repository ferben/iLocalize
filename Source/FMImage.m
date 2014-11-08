//
//  FMImage.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMImage.h"
#import "FMManager.h"
#import "FMEngineImage.h"

@implementation FMImage

- (BOOL)builtIn
{
	return YES;
}

- (NSString*)name
{
	return NSLocalizedStringFromTable(@"Images", @"LocalizableEditors", @"File Editor Images");
}

- (NSImage*)fileImage
{
	return [NSImage imageNamed:@"FileIconPict"];
}

- (Class)editorClass
{
	return NSClassFromString(@"FMEditorImage");
}

- (Class)engineClass
{
	return [FMEngineImage class];
}

- (void)load
{
	NSEnumerator *enumerator = [[NSImage imageFileTypes] objectEnumerator];
	NSString *type;
	while(type = [enumerator nextObject]) {
		[[self manager] registerFileModule:self forFileExtension:type];
	}
}

@end
