//
//  PreferencesWC.m
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesWC.h"

#import "PreferencesGeneral.h"
#import "PreferencesLanguages.h"
#import "PreferencesLocalization.h"
#import "PreferencesInspectors.h"
#import "PreferencesFilters.h"
#import "PreferencesAdvanced.h"
#import "PreferencesEditors.h"
#import "Preferences.h"

#import "GlossaryManager.h"
#import "GlossaryManager.h"
#import "Toolbar.h"
#import "Constants.h"

static NSString*     PrefsToolbarIdentifier = @"PrefsToolbarIdentifier";

//#define TB_IDENT_GENERAL    @"General"
#define TB_IDENT_LANGUAGES    @"Languages"
#define TB_IDENT_LOCALIZATION    @"Localization"
#define TB_IDENT_GLOSSARY    @"Glossary"
#define TB_IDENT_ADVANCED    @"Advanced"
#define TB_IDENT_FILTERS    @"Filters"
#define TB_IDENT_EDITORS    @"Editors"
#define TB_IDENT_INSPECTOR    @"Inspector"

@implementation PreferencesWC

static PreferencesWC* prefs = nil;

+ (PreferencesWC*)shared
{
    @synchronized(self) {
        if(prefs == nil)
            prefs = [[PreferencesWC alloc] init];        
    }
    return prefs;
}

+ (void)initialize
{
    [Preferences initialize];
}

- (id)init
{
    if(self = [super initWithWindowNibName:@"Preferences"]) {
        mObservers = [[NSMutableArray alloc] init];
        mToolbar = [[Toolbar alloc] init];

        [PreferencesGeneral shared];
        [PreferencesLanguages shared];
        [PreferencesLocalization shared];
        [PreferencesInspectors shared];
        [PreferencesFilters shared];
        [PreferencesAdvanced shared];
        [PreferencesEditors shared];
        
        // Call [self window] only after all initialization because awakeFromNib is called ;-)
        
        [[PreferencesGeneral shared] setWindow:[self window]];
        [[PreferencesLanguages shared] setWindow:[self window]];
        [[PreferencesLocalization shared] setWindow:[self window]];
        [[PreferencesInspectors shared] setWindow:[self window]];
        [[PreferencesFilters shared] setWindow:[self window]];
        [[PreferencesAdvanced shared] setWindow:[self window]];
        [[PreferencesEditors shared] setWindow:[self window]];
    }
    return self;
}


#define AUTO_SAVE_NAME @"Preferences"

- (void)awakeFromNib
{        
    [mToolbar setWindow:[self window]];

//    [mToolbar addIdentifier:TB_IDENT_GENERAL];
//    [mToolbar addView:[[PreferencesGeneral shared] prefsView] image:[NSImage imageNamed:@"ToolbarGeneral"] identifier:TB_IDENT_GENERAL name:NSLocalizedString(@"General", @"Preferences General")];

    [mToolbar addIdentifier:TB_IDENT_LOCALIZATION];
//    [mToolbar addView:[[PreferencesLocalization shared] prefsView] image:[NSImage imageNamed:@"ToolbarLocalization"] identifier:TB_IDENT_LOCALIZATION name:NSLocalizedString(@"Localization", @"Preferences Localization")];
    [mToolbar addView:[[PreferencesLocalization shared] prefsView] image:[NSImage imageNamed:NSImageNamePreferencesGeneral] identifier:TB_IDENT_LOCALIZATION name:NSLocalizedString(@"General", @"Preferences General")];

    [mToolbar addIdentifier:TB_IDENT_FILTERS];
    [mToolbar addView:[[PreferencesFilters shared] prefsView] image:[NSImage imageNamed:NSImageNameFolderSmart] identifier:TB_IDENT_FILTERS name:NSLocalizedString(@"Filters", @"Preferences Filters")];

    [mToolbar addIdentifier:TB_IDENT_LANGUAGES];
    [mToolbar addView:[[PreferencesLanguages shared] prefsView] image:[NSImage imageNamed:@"_settings_language"] identifier:TB_IDENT_LANGUAGES name:NSLocalizedString(@"Languages", @"Preferences Languages")];

    [mToolbar addIdentifier:TB_IDENT_EDITORS];
    [mToolbar addView:[[PreferencesEditors shared] prefsView] image:[NSImage imageNamed:@"_settings_editor"] identifier:TB_IDENT_EDITORS name:NSLocalizedString(@"Editors", @"Preferences Editors")];
        
    [mToolbar addIdentifier:TB_IDENT_ADVANCED];
    [mToolbar addView:[[PreferencesAdvanced shared] prefsView] image:[NSImage imageNamed:NSImageNameAdvanced] identifier:TB_IDENT_ADVANCED name:NSLocalizedString(@"Advanced", @"Preferences Advanced")];

    [mToolbar setupToolbarWithIdentifier:PrefsToolbarIdentifier displayMode:NSToolbarDisplayModeIconAndLabel];    

    [mToolbar selectViewWithIdentifier:TB_IDENT_LOCALIZATION];    
}

- (NSString*)windowTopLeftPoint
{
    NSRect frame = [[self window] frame];
    return NSStringFromPoint(NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height));
}

- (void)show
{    
    [[self window] makeKeyAndOrderFront:self];
}

- (void)load
{
    NSString *topLeftPointAsString = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferencesTopLeftPoint"];
    if(topLeftPointAsString) {
        [[self window] setFrameTopLeftPoint:NSPointFromString(topLeftPointAsString)];        
    }

    [[GlossaryManager sharedInstance] setPersistentData:[[NSUserDefaults standardUserDefaults] objectForKey:@"GlossaryManagerPrefsKey"]];
    [[PreferencesEditors shared] loadData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PreferencesEditorsPrefsKey"]];
}

- (void)save
{
    // Save and reload manually the position of the window (Cocoa bug when the window is not resizable)
    [[NSUserDefaults standardUserDefaults] setObject:[self windowTopLeftPoint] forKey:@"PreferencesTopLeftPoint"];

    [[NSUserDefaults standardUserDefaults] setObject:[[GlossaryManager sharedInstance] persistentData] forKey:@"GlossaryManagerPrefsKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[[PreferencesEditors shared] data] forKey:@"PreferencesEditorsPrefsKey"];
    
    // Make sure it is saved on the disk
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -

- (void)changeFont:(id)sender
{
    [[PreferencesGeneral shared] changeFont:sender];
}

#pragma mark -

- (void)setProjectPresets:(NSArray*)array
{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"newProjectPresets"];
}

- (NSArray*)projectPresets
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"newProjectPresets"];
}

#pragma mark -

- (void)setLicenseBundleVersionAccepted:(NSString*)build
{
    [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"licenseBundleVersionAccepted"];
}

- (NSString*)licenseBundleVersionAccepted
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"licenseBundleVersionAccepted"];
}

#pragma mark -

- (void)addObserver:(id)observer selector:(SEL)selector forKey:(NSString*)key
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"observer"] = [NSValue valueWithNonretainedObject:observer];
    dic[@"selector"] = [NSValue value:&selector withObjCType:@encode(SEL)];
    dic[@"key"] = key;
    [mObservers addObject:dic];
}

- (void)removeObserver:(id)observer
{
    NSEnumerator *enumerator = [mObservers reverseObjectEnumerator];
    NSDictionary *dic;
    while((dic = [enumerator nextObject])) {
        if([dic[@"observer"] nonretainedObjectValue] == observer)
            [mObservers removeObject:dic];
    }
}

@end

