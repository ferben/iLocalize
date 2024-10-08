//
//  ImportAppWC.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportBundleOVC.h"
#import "ImportAppItem.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "ProjectModel.h"
#import "LanguageTool.h"
#import "BundleSelectorDialog.h"

#import "Preferences.h"
#import "PreferencesAdvanced.h"
#import "PreferencesLocalization.h"
#import "ProjectPrefs.h"

@implementation ImportBundleOVC

- (id)init
{
    if((self = [super initWithNibName:@"ImportBundle"])) {
        applySettingsWithSelectLanguage = NO;
        mLanguagesSelectionView = [[AZListSelectionView alloc] init];
    }
    return self;
}


- (BOOL)importBaseLanguage
{
    return [mImportBaseButton state] == NSControlStateValueOn;    
}

- (BOOL)keepLayout
{
    return [mImportCheckLayoutCheckbox state] == NSControlStateValueOff;
}

- (BOOL)importOtherLanguages
{
    return [mImportLocalizedButton state] == NSControlStateValueOn;    
}

- (NSArray*)languages
{
    NSMutableArray *array = [NSMutableArray array];    
    for(ImportAppItem *item in [mLanguagesSelectionView selectedElements]) {
        if([item import]) {
            [array addObject:[item language]];                    
        }
    }
    return array;
}

- (NSString*)baseBundle
{
    return [[mBaseBundlePathControl URL] path];
}

- (NSString*)localizedBundle
{
    return [[mLocalizedBundlePathControl URL] path];
}

- (BOOL)layouts
{
    return [mImportImportLayoutsCheckbox state] == NSControlStateValueOn;
}

- (BOOL)copyOnlyIfExists
{
    return [mCopyOnlyIfExistsCheckbox state] != NSControlStateValueOn;
}

- (BOOL)canContinue
{
    return ([self importBaseLanguage] && [[self baseBundle] isPathExisting]) || ([self importOtherLanguages] && [[self localizedBundle] isPathExisting]);
}

- (void)updateInterface
{
    BOOL visible = (![self keepLayout] && [self importBaseLanguage]) || ([self layouts] && [self importOtherLanguages]);
    [mNibWarningIcon setHidden:!visible];
    [mNibWarningText setHidden:!visible];
        
//    [mBaseBundlePathControl setTextColor:[[self baseBundle] isPathExisting]?[NSColor blackColor]:[NSColor redColor]];
//    [mLocalizedBundlePathControl setTextColor:[[self localizedBundle] isPathExisting]?[NSColor blackColor]:[NSColor redColor]];
    [mLanguagesOutlineView setEnabled:[self importOtherLanguages]];
    
    [self stateChanged];
}

- (IBAction)keepExistingNibLayouts:(id)sender
{
    [self updateInterface];    
}

- (IBAction)importNibLayouts:(id)sender
{
    [self updateInterface];
}

- (BOOL)containsLanguageEquivalent:(NSString*)language array:(NSArray*)languages
{
    NSString *l;
    for(l in languages) {
        if([l isEquivalentToLanguage:language]) return YES;
    }
    return NO;
}

- (void)updateLocalizeLanguageAvailable
{
    NSMutableArray *languageItems = [NSMutableArray array];
    NSArray *languages = [LanguageTool languagesInPath:[self localizedBundle]];
    ProjectController *pc = [[self projectProvider] projectController];
    for(LanguageController *lc in [pc languageControllers]) {
        if([lc isBaseLanguage]) continue;
        
        NSString *language = [lc language];
        if(![self containsLanguageEquivalent:language array:languages]) continue;
        
        ImportAppItem *o = [ImportAppItem itemWithLanguage:language];
        [o setImport:[[[[self projectProvider] selectedLanguageController] language] isEquivalentToLanguage:language]];
        [languageItems addObject:o];
    }        
    
    mLanguagesSelectionView.elements = languageItems;
    mLanguagesSelectionView.outlineView = mLanguagesOutlineView;
    [mLanguagesSelectionView reloadData];
}

- (void)selectImportBaseButton:(int)state
{
    [mUIController willChangeValueForKey:@"updateBaseLanguage"];
    [mUIController content][@"updateBaseLanguage"] = @(state);
    [mUIController didChangeValueForKey:@"updateBaseLanguage"];    
}

- (void)selectImportLocalizedButton:(int)state
{
    [mUIController willChangeValueForKey:@"updateLocalizedLanguage"];
    [mUIController content][@"updateLocalizedLanguage"] = @(state);
    [mUIController didChangeValueForKey:@"updateLocalizedLanguage"];    
}

#define KEY_BASE_BUNDLE_PATH @"baseBundlePath"
#define KEY_LOCALIZED_BUNDLE_PATH @"localizedBundlePath"

