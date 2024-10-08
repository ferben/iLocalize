//
//  RebuildBaseFilesOperation.m
//  iLocalize3
//
//  Created by Jean on 12/10/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "RebuildBaseFilesOperation.h"
#import "OperationWC.h"
#import "PreferencesGeneral.h"
#import "ProjectWC.h"
#import "ImportRebaseBundleOp.h"

@implementation RebuildBaseFilesOperation

- (void)awake
{
    mFileControllers = NULL;
}


- (void)rebuildBaseFileControllers:(NSArray *)controllers
{
    mFileControllers = controllers;
    
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setMessageText:NSLocalizedStringFromTable(@"RebuildBaseFilesTitle",@"Alerts",nil)];
    [alert setInformativeText:[NSString stringWithFormat:@"%@ %@", NSLocalizedStringFromTable(@"RebuildBaseFilesDescr",@"Alerts",nil), NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)]];
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
         
         [self performSelector:@selector(performRebuild:) withObject:@(keepLayout) afterDelay:0];
     }];
}


- (void)performRebuild:(NSNumber *)keepLayout
{
    if ([mFileControllers count] > 1)
    {
        [[self operation] setTitle:NSLocalizedString(@"Rebuilding files…", nil)];
        [[self operation] setCancellable:NO];
        [[self operation] setIndeterminate:NO];
        [[self operation] showAsSheet];        
    }
    
    [[self projectWC] fmEditorWillChange];
    
    [[self projectWC] disconnectInterface];
    
    ImportRebaseBundleOp *op = [ImportRebaseBundleOp operation];
    op.projectProvider = [self projectProvider];
    [op rebaseBaseFileControllers:mFileControllers keepLayout:[keepLayout boolValue]];    
    
    [[self projectWC] connectInterface];
    
    [[self operation] hide];
}

@end
