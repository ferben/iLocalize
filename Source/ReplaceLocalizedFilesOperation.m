//
//  ReplaceLocalizedFilesOperation.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ReplaceLocalizedFilesOperation.h"
#import "OperationWC.h"
#import "PreferencesGeneral.h"

@implementation ReplaceLocalizedFilesOperation

- (void)awake
{
    mFileControllers = NULL;
}


- (void)replaceLocalizedFileControllersFromCorrespondingBase:(NSArray *)controllers
{
    mFileControllers = [controllers copy];
    
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setMessageText:NSLocalizedStringFromTable(@"ReplaceLocalizedFilesTitle",@"Alerts",nil)];
    [alert setInformativeText:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"ReplaceLocalizedFilesDescr",@"Alerts",nil), NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)]];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextRebuild",@"Alerts",nil)];     // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 2nd button

    [alert setShowsSuppressionButton:YES];
    [[alert suppressionButton] setTitle:NSLocalizedStringFromTable(@"AlertKeepNIBLayout",@"Alerts",nil)];

    // show alert
    [alert beginSheetModalForWindow:[self projectWindow] completionHandler:^(NSModalResponse alertReturnCode)
    {
        BOOL keepLayout = [[alert suppressionButton] state] == NSControlStateValueOn;
        
        [[alert window] orderOut:self];
        
        if (alertReturnCode == NSAlertSecondButtonReturn)
            return;

        [self performSelector:@selector(performReplace:) withObject:@(keepLayout) afterDelay:0];
    }];
}

- (void)performReplace:(BOOL)keepLayout
{
    if ([mFileControllers count] > 1)
    {
        [[self operation] setTitle:NSLocalizedString(@"Rebuilding localized files…", nil)];
        [[self operation] setCancellable:NO];
        [[self operation] setIndeterminate:NO];
        [[self operation] showAsSheet];        
    }
    
    [[self operationDispatcher] replaceLocalizedFileControllersWithCorrespondingBase:mFileControllers
                                                                          keepLayout:keepLayout
                                                                          completion:^(id results)
    {
        [[self operation] hide];
        [self close];
        
        if ([[PreferencesGeneral shared] autoUpdateSmartFilters])
            [self refreshListOfFiles];
    }];
}

@end
