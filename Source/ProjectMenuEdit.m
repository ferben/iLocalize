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
    if (self = [super init])
    {
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
    BOOL lock = [(StringController *)[[[self projectWC] selectedStringControllers] firstObject] lock];
    
    for (StringController *sc in [[self projectWC] selectedStringControllers])
    {
        [sc setLock:!lock];
    }
    
    FMEditor *editor = [[self projectWC] currentFileEditor];
    
    if ([editor isKindOfClass:[FMEditorStrings class]])
    {
        FMEditorStrings *stringEditor = (FMEditorStrings *)editor;
        [stringEditor updateLockStates];
    }
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
    
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"ProjectMenuEditChangeTitle",@"Alerts",nil)];
    [alert setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"ProjectMenuEditChangeDescr",@"Alerts",nil), encodingName, encodingName]];
    
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextSave",@"Alerts",nil)];        // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 2nd button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextReload",@"Alerts",nil)];      // 3rd button
    
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse alertReturnCode)
    {
        if (alertReturnCode == NSAlertSecondButtonReturn)
            return;
        
        mWillConvertUsingReload = alertReturnCode == NSAlertThirdButtonReturn;

        [self performSelector:@selector(performEncodingConversion) withObject:nil afterDelay:0];
    }];
     
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
    
    if (action == @selector(smartQuoteSubstitution:))
    {
        [anItem setState:[PreferencesLanguages quoteSubstitutionEnabled]?NSControlStateValueOn:NSControlStateValueOff];
        return YES;
    }

    if (action == @selector(lockString:))
    {
        BOOL lock = [(StringController *)[[[self projectWC] selectedStringControllers] firstObject] lock];
        [anItem setTitle:lock?NSLocalizedString(@"Unlock", nil):NSLocalizedString(@"Lock", nil)];
        
        return [[[self projectWC] selectedStringControllers] count] > 0;
    }
    
    if (action == @selector(fileEncodingMenuAction:))
    {
        StringEncoding *se = [anItem representedObject];
        [anItem setState:[[self projectFiles] encodingStateForSelectedFilesWithEncoding:se]];
        
        if ([[self projectFiles] selectedFilesSupportEncoding])
        {
            return isFilesSelected;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;        
}

@end
