//
//  NewGlossaryOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 11/30/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "NewGlossaryOperation.h"
#import "ProjectController.h"
#import "ProjectWC.h"

#import "Glossary.h"
#import "GlossaryCreator.h"
#import "GlossaryManager.h"

#import "FileTool.h"
#import "Preferences.h"

typedef NS_ENUM(NSInteger, NewGlossaryOptions)
{
    NewGlossaryOptionsDontView = 0,
    NewGlossaryOptionsAlwaysView,
};

@implementation NewGlossaryOperation

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Collecting Strings…", nil)];

    NSError *error = nil;
    
    for (NSString *language in self.languages)
    {
        if (![self glossaryCreateNewWithLanguage:language error:&error])
        {
            NSString *title = NSLocalizedString(@"Error Creating Glossary", nil);
            NSString *message = NSLocalizedString(@"Error creating glossary for language `%@`: %@", nil);
            [self reportInformativeAlertWithTitle:title
                                          message:[NSString stringWithFormat:message, language, [error localizedDescription]]];
            break;
        }
    }
}

- (void)didExecute
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAlwaysViewGlossaryPrefs])
    {
        NewGlossaryOptions option = [[NSUserDefaults standardUserDefaults] integerForKey:kAlwaysViewGlossaryPrefs];
        
        if (NewGlossaryOptionsAlwaysView == option)
        {
            [self openGeneratedGlossaries];
        }
        
        return;
    }
    
    NSString *title;
    NSString *message;
    
    if (self.languages.count == 1)
    {
        title = NSLocalizedStringFromTable(@"NewGlossaryOperationGlossaryGeneratedTitle",@"Alerts", nil);
        message = NSLocalizedStringFromTable(@"NewGlossaryOperationGlossaryGeneratedDescr",@"Alerts", nil);
    }
    else
    {
        title = NSLocalizedStringFromTable(@"NewGlossaryOperationGlossariesGeneratedTitle",@"Alerts", nil);
        message = NSLocalizedStringFromTable(@"NewGlossaryOperationGlossariesGeneratedDescr",@"Alerts", nil);
    }

    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOpen",@"Alerts",nil)];      // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextDoNothing",@"Alerts",nil)]; // 2nd button
    [alert setShowsSuppressionButton:YES];
    
    // show alert
    NSInteger alertReturnCode = [alert runModal];

    BOOL suppressWarning = [alert suppressionButton].state == NSOnState;

    if (alertReturnCode == NSAlertFirstButtonReturn)
    {
        // View
        if (suppressWarning)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:NewGlossaryOptionsAlwaysView forKey:kAlwaysViewGlossaryPrefs];
        }
        
        [self openGeneratedGlossaries];
    }
    else
    {
        // Don't view
        if (suppressWarning)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:NewGlossaryOptionsDontView forKey:kAlwaysViewGlossaryPrefs];
        }
    }
}

- (BOOL)needsToOverwrite
{
    for (NSString *language in self.languages)
    {
        if ([self glossaryAlreadyExists:language])
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)openGeneratedGlossaries
{
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    
    for (NSString *language in self.languages)
    {
        NSString *path = [self glossaryPathWithTargetLanguage:language];
        
        if ([path isPathExisting])
        {
            [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:YES completionHandler:
             ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
             {
                 if (error)
                     [documentController presentError:error];
             }];
        }
    }
}

- (BOOL)glossaryAlreadyExists:(NSString*)language
{
    return [[self glossaryPathWithTargetLanguage:language] isPathExisting];
}

- (BOOL)glossaryCreateNewWithLanguage:(NSString*)language error:(NSError **)error
{
    GlossaryCreator *creator = [GlossaryCreator creator];
	[creator setProvider:self.projectProvider];
	[creator setSource:SOURCE_LANGUAGE];
	[creator setSourceLanguage:[[self.projectProvider projectController] baseLanguage]];
	[creator setTargetLanguage:language];
	[creator setIncludeTranslatedStrings:YES];
	[creator setIncludeNonTranslatedStrings:NO];
	[creator setExcludeLockedStrings:NO];
	[creator setRemoveDuplicateEntries:YES];
	
	Glossary *g = [creator create];
    
	g.targetFile = g.file = [self glossaryPathWithTargetLanguage:language];
	g.format = TMX;
    
	if ([g.file isPathExisting])
		[g.file movePathToTrash];
	else
		[[FileTool shared] preparePath:g.file atomic:YES skipLastComponent:YES];
	
	return [g writeToFile:error];
}

- (NSString *)glossaryNameForTargetLanguage:(NSString *)targetLanguage
{
	NSString *appName = [self.projectProvider applicationExecutableName];
	NSString *sourceLanguage = [[self.projectProvider projectController] baseLanguage];
	
	NSMutableString *name = [NSMutableString string];
    
	[name appendString:appName];
    
	if ([sourceLanguage length] > 0)
    {
		[name appendString:@" "];
		[name appendString:sourceLanguage];
	}
    
	if ([targetLanguage length] > 0)
    {
		[name appendString:@"-"];
		[name appendString:targetLanguage];
	}
    
    return name;
}

- (NSString *)glossaryPathWithTargetLanguage:(NSString *)targetLanguage
{
	return [[[self localPath] stringByAppendingPathComponent:[self glossaryNameForTargetLanguage:targetLanguage]] stringByAppendingPathExtension:@"tmx"];
}

- (NSString *)localPath
{
    return [[[GlossaryManager sharedInstance] globalFoldersAndLocalFoldersForProject:self.projectProvider][0] path];
}

@end
