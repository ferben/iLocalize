//
//  PreferencesLanguages.m
//  iLocalize3
//
//  Created by Jean on 11/26/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesLanguages.h"
#import "Preferences.h"
#import "LanguageInfoModel.h"
#import "LanguageTool.h"
#import "StringEncodingTool.h"
#import "LanguageIdToTagTransformer.h"
#import "Constants.h"
#import "StringEncoding.h"

#define KEY_LANGUAGE_ID @"identifier"
#define KEY_ENCODING @"encoding"

#define KEY_QUOTE_OPEN_DOUBLE @"quote_open_double"
#define KEY_QUOTE_CLOSE_DOUBLE @"quote_close_double"
#define KEY_QUOTE_OPEN_SINGLE @"quote_open_single"
#define KEY_QUOTE_CLOSE_SINGLE @"quote_close_single"

#define ENGLISH_OPEN_DOUBLE [NSString stringWithFormat:@"%C", (unichar)0x201C]
#define ENGLISH_CLOSE_DOUBLE [NSString stringWithFormat:@"%C", (unichar)0x201D]
#define ENGLISH_OPEN_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x2018]
#define ENGLISH_CLOSE_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x2019]

#define FRENCH_OPEN_DOUBLE [NSString stringWithFormat:@"%C%C", (unichar)0x00AB, (unichar)NOBREAK_SPACE]
#define FRENCH_CLOSE_DOUBLE [NSString stringWithFormat:@"%C%C", (unichar)NOBREAK_SPACE, (unichar)0x00BB]
#define FRENCH_OPEN_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x2018]
#define FRENCH_CLOSE_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x2019]

#define GERMAN_OPEN_DOUBLE [NSString stringWithFormat:@"%C", (unichar)0x201E]
#define GERMAN_CLOSE_DOUBLE [NSString stringWithFormat:@"%C", (unichar)0x201C]
#define GERMAN_OPEN_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x201A]
#define GERMAN_CLOSE_SINGLE [NSString stringWithFormat:@"%C", (unichar)0x2018]

@implementation PreferencesLanguages

static id _shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(_shared == nil)
            _shared = [[self alloc] init];        
    }
    return _shared;
}

+ (NSDictionary*)createLanguageWithIdentifier:(NSString*)identifier encoding:(StringEncoding*)encoding openDouble:(NSString*)od closeDouble:(NSString*)cd openSingle:(NSString*)os closeSingle:(NSString*)cs
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[KEY_LANGUAGE_ID] = identifier;
	dic[KEY_ENCODING] = @([encoding identifier]);
	dic[KEY_QUOTE_OPEN_DOUBLE] = od;
	dic[KEY_QUOTE_CLOSE_DOUBLE] = cd;
	dic[KEY_QUOTE_OPEN_SINGLE] = os;
	dic[KEY_QUOTE_CLOSE_SINGLE] = cs;
	return dic;
}

+ (NSMutableArray*)defaultLanguages
{
	NSMutableArray *languages = [NSMutableArray array];
	
	[languages addObject:[self createLanguageWithIdentifier:@"en" 
												   encoding:ENCODING_MACOS_ROMAN
												 openDouble:ENGLISH_OPEN_DOUBLE
												closeDouble:ENGLISH_CLOSE_DOUBLE
												 openSingle:ENGLISH_OPEN_SINGLE
												closeSingle:ENGLISH_CLOSE_SINGLE]];

	[languages addObject:[self createLanguageWithIdentifier:@"fr" 
												   encoding:ENCODING_UTF8
												 openDouble:FRENCH_OPEN_DOUBLE
												closeDouble:FRENCH_CLOSE_DOUBLE
												 openSingle:FRENCH_OPEN_SINGLE
												closeSingle:FRENCH_CLOSE_SINGLE]];

	[languages addObject:[self createLanguageWithIdentifier:@"de" 
												   encoding:ENCODING_UTF8
											 openDouble:GERMAN_OPEN_DOUBLE
												closeDouble:GERMAN_CLOSE_DOUBLE
												 openSingle:GERMAN_OPEN_SINGLE
												closeSingle:GERMAN_CLOSE_SINGLE]];
		
	return languages;
}

+ (void)initialize
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];    

    // mLanguagesController is bound to this defaults key
	dic[@"languagesSettings"] = [self defaultLanguages];	
    dic[DEFAULT_ENCODING] = @([ENCODING_UTF8 identifier]);
	dic[@"QuoteSubstitution"] = @NO;
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:dic];
	
	LanguageIdToTagTransformer *transformer = [[LanguageIdToTagTransformer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"languageIdToTag"];
}

- (id)init
{
	if (self = [super init])
    {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [bundle loadNibNamed:@"PreferencesLanguages" owner:self topLevelObjects:nil];
		
		mLanguagesCache = nil;
        
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"QuoteSubstitution" options:NSKeyValueObservingOptionNew context:nil];		
	}

    return self;
}

