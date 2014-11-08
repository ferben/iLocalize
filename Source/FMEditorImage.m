//
//  FMEditorImage.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditorImage.h"

#import "FileController.h"

@implementation FMEditorImage

- (NSString*)nibname
{
	return @"FMEditorImage";
}

- (BOOL)allowsMultipleSelection
{
	return NO;
}

- (void)updateContent
{
    NSImage *baseImage = nil;
    NSImage *localizedImage = nil;
    
	if([[self fileController] baseModelContent])
		baseImage = [[NSImage alloc] initWithData:[[self fileController] baseModelContent]];

    if([[self fileController] modelContent])
		localizedImage = [[NSImage alloc] initWithData:[[self fileController] modelContent]];

    [mBaseBaseImageView setImage:baseImage];
    [mLocalizedBaseImageView setImage:baseImage];
    [mLocalizedTranslationImageView setImage:localizedImage];        
}

@end
