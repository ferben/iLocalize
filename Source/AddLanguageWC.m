//
//  AddLanguageWC.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AddLanguageWC.h"
#import "ProjectController.h"
#import "LanguageTool.h"

@implementation AddLanguageWC

@synthesize initialLanguageSelection;

- (id)init
{
    if (self = [super initWithWindowNibName:@"AddLanguage"])
    {
        languageMenuProvider = [[LanguageMenuProvider alloc] init];
        languageMenuProvider.actionTarget = self;
        languageMenuProvider.delegate = self;
        mCheckForExistingLanguage = YES;
    }
    
    return self;
}


- (BOOL)alreadyExistsLanguage:(NSString *)language
{
    return [[[self projectProvider] projectController] isLanguageExisting:language];
}

- (void)updateOKButton
{
    BOOL enabled = NO;
    
    if (mCheckForExistingLanguage)
    {
        NSString *language = [languageMenuProvider selectedLanguage];
        
        if (language)
        {
            enabled = ![self alreadyExistsLanguage:language];
        }
    }
    else
    {
        enabled = YES;
    }
    
    [mOKButton setEnabled:enabled];
}

- (void)willShow
{
    languageMenuProvider.popupButton = mLocalePopUpButton;
    [languageMenuProvider refreshPopUp];
    
    if (self.initialLanguageSelection != nil)
    {
        [languageMenuProvider selectLanguage:initialLanguageSelection];
    }
    else
    {
        [languageMenuProvider selectCurrentLanguage];
    }

    [mFillTranslationButton setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"autoFillTranslationWithBaseForNewLanguage"]?NSOnState:NSOffState];
    [self updateOKButton];
}

- (void)setCheckForExistingLanguage:(BOOL)flag
{
    mCheckForExistingLanguage = flag;
}

- (void)setRenameLanguage:(BOOL)flag
{
    [mFillTranslationButton setHidden:flag];
    
    if (flag)
    {
        [mOKButton setTitle:NSLocalizedString(@"Rename", @"Language")];        
    }
    else
    {
        [mOKButton setTitle:NSLocalizedString(@"Add", @"Language")];
    }
}

- (BOOL)enableMenuItemForLanguage:(NSString *)language
{
    if (!mCheckForExistingLanguage)
    {
        return YES;
    }
    
    if (!language)
    {
        return YES;
    }
    
    return ![self alreadyExistsLanguage:language];
}

- (NSString *)language
{
    return [languageMenuProvider selectedLanguage];
}

- (IBAction)languageSelected:(id)sender
{
    [self updateOKButton];
}

- (IBAction)cancel:(id)sender
{
    [self hide];    
}

- (IBAction)add:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[mFillTranslationButton state] == NSOnState forKey:@"autoFillTranslationWithBaseForNewLanguage"];

    if (mCheckForExistingLanguage && [self alreadyExistsLanguage:[self language]])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSWarningAlertStyle];
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