- (void)dealloc
{
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"QuoteSubstitution"];
}

- (void)awakeFromNib
{
	[[StringEncodingTool shared] fillAvailableEncodingsToMenu:[mDefaultEncodingPopup menu] target:nil action:nil];
	[[StringEncodingTool shared] fillAvailableEncodingsToMenu:mEncodingsMenu target:nil action:nil];
	[LanguageTool fillAvailableLanguageIdentifiersToMenu:mLanguagesMenu target:nil action:nil];
	
	[mDefaultEncodingPopup selectItemWithTag:[[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_ENCODING]];		
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"QuoteSubstitution"]) {
        [self updateLanguagesCache];
    }
}

#pragma mark -

- (IBAction)addLanguage:(id)sender
{
	[mLanguagesController addObject:[PreferencesLanguages createLanguageWithIdentifier:@"en" 
																			  encoding:ENCODING_UTF8
																  openDouble:ENGLISH_OPEN_DOUBLE
																 closeDouble:ENGLISH_CLOSE_DOUBLE
																  openSingle:ENGLISH_OPEN_SINGLE
																 closeSingle:ENGLISH_CLOSE_SINGLE]];
	
	int row = [[mLanguagesController content] count]-1;
	[mLanguagesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	[mLanguagesTableView editColumn:0 row:row withEvent:nil select:YES];
	
	[self updateLanguagesCache];
}

- (IBAction)deleteLanguage:(id)sender
{
	[mLanguagesController remove:self];
	[self updateLanguagesCache];
}

#pragma mark -

- (void)updateLanguagesCache
{
	// build a dictionary of "language_id" -> settings
	@synchronized(self) {
		if(mLanguagesCache == nil) {
			mLanguagesCache = [[NSMutableDictionary alloc] init];
		}
		[mLanguagesCache removeAllObjects];
		for(NSDictionary *dic in [mLanguagesController content]) {
			mLanguagesCache[dic[KEY_LANGUAGE_ID]] = dic;
		}		
	}	
	[[NSNotificationCenter defaultCenter] postNotificationName:ILQuoteSubstitutionDidChange
														object:nil];
}

- (NSDictionary*)settingsForLanguage:(NSString*)language
{
	if(!mLanguagesCache) {
		[self updateLanguagesCache];
	}
	NSDictionary *dic = mLanguagesCache[language];
	if(!dic) {
		dic = mLanguagesCache[[language isoLanguage]];
	}
	return dic;
}

- (StringEncoding*)defaultEncodingForLanguage:(NSString*)language
{
	NSDictionary *settings = [self settingsForLanguage:language];
	if(settings) {
		return [StringEncoding stringEncodingForIdentifier:[settings[KEY_ENCODING] integerValue]];
	} else {
		return [[Preferences shared] defaultEncoding];
	}
}

#pragma mark -

+ (void)setQuoteSubstitutionEnabled:(BOOL)flag
{
	[[NSUserDefaults standardUserDefaults] setBool:flag forKey:@"QuoteSubstitution"];
	[[NSNotificationCenter defaultCenter] postNotificationName:ILQuoteSubstitutionDidChange
														object:nil];
}

+ (BOOL)quoteSubstitutionEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"QuoteSubstitution"];
}

+ (NSString*)quoteSubstitutionForLanguage:(NSString*)language forQuoteKey:(NSString*)quote_key
{
	NSDictionary *dic = [[PreferencesLanguages shared] settingsForLanguage:language];
	if(dic == nil) return nil;
	
	return dic[quote_key];
}

+ (NSString*)openDoubleQuoteSubstitutionForLanguage:(NSString*)language
{
    return [PreferencesLanguages quoteSubstitutionForLanguage:language forQuoteKey:KEY_QUOTE_OPEN_DOUBLE];
}

+ (NSString*)closeDoubleQuoteSubstitutionForLanguage:(NSString*)language
{
    return [PreferencesLanguages quoteSubstitutionForLanguage:language forQuoteKey:KEY_QUOTE_CLOSE_DOUBLE];
}

+ (NSString*)openSingleQuoteSubstitutionForLanguage:(NSString*)language
{
    return [PreferencesLanguages quoteSubstitutionForLanguage:language forQuoteKey:KEY_QUOTE_OPEN_SINGLE];
}

+ (NSString*)closeSingleQuoteSubstitutionForLanguage:(NSString*)language
{
    return [PreferencesLanguages quoteSubstitutionForLanguage:language forQuoteKey:KEY_QUOTE_CLOSE_SINGLE];
}

#pragma mark -

- (int)numberOfItemsInComboBoxCell:(id)aComboBox
{
	return [[LanguageTool defaultLanguageIdentifiers] count];
}

- (id)comboBoxCell:(id)aComboBox objectValueForItemAtIndex:(int)index
{
	return [LanguageTool defaultLanguageIdentifiers][index];	
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    [self updateLanguagesCache];
	return YES;
}

@end
