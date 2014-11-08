//
//  ProjectMenuProject.m
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenuProject.h"
#import "ProjectWC.h"
#import "ProjectFilesController.h"
#import "ProjectDocument.h"
#import "ProjectPrefs.h"

#import "LanguageController.h"
#import "FileController.h"
#import "ProjectController.h"

#import "LaunchOperation.h"
#import "SaveAllOperation.h"
#import "RebuildBaseFilesOperation.h"
#import "ReplaceLocalizedFilesOperation.h"
#import "AddLanguageOperation.h"
#import "RemoveLanguageOperation.h"
#import "AddRemoveFilesOperation.h"
#import "LineEndingsConverterOperation.h"
#import "CleanOperation.h"
#import "CheckProjectOperation.h"
#import "StatsOperation.h"
#import "ImportLocalFilesOperation.h"
#import "EncodingOperation.h"

#import "ExportProjectOperationDriver.h"
#import "ImportBundleOperationDriver.h"
#import "ImportFilesOperationDriver.h"
#import "ImportLocalFilesOperationDriver.h"

#import "XLIFFExportOperationDriver.h"
#import "XLIFFImportOperationDriver.h"

#import "FMEditor.h"

@implementation ProjectMenuProject

- (id)init
{
	if((self = [super init])) {
		mProjectExport = [[ExportProjectOVC alloc] init];
		mProjectLabelsWC = [[ProjectLabelsWC alloc] init];
		
		mHistoryManagerWC = [[HistoryManagerWC alloc] init];
		[mHistoryManagerWC setHistoryManager:[self.projectWC historyManager]];
	}
	return self;
}


#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
	BOOL isFilesSelected = [[self.projectWC selectedFileControllers] count]>0;
