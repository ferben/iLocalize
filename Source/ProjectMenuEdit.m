//
//  ProjectMenuEdit.m
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenuEdit.h"
#import "ProjectController.h"
#import "ProjectWC.h"
#import "ProjectDocument.h"
#import "ProjectFilesController.h"
#import "ProjectViewSearchController.h"
#import "ProjectExplorerController.h"

#import "Explorer.h"
#import "ExplorerFilter.h"

#import "FMEditorStrings.h"

#import "PreferencesFilters.h"
#import "PreferencesLanguages.h"
#import "StringController.h"

#import "StringEncoding.h"
#import "EncodingOperation.h"

@implementation ProjectMenuEdit

- (id)init
{
	if(self = [super init]) {
	}
	return self;
}


#pragma mark -

- (IBAction)smartQuoteSubstitution:(id)sender
{
	[PreferencesLanguages setQuoteSubstitutionEnabled:![PreferencesLanguages quoteSubstitutionEnabled]];
}
	
- (IBAction)lockString:(id)sender
{
	BOOL lock = [(StringController*)[[[self projectWC] selectedStringControllers] firstObject] lock];
	for(StringController *sc in [[self projectWC] selectedStringControllers]) {
		[sc setLock:!lock];
	}
    FMEditor *editor = [[self projectWC] currentFileEditor];
    if ([editor isKindOfClass:[FMEditorStrings class]]) {
        FMEditorStrings *stringEditor = (FMEditorStrings*)editor;
        [stringEditor updateLockStates];
    }
}

- (void)encodingConvertAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertAlternateReturn) {
		return;
	}
	
	mWillConvertUsingReload = returnCode == NSAlertOtherReturn;
	[self performSelector:@selector(performEncodingConversion) withObject:nil afterDelay:0];
}

- (void)performEncodingConversion
{
	[[EncodingOperation operationWithProjectProvider:[self projectDocument]] convertFileControllers:[self.projectWC selectedFileControllers] 
																						 toEncoding:mWillConvertUsingEncoding
																							 reload:mWillConvertUsingReload];
}

- (IBAction)fileEncodingMenuAction:(id)sender
{
	mWillConvertUsingEncoding = [(NSMenuItem*)sender representedObject];
	NSString *encodingName = [mWillConvertUsingEncoding encodingName];
	
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Change the encoding of the selected files?", nil) 
									 defaultButton:NSLocalizedString(@"Save", nil)
								   alternateButton:NSLocalizedString(@"Cancel", nil)
									   otherButton:NSLocalizedString(@"Reload", nil)
						 informativeTextWithFormat:NSLocalizedString(@"Do you want to reload each file as '%@' or save the current in-memory content of each file as a '%@' file?", nil), encodingName, encodingName];
	[alert beginSheetModalForWindow:[self.projectWC window] 
					  modalDelegate:self
					 didEndSelector:@selector(encodingConvertAlertDidEnd:returnCode:contextInfo:) 
						contextInfo:nil];
}

/**
 Invoked when using the command Edit > Find > Search Project
 */
- (IBAction)searchProject:(id)sender
{
	[[self projectWC] selectSearchField];
}

/**
 Invoked when the user presses enter in the search field of the project window.
 */
- (IBAction)search:(id)sender
{
	[[self projectWC] doSearch];
}

#pragma mark -
#pragma mark Actions

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
	BOOL isFilesSelected = [[self.projectWC selectedFileControllers] count] > 0;
	
	if(action == @selector(smartQuoteSubstitution:)) {
		[anItem setState:[PreferencesLanguages quoteSubstitutionEnabled]?NSOnState:NSOffState];
		return YES;
	}

	if(action == @selector(lockString:)) {
		BOOL lock = [(StringController*)[[[self projectWC] selectedStringControllers] firstObject] lock];
		[anItem setTitle:lock?NSLocalizedString(@"Unlock", nil):NSLocalizedString(@"Lock", nil)];
		return [[[self projectWC] selectedStringControllers] count] > 0;
	}
	
	if(action == @selector(fileEncodingMenuAction:)) {
		StringEncoding *se = [anItem representedObject];
		[anItem setState:[[self projectFiles] encodingStateForSelectedFilesWithEncoding:se]];
		
		if([[self projectFiles] selectedFilesSupportEncoding]) {
			return isFilesSelected;
		} else {
			return NO;
		}
	}
	
	return YES;		
}

@end
