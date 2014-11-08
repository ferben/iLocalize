//
//  PreferencesLocalization.m
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesLocalization.h"
#import "PreferencesWC.h"
#import "Preferences.h"

#import "StringTool.h"

@implementation PreferencesLocalization

static id _shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(_shared == nil)
            _shared = [[self alloc] init];        
    }
    return _shared;
}

- (id)init
{
	if((self = [super init])) {
		[NSBundle loadNibNamed:@"PreferencesLocalization" owner:self];
	}
	return self;
}

- (IBAction)ignoreControlCharactersChanged:(id)sender
{
	[StringTool setIgnoreControlCharacters:[self ignoreControlCharacters]];
}

- (IBAction)help:(id)sender 
{
    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"mode" inBook:locBookName];
//    [[NSHelpManager sharedHelpManager] findString:@"Preferences"  inBook:locBookName];
    // Need Carbon for that but not compatible with 64 bits.
//    AHGotoPage((CFStringRef)locBookName, (CFStringRef)@"topics/preferences.html", nil);
}

- (IBAction)resetDialogWarnings:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAlwaysOverwriteGlossaryPrefs];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAlwaysViewGlossaryPrefs];
}

#pragma mark -

- (BOOL)ignoreCase
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"translateIgnoreCase"];
}

- (BOOL)ignoreControlCharacters
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"translateIgnoreControlCharacters"];
}

- (void)togglePropagation
{
	int next;
	if([self autoPropagateTranslationNone]) {
		next = AUTO_PROPAGATE_TRANSLATION_SELECTED;
	} else if([self autoPropagateTranslationSelectedFiles]) {
		next = AUTO_PROPAGATE_TRANSLATION_ALL;		
	} else {
		next = AUTO_PROPAGATE_TRANSLATION_NONE;
	}
	[[NSUserDefaults standardUserDefaults] setInteger:next forKey:@"autoPropagateTranslationMode"];
}

- (NSInteger)propagationMode
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoPropagateTranslationMode"];
}

- (BOOL)autoPropagateTranslationNone
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoPropagateTranslationMode"] == AUTO_PROPAGATE_TRANSLATION_NONE;	
}

- (BOOL)autoPropagateTranslationSelectedFiles
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoPropagateTranslationMode"] == AUTO_PROPAGATE_TRANSLATION_SELECTED;	
}

- (BOOL)autoPropagateTranslationAllFiles
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoPropagateTranslationMode"] == AUTO_PROPAGATE_TRANSLATION_ALL;	
}

@end
