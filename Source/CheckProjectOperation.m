//
//  CheckProjectOperation.m
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "CheckProjectOperation.h"
#import "CheckProjectWC.h"
#import "OperationWC.h"

#import "ProjectController.h"
#import "PreferencesGeneral.h"

#import "ASManager.h"
#import "CheckEngine.h"

@implementation CheckProjectOperation

- (CheckProjectWC *)checkProjectWC
{
    return (CheckProjectWC *)[self instanceOfAbstractWCName:@"CheckProjectWC"];
}

- (void)awake
{
    mDisplayAlertIfSuccess = YES;
}

- (void)setDelegate:(id<CheckProjectDelegate>)delegate
{
    mDelegate = delegate;
}

- (void)checkSelectedFile
{
    CheckEngine *engine = [[[self projectProvider] engineProvider] checkEngine];
    [engine checkFileController:[[[self projectProvider] selectedFileControllers] firstObject]];
}

- (void)checkProject
{
    [[self checkProjectWC] setDidCloseSelector:@selector(performCheckProject) target:self];
    [[self checkProjectWC] showAsSheet];
}

- (void)performCheckProject
{    
    if ([[self checkProjectWC] hideCode] == 0)
    {
        [self close];
        return;
    }
    
    [self checkLanguages:[[self checkProjectWC] checkLanguages]];    
}

- (void)checkAllProject
{
    mDisplayAlertIfSuccess = YES;
    [self checkLanguages:[[[self projectProvider] projectController] languages]];
}

- (void)checkAllProjectNoAlertIfSuccess
{
    mDisplayAlertIfSuccess = NO;
    [self checkLanguages:[[[self projectProvider] projectController] languages]];
}

- (void)checkLanguages:(NSArray*)languages
{
#pragma warning WHAT THE HECK IS THIS?
    [[self operation] setTitle:NSLocalizedString(@"Checking…", nil)];
    [[self operation] setCancellable:YES];
    [[self operation] setIndeterminate:NO];
    [[self operation] showAsSheet];
    
    [[self operationDispatcher] checkProjectLanguages:languages completion:^(id results)
    {
        [self performCheckEnded:results];
    }];
}

- (void)performCheckEnded:(id)results
{    
    [[self operation] hide];    
    [self close];
    
    if ([[PreferencesGeneral shared] autoUpdateSmartFilters])
        [self refreshListOfFiles];

    NSString *info;
    int warnings = [results intValue];
    
    if (warnings == 0)
    {
        info = NSLocalizedString(@"No inconsistencies have been detected.", nil);
    }
    else
    {
        NSString *firstPart;
        
        if (warnings > 1)
        {
            firstPart = NSLocalizedString(@"%d inconsistencies have been detected.", nil);;            
        }
        else
        {
            firstPart = NSLocalizedString(@"%d inconsistency has been detected.", nil);;
        }        
        
        NSString *secondPart = NSLocalizedString(@"Double-click the yellow icon in the file status column to get more information.", nil);
        info = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:firstPart, warnings], secondPart];
    }
    
    if (warnings == 0 && !mDisplayAlertIfSuccess)
    {
        // reset the flag
        mDisplayAlertIfSuccess = YES;
        [mDelegate checkProjectCompleted];
        return;
    }
    
    // fd:2017-01-30: What the heck does this alert tell the user?!? And does he have any option?

    /*
    // Display a message only if there is no AppleScript command in progress
    if (![[ASManager shared] isCommandInProgress])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setMessageText:NSLocalizedStringFromTable(@"ConsoleClearAllEntriesTitle",@"Alerts",nil)];
        [alert setInformativeText:@""];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOK",@"Alerts",nil)];      // 1st button
        
        // show alert
        [alert runModal];
    }
    */
    
    [mDelegate checkProjectCompleted];
}

@end