- (BOOL)loadPrefs
{
    NSDictionary *dic = [[[self projectProvider] projectPrefs] updateBundlePrefs];
    if(dic) {
        // Migrate string to URL
        NSMutableDictionary *md = [dic mutableCopy];
        id path = md[KEY_BASE_BUNDLE_PATH];
        if([path isKindOfClass:[NSString class]]) {
            md[KEY_BASE_BUNDLE_PATH] = [NSURL fileURLWithPath:path];
        }
        
        path = md[KEY_LOCALIZED_BUNDLE_PATH];
        if([path isKindOfClass:[NSString class]]) {
            md[KEY_LOCALIZED_BUNDLE_PATH] = [NSURL fileURLWithPath:path];
        }
        // Set dictionary
        [mUIController setContent:md];
    }
    return dic != nil;
}

- (void)savePrefs
{
    [[[self projectProvider] projectPrefs] setUpdateBundlePrefs:[mUIController content]];    
}

- (void)setDefaultBundle:(NSString*)bundle
{
    if(bundle) {
        // Set the default bundle
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSDictionary *prefs = [[[self projectProvider] projectPrefs] updateBundlePrefs];
        if(prefs) {
            [dic setDictionary:prefs];
        }
        dic[KEY_BASE_BUNDLE_PATH] = [NSURL fileURLWithPath:bundle];
        dic[KEY_LOCALIZED_BUNDLE_PATH] = [NSURL fileURLWithPath:bundle];
        [[[self projectProvider] projectPrefs] setUpdateBundlePrefs:dic];
        
        // Also apply the settings considering the current language
        applySettingsWithSelectLanguage = YES;
    }
}

- (void)baseBundlePathChanged:(id)sender
{
    [self updateInterface];
}

- (void)localizedBundlePathChanged:(id)sender
{
    [self updateLocalizeLanguageAvailable];
    [self updateInterface];
}

#pragma mark Overrides

- (void)willShow
{        
    [self loadPrefs];
    
    // change here
    
    if([[Preferences shared] developerMode]) {
        if([[[self projectProvider] selectedLanguageController] isBaseLanguage]) {
            [self selectImportBaseButton:NSControlStateValueOn];            
            [self selectImportLocalizedButton:NSControlStateValueOff];
        } else {
            [self selectImportLocalizedButton:NSControlStateValueOn];
            [self selectImportBaseButton:NSControlStateValueOff];            
        }                
    } else {
        [self selectImportBaseButton:NSControlStateValueOn];            
        [self selectImportLocalizedButton:NSControlStateValueOff];        
    }
    
    NSString *bundlePathArg = (self.arguments)[@"importBundlePath"];
    if(bundlePathArg) {
        if([self importBaseLanguage]) {
            [mBaseBundlePathControl setURL:[NSURL fileURLWithPath:bundlePathArg]];
        } else {
            [mLocalizedBundlePathControl setURL:[NSURL fileURLWithPath:bundlePathArg]];
        }
    }
    
    [mBaseBundlePathControl setTarget:self];
    [mBaseBundlePathControl setAction:@selector(baseBundlePathChanged:)];
    [mLocalizedBundlePathControl setTarget:self];
    [mLocalizedBundlePathControl setAction:@selector(localizedBundlePathChanged:)];
    
    [self updateLocalizeLanguageAvailable];
    [self updateInterface];    
}

- (void)willCancel
{
    [self savePrefs];
}

- (void)willContinue
{
    [self savePrefs];
}

#pragma mark Actions

- (IBAction)importBaseBundle:(id)sender
{
    [self updateInterface];
}

- (IBAction)importLocalizedBundle:(id)sender
{
    if([self importOtherLanguages] && [[mLanguagesSelectionView elements] count] == 1) {        
        [[mLanguagesSelectionView elements][0] setImport:YES];
        [mLanguagesSelectionView reloadData];
    }
    
    [self updateInterface];
}

- (void)chooseBundleAndStoreInKey:(NSString*)key
{
    BundleSelectorDialog *dialog = [[BundleSelectorDialog alloc] init];
    dialog.defaultPath = [[mUIController content][key] path];
    [dialog promptForBundleForWindow:[self window] callback:^(NSString *path) {
        if(path) {
            [mUIController willChangeValueForKey:key];
            [mUIController content][key] = [NSURL fileURLWithPath:path];
            [mUIController didChangeValueForKey:key];            
        }        
        [self updateLocalizeLanguageAvailable];
        [self updateInterface];
    }];
}

- (IBAction)chooseBaseBundle:(id)sender
{
    [self chooseBundleAndStoreInKey:KEY_BASE_BUNDLE_PATH];
}

- (IBAction)chooseLocalizedBundle:(id)sender
{
    [self chooseBundleAndStoreInKey:KEY_LOCALIZED_BUNDLE_PATH];    
}

- (IBAction)help:(id)sender
{
    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"updatefrombundle"  inBook:locBookName];
}

@end