//	BOOL multipleFilesSelected = [[self selectedFileControllers] count]>1;
	BOOL isBaseLanguage = [self.projectWC isBaseLanguage];
	NSString *language = [[self.projectWC selectedLanguageController] displayLanguage];

	if(action == @selector(exportAgain:)) {
		NSArray *presets = [[self.projectWC projectPreferences] exportSettingsPresets];
		NSMenu *menu = [anItem submenu];
		[menu removeAllItems];
		for(NSDictionary *p in presets) {
			[menu addItemWithTitle:p[@"PRESET_NAME"] action:@selector(exportAgainWithPreset:) keyEquivalent:@""];
		}
		[anItem setHidden:[presets count] == 0];
		return YES;
	}
	
	if(action == @selector(exportToStrings:)) {
		return [[self.projectWC currentFileEditor] canExportToStrings];
	}
	
	if(action == @selector(importUsingXLIFF:) ||
	   action == @selector(importFilesUsingXLIFF:)) {
		return !isBaseLanguage;
	}
	
	if(action == @selector(launch:)) {
		NSString *appName = [[[[self.projectWC projectDocument] sourceApplicationPath] lastPathComponent] stringByDeletingPathExtension]; 
        [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Launch “%@” in %@", nil), appName, language]];
        return YES;
	}
	
	if(action == @selector(reloadFiles:)) {
		return isFilesSelected;
	}

    if(action == @selector(revertLocalizedFiles:)) {
		if([[self.projectWC selectedFileControllers] supportOperation:OPERATION_REBUILD]) {
			if(isBaseLanguage) {
				[anItem setTitle:NSLocalizedString(@"Rebuild Selected Files", nil)];
			} else {
				[anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rebuild Selected Files from “%@”", nil), [[[self.projectWC projectController] baseLanguageController] displayLanguage]]];			
			}
		} else {
			[anItem setTitle:NSLocalizedString(@"Rebuild Selected Files", nil)];
		}
		return isFilesSelected;						
	}
		
	if(action == @selector(renameLanguage:)) {
        if(isBaseLanguage) {
            [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Cannot Rename “%@”", nil), language]];
            return NO;
        } else {
            [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Rename “%@”…", nil), language]];
            return YES;
        }			
	}
	
	if(action == @selector(removeLanguage:)) {
        if(isBaseLanguage) {
            [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Cannot Delete “%@”", nil), language]];
            return NO;
        } else {
            [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete “%@”", nil), language]];
            return YES;
        }			
	}

	if(action == @selector(ignoreSelectedFiles:)) {
		[anItem setState:[[self projectFiles] ignoreStateForSelectedFiles]];
		return isFilesSelected;
	}

	if(action == @selector(deleteSelectedFiles:)) {
		return isFilesSelected;
	}
		
	return YES;
}

#pragma mark -

- (IBAction)launch:(id)sender
{
	[[LaunchOperation operationWithProjectProvider:[self projectDocument]] launch];	
}

- (void)exportProjectWithPresetName:(NSString*)name
{
	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] saveFilesWithoutConfirmation];
	
	NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if([name length] > 0) {
		args[EXPORT_PRESET_NAME] = name;		
	}
	[[ExportProjectOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:args];	
}

- (IBAction)exportProject:(id)sender
{
	[self exportProjectWithPresetName:nil];
}

- (IBAction)exportAgainWithPreset:(id)sender
{
	NSString *presetName = [sender title];
	[self exportProjectWithPresetName:presetName];
}

- (IBAction)exportAgain:(id)sender
{
	// empty implementation to allow the menu item to be connect to this action.
	// Then we update it in the validateMenu method.
}

- (IBAction)exportToXLIFF:(id)sender
{
	[[XLIFFExportOperationDriver driverWithProjectProvider:[self projectDocument]] execute];
}

- (IBAction)exportFilesToXLIFF:(id)sender
{
	NSArray *fcs = [[self projectDocument] selectedFileControllers];
	NSDictionary *args = @{@"fcs": fcs};
	[[XLIFFExportOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:args];
}

- (IBAction)exportToStrings:(id)sender
{
	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] saveFilesWithoutConfirmation];

	[[self projectFiles] exportToStrings];
}

- (IBAction)importUsingBundle:(id)sender
{
	[[ImportBundleOperationDriver driverWithProjectProvider:[self projectDocument]] execute];
}

- (IBAction)importUsingXLIFF:(id)sender
{
	[[XLIFFImportOperationDriver driverWithProjectProvider:[self projectDocument]] execute];
}

- (IBAction)importFilesUsingXLIFF:(id)sender
{
	NSArray *fcs = [[self projectDocument] selectedFileControllers];
	NSDictionary *args = @{@"fcs": fcs};
	[[XLIFFImportOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:args];
}

- (IBAction)importUsingFiles:(id)sender
{
	[[ImportFilesOperationDriver driverWithProjectProvider:[self projectDocument]] execute];
}

#pragma mark -

- (IBAction)reloadFiles:(id)sender
{
	[[SaveAllOperation operationWithProjectProvider:[self projectDocument]] reloadFiles];
}

- (IBAction)revertLocalizedFiles:(id)sender
{
	if([[self.projectWC selectedLanguageController] isBaseLanguage]) {
		[[RebuildBaseFilesOperation operationWithProjectProvider:[self projectDocument]] rebuildBaseFileControllers:[[self projectFiles] selectedFileControllers]];
	} else {
		[[ReplaceLocalizedFilesOperation operationWithProjectProvider:[self projectDocument]] replaceLocalizedFileControllersFromCorrespondingBase:[[self projectFiles] selectedFileControllers]];		
	}
}

#pragma mark -

- (IBAction)addNewLanguage:(id)sender
{
	[[AddLanguageOperation operationWithProjectProvider:[self projectDocument]] addLanguage];	
}

- (IBAction)addCustomLanguage:(id)sender
{
	[[AddLanguageOperation operationWithProjectProvider:[self projectDocument]] addCustomLanguage];
}

- (IBAction)renameLanguage:(id)sender
{
	[[AddLanguageOperation operationWithProjectProvider:[self projectDocument]] renameLanguage];
}

- (IBAction)renameCustomLanguage:(id)sender
{
	[[AddLanguageOperation operationWithProjectProvider:[self projectDocument]] renameCustomLanguage];	
}

- (IBAction)removeLanguage:(id)sender
{
	[[RemoveLanguageOperation operationWithProjectProvider:[self projectDocument]] removeLanguage:[self.projectWC selectedLanguageController]];	
}

#pragma mark -

- (IBAction)addFiles:(id)sender
{
	[[AddRemoveFilesOperation operationWithProjectProvider:[self projectDocument]] addFiles];
}

- (IBAction)addLocalFiles:(id)sender
{
	[[AddRemoveFilesOperation operationWithProjectProvider:[self projectDocument]] addFilesToLanguage:[[self.projectWC selectedLanguageController] language]];
}

- (IBAction)updateLocalFiles:(id)sender
{
	[[ImportLocalFilesOperationDriver driverWithProjectProvider:[self projectDocument]] execute];
}

- (IBAction)ignoreSelectedFiles:(id)sender
{		
	BOOL flag = NO;
	switch([[self.projectWC projectFiles] ignoreStateForSelectedFiles]) {
		case NSOnState: flag = NO; break;
		case NSOffState: flag = YES; break;
		case NSMixedState: flag = YES; break;
	}
	
	for(FileController *fc in [[self.projectWC projectFiles] selectedFileControllers]) {
		FileController *baseFileController = [fc baseFileController];
		for(LanguageController *lc in [[self.projectWC languagesController] content]) {
			[[lc fileControllerMatchingBaseFileController:baseFileController] setIgnore:flag];			
		}
	}
	
	[self.projectWC refreshSelectedFile];
}

- (IBAction)deleteSelectedFiles:(id)sender
{
	[[AddRemoveFilesOperation operationWithProjectProvider:[self projectDocument]] removeFileControllers:[[self projectFiles] selectedFileControllers]];
}

#pragma mark -

- (IBAction)convertLineEndings:(id)sender
{
	[[LineEndingsConverterOperation operationWithProjectProvider:[self projectDocument]] convertFileControllers:[[self projectFiles] selectedFileControllers]];	
}

- (IBAction)clean:(id)sender
{
	[[CleanOperation operationWithProjectProvider:[self projectDocument]] clean];
}

#pragma mark -

- (IBAction)checkProject:(id)sender
{
	[[CheckProjectOperation operationWithProjectProvider:[self projectDocument]] checkProject];
}

- (IBAction)statistics:(id)sender
{
	[[StatsOperation operationWithProjectProvider:[self projectDocument]] stats];
}

#pragma mark -

- (IBAction)projectLabels:(id)sender
{
	[mProjectLabelsWC setProjectProvider:[self projectDocument]];
	[mProjectLabelsWC setParentWindow:[self window]];
	[mProjectLabelsWC showAsSheet];
}

- (IBAction)createSnapshot:(id)sender
{
    [mHistoryManagerWC createSnapshot:[self window]];
}

- (IBAction)manageSnapshots:(id)sender
{
    [mHistoryManagerWC displaySnapshots:[self window]];
}

@end
