//
//  AddLanguageOperation.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AddLanguageOperation.h"
#import "AddLanguageWC.h"
#import "AddCustomLanguageWC.h"
#import "OperationWC.h"
#import "LanguageController.h"
#import "ProjectWC.h"
#import "ProjectController.h"

@implementation AddLanguageOperation

- (AddLanguageWC*)addLanguageWC
{
	return (AddLanguageWC*)[self instanceOfAbstractWCName:@"AddLanguageWC"];
}

- (AddCustomLanguageWC*)addCustomLanguageWC
{
	return (AddCustomLanguageWC*)[self instanceOfAbstractWCName:@"AddCustomLanguageWC"];
}

- (void)addLanguage
{
	[[self addLanguageWC] setDidCloseSelector:@selector(performAddLanguage) target:self];
	[[self addLanguageWC] setRenameLanguage:NO];
	[[self addLanguageWC] showAsSheet];
}

- (void)performAddLanguage
{
	if([[self addLanguageWC] hideCode] != 1) {
		[self close];
		return;
	}
	
	[[self operation] setTitle:NSLocalizedString(@"Add Language…", nil)];
	[[self operation] setCancellable:NO];
	[[self operation] setIndeterminate:NO];
	[[self operation] showAsSheet];
	
    [[self operationDispatcher] addLanguage:[[self addLanguageWC] language] completion:^(id results)
    {
        [[[self projectProvider] projectWC] selectLanguageAtIndex:[[[[self projectProvider] projectController] languages] count] - 1];
        
        [[self operation] hide];
        [self close];
    }];
}

#pragma mark -

- (void)addCustomLanguage
{
	[[self addCustomLanguageWC] setDidCloseSelector:@selector(performAddCustomLanguage) target:self];
	[[self addCustomLanguageWC] setRenameLanguage:NO];		
	[[self addCustomLanguageWC] showAsSheet];	
}

- (void)performAddCustomLanguage
{
	if ([[self addCustomLanguageWC] hideCode] != 1)
    {
		[self close];
		return;
	}
	
	[[self operation] setTitle:NSLocalizedString(@"Add Language…", nil)];
	[[self operation] setCancellable:NO];
	[[self operation] setIndeterminate:NO];
	[[self operation] showAsSheet];
	
    [[self operationDispatcher] addLanguage:[[self addCustomLanguageWC] language] completion:^(id results)
    {
        [[[[self projectProvider] projectWC] languagesController] rearrangeObjects];
        
        [[self operation] hide];
        [self close];
    }];
}

#pragma mark -

- (void)renameLanguage
{
	[[self addLanguageWC] setDidCloseSelector:@selector(performRenameLanguage) target:self];
	[[self addLanguageWC] setRenameLanguage:YES];
	[[self addLanguageWC] showAsSheet];		
}

- (void)performRenameLanguage
{
	if ([[self addLanguageWC] hideCode] != 1)
    {
		[self close];
		return;
	}
	
	[[self operation] setTitle:NSLocalizedString(@"Rename Language…", nil)];
	[[self operation] setCancellable:NO];
	[[self operation] setIndeterminate:NO];
	[[self operation] showAsSheet];
	
    [[self operationDispatcher] renameLanguage:[[self selectedLanguageController] language] toLanguage:[[self addLanguageWC] language] completion:^(id results)
    {
        [[self operation] hide];
        [self close];
    }];
}

#pragma mark -

- (void)renameCustomLanguage
{
	[[self addCustomLanguageWC] setDidCloseSelector:@selector(performRenameCustomLanguage) target:self];
	[[self addCustomLanguageWC] setRenameLanguage:YES];		
	[[self addCustomLanguageWC] showAsSheet];		
}

- (void)performRenameCustomLanguage
{
	if ([[self addCustomLanguageWC] hideCode] != 1)
    {
		[self close];
		return;
	}
	
	[[self operation] setTitle:NSLocalizedString(@"Rename Language…", nil)];
	[[self operation] setCancellable:NO];
	[[self operation] setIndeterminate:NO];
	[[self operation] showAsSheet];
	
    [[self operationDispatcher] renameLanguage:[[self selectedLanguageController] language] toLanguage:[[self addCustomLanguageWC] language] completion:^(id results)
    {
        [[self operation] hide];
        [self close];
    }];
}


@end
