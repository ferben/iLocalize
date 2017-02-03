//
//  LanguageMenuProvider.m
//  iLocalize
//
//  Created by Jean Bovet on 2/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "LanguageMenuProvider.h"
#import "LanguageInfoModel.h"
#import "LanguageTool.h"

@interface LanguageMenuProvider (PrivateMethods)
- (void)addLanguageInfo:(LanguageInfoModel*)info;
@end

@implementation LanguageMenuProvider

- (id)init
{
    if(self = [super init]) {
        mSelectedLanguages = [[NSMutableArray alloc] init];
        mDisplayLanguageToInfo = [[NSMutableDictionary alloc] init];
        mCommonLanguages = [[NSMutableArray alloc] init];
        mLanguages = [[NSMutableDictionary alloc] init];
        self.actionTarget = self;
        
        for(NSString *identifier in [LanguageTool defaultLanguageIdentifiers]) {
            [mCommonLanguages addObject:[LanguageInfoModel infoWithIdentifier:identifier]]; 
        }
        
        for(NSString *identifier in [NSLocale availableLocaleIdentifiers]) {
            [self addLanguageInfo:[LanguageInfoModel infoWithIdentifier:identifier]];
        }                
    }
    return self;
}


- (IBAction)languageSelected:(id)sender
{
    NSString *selectedLanguage = [sender title];
    [self selectLanguage:selectedLanguage];    
    if(self.actionTarget != self) {
        [self.actionTarget languageSelected:sender];        
    }
}

- (void)addLanguageInfo:(LanguageInfoModel*)info
{
    NSMutableSet *languageInfoSet = mLanguages[[info languageIdentifier]];
    if(!languageInfoSet) {
        languageInfoSet = [NSMutableSet set];
        mLanguages[[info languageIdentifier]] = languageInfoSet;
    }
    [languageInfoSet addObject:info];
}

- (void)addItemWithLanguage:(NSString*)language identifier:(NSString*)identifier toMenu:(NSMenu*)menu
{
    NSMenuItem *item = [menu addItemWithTitle:language action:@selector(languageSelected:) keyEquivalent:@""];
    [item setTarget:self];
    [item setRepresentedObject:identifier];
    [item setToolTip:identifier];
}

- (NSString*)languageIdentifierForDisplayName:(NSString*)displayName
{
    LanguageInfoModel *info = mDisplayLanguageToInfo[displayName];
    return info.identifier;    
}

- (void)populateMenu:(NSMenu*)menu withLanguages:(NSArray*)languages
{
    for(NSString *language in languages) {
        [self addItemWithLanguage:language identifier:[self languageIdentifierForDisplayName:language] toMenu:menu];
    }    
}

- (void)populateMenu:(NSMenu*)menu
{
    if([menu numberOfItems] > 0) {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    for(LanguageInfoModel *info in [mCommonLanguages sortedArrayUsingSelector:@selector(compareDisplayName:)]) {
        [self addItemWithLanguage:info.displayName identifier:info.identifier toMenu:menu];
        mDisplayLanguageToInfo[info.displayName] = info;
    }
    
    if([menu numberOfItems] > 0) {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    for(NSString *language in [[mLanguages allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {        
        NSSet *languageInfoSet = mLanguages[language];
        
        NSMenu *submenu = [[NSMenu alloc] initWithTitle:language];
        for(LanguageInfoModel *info in [[languageInfoSet allObjects] sortedArrayUsingSelector:@selector(compareDisplayName:)]) {
            [self addItemWithLanguage:info.displayName identifier:info.identifier toMenu:submenu];
            mDisplayLanguageToInfo[info.displayName] = info;
        }
        
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:language action:nil keyEquivalent:@""];
        [item setSubmenu:submenu];
        [menu addItem:item];
    }    
}

- (void)refreshPopUp
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Locale"];
    
    [self populateMenu:menu withLanguages:mSelectedLanguages];
    [self populateMenu:menu];
    
    [self.popupButton setMenu:menu];
}

- (void)selectLanguage:(NSString*)language
{
    if(![mSelectedLanguages containsObject:language] && ![mCommonLanguages containsObject:language]) {
        [mSelectedLanguages addObject:language];
    }    
    [self refreshPopUp];
    [self.popupButton selectItemWithTitle:language];
}

- (void)selectCurrentLanguage;
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLanguage = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
    if(currentLanguage) {
        [self selectLanguage:currentLanguage];
    }
}    

- (NSString*)selectedLanguage
{
    return [self languageIdentifierForDisplayName:[self.popupButton titleOfSelectedItem]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSString *identifier = [menuItem representedObject];
    if(self.delegate) {
        return [self.delegate enableMenuItemForLanguage:identifier];
    } else {
        return YES;
    }
}

@end
