//
//  FMEditorTXT.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditorTXT.h"

#import "FileController.h"
#import "FileModel.h"
#import "FileModelContent.h"

#import "TextViewCustom.h"

@implementation FMEditorTXT

- (NSString*)nibname
{
    return @"FMEditorTXT";
}

- (BOOL)allowsMultipleSelection
{
    return NO;
}

- (void)updateContent
{
    NSString *base = [[self fileController] baseModelContent];
    if(!base)
        base = @"";

    [mBaseBaseTextView setString:base];
    [mLocalizedBaseTextView setString:base];        

    NSString *localized = [[self fileController] modelContent];
    if(!localized)
        localized = @"";
            
    [mLocalizedTranslationTextView setString:localized];    
    
    [mBaseBaseTextView setLanguage:[self baseLanguage]];
    [mLocalizedBaseTextView setLanguage:[self baseLanguage]];
    [mLocalizedTranslationTextView setLanguage:[self localizedLanguage]];
}

- (void)textDidChange:(NSNotification *)notif
{
    NSTextView *tv = [notif object];
    NSString *s = [[tv string] copy];
    if(tv == mLocalizedBaseTextView)
        [[self fileController] setBaseModelContent:s];
    else
        [[self fileController] setModelContent:s];
}

@end
