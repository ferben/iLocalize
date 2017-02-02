//
//  ImportFilesWC.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportFilesOVC.h"
#import "ImportAppItem.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "ProjectModel.h"
#import "LanguageTool.h"
#import "ImportFilesSettings.h"

@interface ImportFilesOVC (PrivateMethods)
- (void)updateInterface;
@end

@implementation ImportFilesOVC

@synthesize settings;

- (id)init
{
	if(self = [super initWithNibName:@"ImportFiles"]) {

	}
	return self;
}


- (void)willShow
{
	if([[[self projectProvider] selectedLanguageController] isBaseLanguage])
		[self importBaseRadio:self];
	else {
		[self importOtherRadio:self];
        [mImportImportLayoutsCheckbox setState:NSOnState];
    }
	
	NSString *baseLanguage = [[[self projectProvider] projectModel] baseLanguage];
	[mImportBaseLanguageInfo setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Update “%@” and rebase all other languages. All strings in the other languages will be localized according to the current translation.", NULL), [baseLanguage displayLanguageName]]];

	[mController removeObjects:[mController content]];
	
	NSEnumerator *enumerator = [[[[self projectProvider] projectController] languages] objectEnumerator];
	NSString *language;
	ProjectController *pc = [[self projectProvider] projectController];
	id selectionObject = nil;
	while(language = [enumerator nextObject]) {
		if(![pc isLanguageExisting:language])
			continue;
		
		if([[pc baseLanguage] isEqualCaseInsensitiveToString:language])
			continue;
				
		NSMutableDictionary *o = [NSMutableDictionary dictionaryWithObject:language forKey:@"language"];
		if([[[[self projectProvider] selectedLanguageController] language] isEqualToString:language]) {
			selectionObject = o;			
		}
		o[@"displayLanguage"] = [language displayLanguageName];
		
		[mController addObject:o];
	}
    if(selectionObject)
		[mController setSelectedObjects:@[selectionObject]];
	
    [self updateInterface];
}

- (void)saveSettings
{
	self.settings.updateBaseLanguage = ([mImportBaseRadio state] == NSOnState);
	self.settings.resetLayout = ([mImportCheckLayoutCheckbox state] == NSOnState);
	self.settings.updateNibLayouts = ([mImportImportLayoutsCheckbox state] == NSOnState);
	
    NSInteger index = [mLanguagesTableView selectedRow];
	
    if (index >= 0)
    {
		self.settings.localizedLanguage = [mController content][index][@"language"];		
	}
    else
    {
		self.settings.localizedLanguage = nil;
	}
}

- (NSString*)nextButtonTitle
{
	return NSLocalizedString(@"Update", nil);
}

- (void)willContinue
{
	[self saveSettings];
}

- (void)updateInterface
{
	BOOL visible = self.settings.resetLayout || self.settings.updateNibLayouts;
	[mNibWarningIcon setHidden:!visible];
	[mNibWarningText setHidden:!visible];
}

- (IBAction)keepExistingNibLayouts:(id)sender
{
	[self saveSettings];
	[self updateInterface];	
}

- (IBAction)importNibLayouts:(id)sender
{
	[self saveSettings];
	[self updateInterface];
}

- (IBAction)importBaseRadio:(id)sender
{
	[mImportBaseRadio setState:NSOnState];
	[mImportOtherRadio setState:NSOffState];
	[mImportCheckLayoutCheckbox setEnabled:YES];
	[mImportImportLayoutsCheckbox setEnabled:NO];
	[mLanguagesTableView setEnabled:NO];
}

- (IBAction)importOtherRadio:(id)sender
{
	[mImportBaseRadio setState:NSOffState];
	[mImportOtherRadio setState:NSOnState];
	[mImportCheckLayoutCheckbox setEnabled:NO];
	[mImportImportLayoutsCheckbox setEnabled:YES];
	[mLanguagesTableView setEnabled:YES];
//	[[self window] makeFirstResponder:mLanguagesTableView];
	[mController setSelectionIndex:0];
}

//- (IBAction)help:(id)sender
//{
//    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
//    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"updatefromfiles"  inBook:locBookName];
//}

@end
