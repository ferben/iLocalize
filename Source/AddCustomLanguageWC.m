//
//  AddCustomLanguageWC.m
//  iLocalize3
//
//  Created by Jean on 7/29/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "AddCustomLanguageWC.h"
#import "ProjectController.h"

@implementation AddCustomLanguageWC

- (id)init
{
    if (self = [super initWithWindowNibName:@"AddCustomLanguage"])
    {
    }
    
    return self;
}

- (void)willShow
{
    [mNameField setStringValue:@""];
}

- (void)setRenameLanguage:(BOOL)flag
{
    if (flag)
    {
        [mOKButton setTitle:NSLocalizedStringFromTable(@"AlertButtonTextRename", @"Alerts", nil)];
    }
    else
    {
        [mOKButton setTitle:NSLocalizedStringFromTable(@"AlertButtonTextAdd", @"Alerts", nil)];
    }
}

- (NSString *)language
{
    return [mNameField stringValue];
}

- (BOOL)alreadyExists
{
    return [[[self projectProvider] projectController] isLanguageExisting:[self language]];
}

- (IBAction)cancel:(id)sender
{
    [self hide];    
}

- (IBAction)add:(id)sender
{
    if ([self alreadyExists])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setMessageText:NSLocalizedStringFromTable(@"AddCustomLanguageCannotAddTitle",@"Alerts",nil)];
        [alert setInformativeText:NSLocalizedStringFromTable(@"AddCustomLanguageCannotAddDescr",@"Alerts",nil)];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOK",@"Alerts",nil)];
        
        // show alert
        [alert runModal];
    }
    else
    {
        [self hideWithCode:1];    
    }
}

@end
