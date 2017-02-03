//
//  ProjectMenuGlossary.m
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenuGlossary.h"

#import "GlossaryNewWC.h"
#import "GlossaryScope.h"
#import "GlossaryScopeWC.h"
#import "Glossary.h"
#import "GlossaryEntry.h"
#import "ProjectDocument.h"
#import "ProjectController.h"
#import "StringController.h"
#import "ProjectWC.h"
#import "LanguageController.h"
#import "LanguageModel.h"

#import "NewGlossaryOperationDriver.h"

@implementation ProjectMenuGlossary

- (id)init
{
    if(self = [super init]) {
        mGlossaryNew = [[GlossaryNewWC alloc] init];
        glossaryScope = [[GlossaryScope alloc] init];
    }
    return self;
}


- (void)awake
{
    glossaryScope.projectProvider = [self projectDocument];
}

- (void)storeSelectedStates {
    // Store the selected state for the current language
    LanguageController *lc = [glossaryScope.projectProvider selectedLanguageController];
    lc.languageModel.updateOrAddInGlossariesSelectedStates = glossaryScope.selectedStates;
}

- (void)restoreSelectedStates {
    // Restore the selected state
    LanguageController *lc = [glossaryScope.projectProvider selectedLanguageController];
    glossaryScope.selectedStates = lc.languageModel.updateOrAddInGlossariesSelectedStates;
}

- (void)updateEntriesInGlossary
{
    [self storeSelectedStates];
    
    NSArray *scs = [[self projectWC] selectedStringControllers];
    for(Glossary *g in [glossaryScope selectedGlossaries]) {
        if(![g entriesLoaded]) {
            [g loadContent];
        }
        NSMutableArray *entries = [NSMutableArray array];
        for(StringController *sc in scs) {
            GlossaryEntry *entry = [[GlossaryEntry alloc] init];
            entry.source = [sc base];
            entry.translation = [sc translation];
            [entries addObject:entry];
        }
        [g updateEntries:entries];
        [g writeToFile:nil];
    }
}

- (void)showGlossaryScopeWithTitle:(NSString*)title continueSelector:(SEL)continueSelector
{
    [self restoreSelectedStates];
    
    self.scopeWC = [[GlossaryScopeWC alloc] init];
    [self.scopeWC setCancellable:YES];
    [self.scopeWC setTitle:title];
    [self.scopeWC setDidOKSelector:continueSelector target:self];
    [self.scopeWC setParentWindow:[[self projectWC] window]];
    [self.scopeWC setProjectProvider:[self projectDocument]];
    [self.scopeWC setScope:glossaryScope];
    [self.scopeWC showAsSheet];
}

#pragma mark Actions

- (IBAction)newGlossary:(id)sender
{
    [mGlossaryNew setProjectProvider:[self projectDocument]];
    [mGlossaryNew display];
}

- (IBAction)newGlossaryWithCurrentLanguage:(id)sender
{
    NSString *language = [[[self projectDocument] selectedLanguageController] language];
    [[NewGlossaryOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:@{@"languages": @[language]}];
}

- (IBAction)newGlossaryWithAllLanguages:(id)sender
{
    NSMutableArray *languages = [NSMutableArray array];
    for (LanguageController *lc in [[[self projectDocument] projectController] languageControllers]) {
        if (lc.isBaseLanguage) {
            continue;
        }
        [languages addObject:lc.language];
    }
    [[NewGlossaryOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:@{@"languages": languages}];
}

//- (IBAction)addToGlossary:(id)sender
//{
//    [self showGlossaryScopeWithTitle:NSLocalizedString(@"Choose the glossaries to which the selected strings will be added:", @"Add strings to glossary title")
//                    continueSelector:@selector(addEntriesToGlossary)];
//}

- (IBAction)updateInGlossary:(id)sender
{
    [self showGlossaryScopeWithTitle:NSLocalizedString(@"Choose the glossaries in which the selected strings will be updated:", @"Update strings in glossary title")
                    continueSelector:@selector(updateEntriesInGlossary)];    
}

//- (BOOL)validateMenuItem:(NSMenuItem*)anItem
//{
//    SEL action = [anItem action];
//    BOOL isBaseLanguage = [[self.projectWC selectedLanguageController] isBaseLanguage];
//
//    if (action == @selector(newGlossaryWithCurrentLanguage:)) {
//        return !isBaseLanguage;
//    }
//        
//    return YES;
//}

@end
