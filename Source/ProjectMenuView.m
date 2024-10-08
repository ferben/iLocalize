//
//  ProjectMenuView.m
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenuView.h"
#import "ProjectWC.h"
#import "ProjectPrefs.h"
#import "ProjectDetailsController.h"
#import "LanguageController.h"

@implementation ProjectMenuView

- (id)init
{
    if(self = [super init]) {

    }
    return self;
}

- (ProjectPrefs*)preferences
{
    return [[self projectWC] projectPreferences];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
        
    ProjectDetailsController *c = [self projectDetails];

    if(action == @selector(showInfoProject:)) {
        if([c isDetailsVisibleAtIndex:4]) {
            [anItem setTitle:NSLocalizedString(@"Hide Project Information", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Project Information", nil)];
        }
        return YES;
    }
    if(action == @selector(showInfoFile:)) {
        if([c isDetailsVisibleAtIndex:3]) {
            [anItem setTitle:NSLocalizedString(@"Hide File Information", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show File Information", nil)];
        }
        return YES;
    }
    if(action == @selector(showInfoString:)) {
        if([c isDetailsVisibleAtIndex:2]) {
            [anItem setTitle:NSLocalizedString(@"Hide String Information", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show String Information", nil)];
        }
        return YES;
    }
    if(action == @selector(showInfoGlossary:)) {
        if([c isDetailsVisibleAtIndex:0]) {
            [anItem setTitle:NSLocalizedString(@"Hide Glossary Translations", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Glossary Translations", nil)];
        }
        return YES;
    }
    if(action == @selector(showInfoAlternate:)) {
        if([c isDetailsVisibleAtIndex:1]) {
            [anItem setTitle:NSLocalizedString(@"Hide Alternate Translations", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Alternate Translations", nil)];
        }
        return YES;
    }

    if(action == @selector(toggleTextZone:)) {
        if([self preferences].showTextZone) {
            [anItem setTitle:NSLocalizedString(@"Hide Text Zone", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Text Zone", nil)];
        }
        return YES;
    }

    if(action == @selector(toggleKeyColumn:)) {
        if([self preferences].showKeyColumn) {
            [anItem setTitle:NSLocalizedString(@"Hide Key Column", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Key Column", nil)];
        }
        return YES;
    }
    
    if(action == @selector(showFilesCommonToAllLanguages:)) {
        if([[self preferences] showLocalFiles]) {
            [anItem setState:NSControlStateValueOff];
        } else {
            [anItem setState:NSControlStateValueOn];
        }
        return YES;
    }

    if(action == @selector(showFilesSpecificToCurrentLanguage:)) {
        NSString *language = [[[self projectWC] selectedLanguageController] displayLanguage];
        [anItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Show Files Specific To “%@”", nil), language]];
        if([[self preferences] showLocalFiles]) {
            [anItem setState:NSControlStateValueOn];
        } else {
            [anItem setState:NSControlStateValueOff];
        }
        return YES;
    }
    
    if(action == @selector(showInvisibleCharacters:)) {
        if([[self preferences] showInvisibleCharacters]) {
            [anItem setTitle:NSLocalizedString(@"Hide Invisible Characters", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Invisible Characters", nil)];
        }
        return YES;
    }

    if(action == @selector(toggleStatusBar:)) {
        if([[self projectWC] isStatusBarVisible]) {
            [anItem setTitle:NSLocalizedString(@"Hide Status Bar", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Status Bar", nil)];
        }
        return YES;
    }

    if(action == @selector(toggleStructureView:)) {
        if([[self projectWC] isStructureViewVisible]) {
            [anItem setTitle:NSLocalizedString(@"Hide Structure View", nil)];
        } else {
            [anItem setTitle:NSLocalizedString(@"Show Structure View", nil)];
        }
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (void)toggleDetailsAtIndex:(int)index
{
    ProjectDetailsController *c = [self projectDetails];
    if([c isDetailsVisibleAtIndex:index]) {
        [c hideDetailsAtIndex:index];
    } else {
        [c showDetailsAtIndex:index];
    }
}

- (IBAction)showInfoProject:(id)sender
{
    [self toggleDetailsAtIndex:4];
}

- (IBAction)showInfoFile:(id)sender
{
    [self toggleDetailsAtIndex:3];
}

- (IBAction)showInfoString:(id)sender
{
    [self toggleDetailsAtIndex:2];
}

- (IBAction)showInfoGlossary:(id)sender
{
    [self toggleDetailsAtIndex:0];
}

- (IBAction)showInfoAlternate:(id)sender
{
    [self toggleDetailsAtIndex:1];    
}

- (IBAction)toggleTextZone:(id)sender
{
    ProjectPrefs *prefs = [self preferences];
    prefs.showTextZone = !prefs.showTextZone;
}

- (IBAction)toggleKeyColumn:(id)sender
{
    ProjectPrefs *prefs = [self preferences];
    prefs.showKeyColumn = !prefs.showKeyColumn;
}

- (IBAction)showFilesCommonToAllLanguages:(id)sender
{
    ProjectPrefs *prefs = [self preferences];
    prefs.showLocalFiles = NO;
}

- (IBAction)showFilesSpecificToCurrentLanguage:(id)sender
{
    ProjectPrefs *prefs = [self preferences];
    prefs.showLocalFiles = YES;
}

- (IBAction)showInvisibleCharacters:(id)sender
{
    ProjectPrefs *prefs = [self preferences];
    prefs.showInvisibleCharacters = !prefs.showInvisibleCharacters;
}

- (IBAction)toggleStatusBar:(id)sender
{
    [[self projectWC] toggleStatusBar];
}

- (IBAction)toggleStructureView:(id)sender
{
    [[self projectWC] toggleStructureView];
}

@end
