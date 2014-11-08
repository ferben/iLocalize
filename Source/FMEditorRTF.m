//
//  FMEditorRTF.m
//  iLocalize3
//
//  Created by Jean on 27.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditorRTF.h"

#import "FileController.h"
#import "FileModel.h"
#import "FileModelContent.h"

#import "TextViewCustom.h"

@implementation FMEditorRTF

- (NSString*)nibname
{
	return @"FMEditorRTF";
}

- (BOOL)allowsMultipleSelection
{
	return NO;
}

- (void)updateContent
{
	id base = [[self fileController] baseModelContent];
	if(base) {
		[[mBaseBaseTextView textStorage] setAttributedString:base];
		[[mLocalizedBaseTextView textStorage] setAttributedString:base];
	} else {
        [mBaseBaseTextView setString:@""];
        [mLocalizedBaseTextView setString:@""];
    }
	id localized = [[self fileController] modelContent];
	if(localized)
		[[mLocalizedTranslationTextView textStorage] setAttributedString:localized];		
    else
		[mLocalizedTranslationTextView setString:@""];	
	
	[mBaseBaseTextView setLanguage:[self baseLanguage]];
	[mLocalizedBaseTextView setLanguage:[self baseLanguage]];
	[mLocalizedTranslationTextView setLanguage:[self localizedLanguage]];	
}

- (void)textDidChange:(NSNotification *)notif
{
	NSTextView *tv = [notif object];
	NSAttributedString *as = [[NSAttributedString alloc] initWithAttributedString:[[tv textStorage] copy]];
	if(tv == mLocalizedBaseTextView)
		[[self fileController] setBaseModelContent:as];
	else
		[[self fileController] setModelContent:as];
}

@end
