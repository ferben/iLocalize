//
//  RemoveLanguageOperation.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "RemoveLanguageOperation.h"

#import "ProjectController.h"
#import "LanguageController.h"

#import "TableViewCustom.h"
#import "ProjectWC.h"

@implementation RemoveLanguageOperation

- (void)removeLanguage:(LanguageController*)language
{
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Delete “%@”?", nil), [language language]]
                                     defaultButton:NSLocalizedString(@"Delete", nil)
                                   alternateButton:NSLocalizedString(@"Cancel", nil)
                                       otherButton:nil
                         informativeTextWithFormat:NSLocalizedString(@"Do you really want to delete this language? This action cannot be undone.", nil)];
    [alert beginSheetModalForWindow:[self projectWindow]
                      modalDelegate:self
                     didEndSelector:@selector(removeLanguageSheetDidEnd:returnCode:contextInfo:)
                        contextInfo:(__bridge_retained void*)@{@"language" : [language language], @"self" : self }];
}

- (void)removeLanguageSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode != NSAlertDefaultReturn) {
		[self close];
		return;
	}
	
	[[[self projectProvider] projectWC] selectLanguageAtIndex:0];
	
    NSDictionary *info = (__bridge_transfer NSDictionary *)(contextInfo);
    
	// In order for the selection to be changed before removing the language: otherwise, crash can occur
	// because the deleted language can be still updated after it has been removed (or is being removed)
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self operationDispatcher] removeLanguage:info[@"language"] completion:^(id results) {
            [self close];
        }];
    });
}

@end
