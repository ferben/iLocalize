//
//  GlossaryNewWC.m
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryNewWC.h"
#import "GlossaryCreator.h"
#import "GlossaryDocument.h"

#import "GlossaryManager.h"
#import "GlossaryFolder.h"
#import "Glossary.h"

#import "ProjectWC.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileTool.h"

@interface GlossaryNewWC (PrivateMethods)
- (void)defaultsValues;
@end
									
@implementation GlossaryNewWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"GlossaryNew"]) {
		[self defaultsValues];
		[self window];
	}
	return self;
}


#define NAME_KEY	@"NewGlossaryName"
#define PATH_INDEX_KEY	@"NewGlossaryPathIndex"
#define SOURCE_INDEX_KEY @"NewGlossarySourceIndex"
#define INCLUDE_TRANSLATED	@"NewGlossaryIncludeTranslated"
#define INCLUDE_NONTRANSLATED	@"NewGlossaryIncludeNonTranslated"
#define INCLUDE_LOCKED	@"NewGlossaryIncludeLocked"
#define REMOVE_DUPLICATE_ENTRIES_KEY @"NewGlossaryRemoveDuplicateEntries"

- (void)defaultsValues
{
	if([[NSUserDefaults standardUserDefaults] objectForKey:PATH_INDEX_KEY] == nil)
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:PATH_INDEX_KEY];

	if([[NSUserDefaults standardUserDefaults] objectForKey:SOURCE_INDEX_KEY] == nil)
		[[NSUserDefaults standardUserDefaults] setInteger:SOURCE_FILES forKey:SOURCE_INDEX_KEY];

	if([[NSUserDefaults standardUserDefaults] objectForKey:INCLUDE_TRANSLATED] == nil)
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:INCLUDE_TRANSLATED];

	if([[NSUserDefaults standardUserDefaults] objectForKey:INCLUDE_NONTRANSLATED] == nil)
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:INCLUDE_NONTRANSLATED];

	if([[NSUserDefaults standardUserDefaults] objectForKey:INCLUDE_LOCKED] == nil)
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:INCLUDE_LOCKED];

	if([[NSUserDefaults standardUserDefaults] objectForKey:REMOVE_DUPLICATE_ENTRIES_KEY] == nil)
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMOVE_DUPLICATE_ENTRIES_KEY];	
}

#pragma mark -

- (NSString*)name
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:NAME_KEY];
}

- (NSString *)path
{
	NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:PATH_INDEX_KEY];
	return [[[GlossaryManager sharedInstance] globalFoldersAndLocalFoldersForProject:self.projectProvider][index] path];
}

- (NSInteger)sourceIndex
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:SOURCE_INDEX_KEY];
}

- (BOOL)includeTranslatedStrings
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:INCLUDE_TRANSLATED];
}

- (BOOL)includeNonTranslatedStrings
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:INCLUDE_NONTRANSLATED];
}

- (BOOL)includeLockedStrings
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:INCLUDE_LOCKED];
}

- (BOOL)removeDuplicateEntries
{
	// Since 4.0: always remove duplicate entries
	return YES;
//	return [[NSUserDefaults standardUserDefaults] boolForKey:REMOVE_DUPLICATE_ENTRIES_KEY];	
}

#pragma mark -

- (void)buildPathPopup
{
	[mPathPopup removeAllItems];	
	for(GlossaryFolder *folder in [[GlossaryManager sharedInstance] globalFoldersAndLocalFoldersForProject:self.projectProvider]) {
		[mPathPopup addItemWithTitle:[folder nameAndPath]];		
	}
	
	[mPathPopup selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:PATH_INDEX_KEY]];
}

- (void)assignDefaultName
{
	NSString *appName = [self.projectProvider applicationExecutableName];
	NSString *version = [self.projectProvider projectAppVersionString];
	NSString *sourceLanguage = [[self.projectProvider projectController] baseLanguage];
	NSString *targetLanguage = [[self.projectProvider selectedLanguageController] language];
	
	NSMutableString *name = [NSMutableString string];
	[name appendString:appName];
	if([version length] > 0) {
		[name appendString:@"("];
		[name appendString:version];
		[name appendString:@")"];
	}
	if([sourceLanguage length] > 0) {
		[name appendString:@" "];
		[name appendString:[sourceLanguage displayLanguageName]];
	}
	if([targetLanguage length] > 0) {
		[name appendString:@"-"];
		[name appendString:[targetLanguage displayLanguageName]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:name forKey:NAME_KEY];
}

- (void)display
{
	[self buildPathPopup];
	[self assignDefaultName];
	[NSApp beginSheet:[self window] modalForWindow:[[self.projectProvider projectWC] window] modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}

- (NSString*)glossaryPath
{
	return [[[self path] stringByAppendingPathComponent:[self name]] stringByAppendingPathExtension:@"tmx"];		
}

- (BOOL)createGlossary:(NSError **)error
{
	GlossaryCreator *creator = [GlossaryCreator creator];
	[creator setProvider:self.projectProvider];
	[creator setSource:[self sourceIndex]];
	[creator setSourceLanguage:[[self.projectProvider projectController] baseLanguage]];
	[creator setTargetLanguage:[[self.projectProvider selectedLanguageController] language]];
	[creator setIncludeTranslatedStrings:[self includeTranslatedStrings]];
	[creator setIncludeNonTranslatedStrings:[self includeNonTranslatedStrings]];
	[creator setExcludeLockedStrings:![self includeLockedStrings]];
	[creator setRemoveDuplicateEntries:[self removeDuplicateEntries]];
	
	Glossary *g = [creator create];
	g.targetFile = g.file = [self glossaryPath];
	g.format = TMX;
		
	if([g.file isPathExisting])
		[g.file movePathToTrash];
	else
		[[FileTool shared] preparePath:g.file atomic:YES skipLastComponent:YES];
	
	if ([g writeToFile:error])
    {
        NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
        
        [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:g.file] display:YES completionHandler:
         ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *myError)
         {
             if (myError)
                 [documentController presentError:myError];
         }];
        
		return YES;
	}
    else
    {
		return NO;
	}
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];	
}

- (IBAction)create:(id)sender
{
	if ([[self glossaryPath] isPathExisting])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:NSLocalizedStringFromTable(@"GlossaryNewOverwriteTitle",@"Alerts",nil)];
        [alert setInformativeText:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"AlertOverwriteItDescr",@"Alerts",nil), NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)]];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 1st button
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOverwrite",@"Alerts",nil)];   // 2nd button
        
        // show and evaluate alert
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
			return;
		}		
	}

	NSError *error = nil;
    
	if ([self createGlossary:&error])
    {
		[NSApp endSheet:[self window]];
		[[self window] orderOut:self];
	}
    else
    {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
	}
}

@end
