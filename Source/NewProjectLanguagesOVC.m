//
//  NewProjectLanguagesOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "NewProjectLanguagesOVC.h"
#import "LanguageTool.h"
#import "NewProjectSettings.h"
#import "NewLanguageItem.h"
#import "BundleSource.h"

@interface NewProjectLanguagesOVC (PrivateMethods)
- (void)buildLanguageItems;
- (void)buildLocalizedLanguageItems;
- (void)checkForCreationAndReturn;
- (NSString*)baseLanguage;
- (NSArray*)localizedLanguages;
@end

@implementation NewProjectLanguagesOVC

@synthesize settings;
@synthesize validateContinueCallback;

- (id)init
{
    if((self = [super initWithNibName:@"NewProjectLanguages"])) {
        selectionView = [[AZListSelectionView alloc] init];
        selectionView.delegate = self;
        languageItems = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSString*)nextButtonTitle
{
    return NSLocalizedString(@"Create", nil);
}

- (void)willShow
{
    selectionView.outlineView = outlineView;
    [self buildLanguageItems];    
    [self buildLocalizedLanguageItems];
}

- (void)validateContinue:(ValidateContinueCallback)callback
{
    self.validateContinueCallback = callback;
    [self checkForCreationAndReturn];
}

- (void)willContinue
{
    settings.copySourceOnlyIfExists = [mCopySourceOnlyIfExists state] != NSControlStateValueOn;    
    self.settings.baseLanguage = [self baseLanguage];
    self.settings.localizedLanguages = [self localizedLanguages];
}

- (NSString*)baseLanguage
{
    for(NewLanguageItem *item in languageItems) {
        if([item isBaseLanguage])
            return [item language];
    }
    return NULL;
}

- (NSArray*)localizedLanguages
{
    NSMutableArray *array = [NSMutableArray array];
    for(NewLanguageItem *item in languageItems) {
        if(![item isBaseLanguage] && [item import]) {
            [array addObject:[item language]];
        }
    }
    return array;    
}

- (void)checkForCreationAndReturn
{
    NSString *path = [self.settings projectFolderPath];
    if([path isPathExisting]) {
        NSBeginAlertSheet(NSLocalizedString(@"The project folder already exists", nil), 
                          NSLocalizedString(@"Move to Trash", NULL),
                          NSLocalizedString(@"Cancel", NULL), NULL, [self window], self, nil,
                          @selector(moveProjectToTrashSheetDidDismiss:returnCode:contextInfo:),
                          nil, NSLocalizedString(@"The project folder “%@” already exists. Do you want to move it to the trash and create a new one?", nil),
                                [self.settings projectFolderPath]);        
    } else {
        self.validateContinueCallback(YES);
    }
}

- (void)moveProjectToTrashSheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if(returnCode == NSAlertDefaultReturn) {
        self.validateContinueCallback([[self.settings projectFolderPath] movePathToTrash]);
    } else {
        self.validateContinueCallback(NO);        
    }
}

- (void)buildLanguageItems
{
    // Obtention de toutes les langues disponibles
    NSMutableArray *languages = [NSMutableArray array];
    
    for (NSString *file in [self.settings.source relativeSourceFiles])
    {
        NSString *language = [[LanguageTool languageOfFile:file] isoLanguage];
        
        if (language.length > 0 && ![languages containsObject:language])
        {
            [languages addObject:language];
        }
    }
        
//    // Obtention des languages "legacy" ayant un double en norme ISO
//    NSMutableArray *nonNormalizedLegacyLanguageNames = [NSMutableArray array];
//    for(NSString *path in [self.settings.source sourcePaths]) {
//        [nonNormalizedLegacyLanguageNames addObjectsFromArray:[LanguageTool nonNormalizedLanguagesInPath:self.settings.source.sourcePath]];    
//    }    
//    
//    // Filtre la liste des langues en eliminant les noms "legacy" car plus tard
//    // le moteur NewProjectEngine eliminera les "legacy" names (en les copiant en ISO)
//    NSArray *filteredLanguages = [languages arrayOfObjectsNotInArray:nonNormalizedLegacyLanguageNames];
//    [languages removeAllObjects];
//    [languages addObjectsFromArray:filteredLanguages];

    // Build the list of language items.
    [languageItems removeAllObjects];
    
    BOOL usingBaseI18n = FALSE;

    for (NSString *language in languages)
    {
        NewLanguageItem *item = [NewLanguageItem itemWithLanguage:language];
        
        if ([language isEqualCaseInsensitiveToString:@"Base"])
        {
            [item setIsBaseLanguage:YES];
            usingBaseI18n = YES;
        }
        
        else if (    [language isEqualCaseInsensitiveToString:@"en"]
                  || [language isEqualCaseInsensitiveToString:@"English"]
                  || [languages count] == 1)
        {
            if (usingBaseI18n == NO)
                [item setIsBaseLanguage:YES];
        }        
        
        [item setDisplay:[language displayLanguageName]];
        
        // Ajoute le descripteur de langue
        [languageItems addObject:item];
    }
    
    // Sort the languages by display name
    NSSortDescriptor *languageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"display" ascending:YES];
    [languageItems sortUsingDescriptors:@[languageDescriptor]];
         
    // Build the base language popup
    [mBaseLanguagePopUp removeAllItems];
    
    [languageItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NewLanguageItem *item = obj;
        [mBaseLanguagePopUp addItemWithTitle:[item display]];
        
        if ([item isBaseLanguage])
        {
            [mBaseLanguagePopUp selectItemWithTitle:[item display]];
        }
    }];    
}

- (void)buildLocalizedLanguageItems
{
    NSArray *localized = [languageItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isBaseLanguage == NO"]];
    selectionView.elements = localized;
    [selectionView reloadData];
}

- (IBAction)baseLanguagePopUp:(id)sender
{
    NSString *baseLanguage = [mBaseLanguagePopUp titleOfSelectedItem];
    [languageItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NewLanguageItem *item = obj;
        if([[item display] isEqualToString:baseLanguage]) {
            [item setIsBaseLanguage:YES];
        } else {
            if([item isBaseLanguage]) {
                [item setImport:NO];
                [item setIsBaseLanguage:NO];
            }
        }
    }];
    [self buildLocalizedLanguageItems];
}

- (void)elementsSelectionChanged:(BOOL)noSelection
{
    // nothing to do, the selection is already capture inside the NewLanguageItem object.
}

@end
