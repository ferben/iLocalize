//
//  PreferencesLanguages.h
//  iLocalize3
//
//  Created by Jean on 11/26/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@class StringEncoding;

@interface PreferencesLanguages : PreferencesObject {
	IBOutlet NSMenu *mLanguagesMenu;
	IBOutlet NSMenu *mEncodingsMenu;
	IBOutlet NSPopUpButton *mDefaultEncodingPopup;
	IBOutlet NSArrayController *mLanguagesController;	
	IBOutlet NSTableView *mLanguagesTableView;
	
	NSMutableDictionary *mLanguagesCache;
}

+ (id)shared;

- (IBAction)addLanguage:(id)sender;
- (IBAction)deleteLanguage:(id)sender;

- (void)updateLanguagesCache;

- (StringEncoding*)defaultEncodingForLanguage:(NSString*)language;

+ (void)setQuoteSubstitutionEnabled:(BOOL)flag;
+ (BOOL)quoteSubstitutionEnabled;

+ (NSString*)openDoubleQuoteSubstitutionForLanguage:(NSString*)language;
+ (NSString*)closeDoubleQuoteSubstitutionForLanguage:(NSString*)language;
+ (NSString*)openSingleQuoteSubstitutionForLanguage:(NSString*)language;
+ (NSString*)closeSingleQuoteSubstitutionForLanguage:(NSString*)language;

@end
