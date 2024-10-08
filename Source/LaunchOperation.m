//
//  LaunchOperation.m
//  iLocalize3
//
//  Created by Jean on 21.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LaunchOperation.h"

#import "OperationWC.h"
#import "Console.h"

#import "LanguageController.h"
#import "ProjectModel.h"

#import "FileTool.h"
#import "AppTool.h"

@implementation LaunchOperation

- (BOOL)assertLaunch
{
    if (![[[self projectProvider] sourceApplicationPath] isPathExisting])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setMessageText:NSLocalizedStringFromTable(@"LaunchOperationCannotTitle",@"Alerts",nil)];
        [alert setInformativeText:NSLocalizedStringFromTable(@"LaunchOperationCannotDescr",@"Alerts",nil)];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOK",@"Alerts",nil)];  // 1st button
        
        // show alert
        [alert runModal];
        
        return NO;
    }
    else
    {
        return YES;        
    }
}

- (void)launch
{
    if (![self assertLaunch])
        return;
    
    NSString *path = [[[self projectProvider] projectModel] projectSourceFilePath];
    
    if ([path isPathApplication])
    {
        [AppTool launchApplication:[[self projectProvider] sourceApplicationPath] 
                          language:[[self selectedLanguageController] language]
                      bringToFront:YES];
    }
    else
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setMessageText:NSLocalizedStringFromTable(@"LaunchOperationBundleTitle",@"Alerts",nil)];
        [alert setInformativeText:NSLocalizedStringFromTable(@"LaunchOperationBundleDescr",@"Alerts",nil)];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOK",@"Alerts",nil)];  // 1st button
        
        // show alert
        [alert runModal];
    }

    [self close];
}

@end
