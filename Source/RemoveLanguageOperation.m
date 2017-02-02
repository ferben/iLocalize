//
//  RemoveLanguageOperation.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "RemoveLanguageOperation.h"

#import "ProjectController.h"
#import "LanguageController.h"

#import "TableViewCustom.h"
#import "ProjectWC.h"

@implementation RemoveLanguageOperation

- (void)removeLanguage:(LanguageController*)language
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"RemoveLanguageTitle",@"Alerts",nil), [language language]]];
    [alert setInformativeText:NSLocalizedStringFromTable(@"RemoveLanguageDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextDelete",@"Alerts",nil)];      // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 2nd button
    
    // show alert
    [alert beginSheetModalForWindow:[self projectWindow] completionHandler:^(NSModalResponse alertReturnCode)
     {
         [[alert window] orderOut:self];
         
         if (alertReturnCode == NSAlertSecondButtonReturn)
             return;
         
         [[[self projectProvider] projectWC] selectLanguageAtIndex:0];
         
         // old stuff from -beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:
         // contextInfo:(__bridge_retained void*)@{@"language" : [language language], @"self" : self }];
         // NSDictionary *info = (__bridge_transfer NSDictionary *)(contextInfo);
         
         // In order for the selection to be changed before removing the language: otherwise, crash can occur
         // because the deleted language can be still updated after it has been removed (or is being removed)
         dispatch_async(dispatch_get_main_queue(), ^{
             [[self operationDispatcher] removeLanguage:[language language] completion:^(id results)
             {
                 [self close];
             }];
         });
     }];
}

@end
