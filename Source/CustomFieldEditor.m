//
//  CustomFieldEditor.m
//  iLocalize3
//
//  Created by Jean on 16.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "CustomFieldEditor.h"
#import "FMEditorStrings.h"
#import "LayoutManagerCustom.h"

@implementation CustomFieldEditor

- (id)init
{
    if(self = [super init]) {
		LayoutManagerCustom *layoutManager = [[LayoutManagerCustom alloc] init];
		[[self textContainer] replaceLayoutManager:layoutManager];
    }
    return self;
}

- (void)setShowInvisibleCharacters:(BOOL)flag
{
	[(LayoutManagerCustom*)[self layoutManager] setShowInvisibleCharacters:flag];
}

- (BOOL)shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{	
    FMEditor *editor = [self.provider currentFileModuleEditor];
    if([editor isKindOfClass:[FMEditorStrings class]]) {
        FMEditorStrings *editorStrings = (FMEditorStrings*)editor;
        NSString *s = [editorStrings quoteSubstitutionOfString:[self string] range:affectedCharRange replacementString:replacementString];
        if(s) {
            [self insertText:s];
            return NO;            
        } 
    }
	return [super shouldChangeTextInRange:affectedCharRange replacementString:replacementString];
}

@end
