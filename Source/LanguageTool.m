//
//  LanguageTool.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "LanguageTool.h"
#import "LanguageInfoModel.h"
#import "Constants.h"

@implementation LanguageTool

static NSArray *defaultLanguageIdentifiers = nil;
static NSLocale *autoupdatingLocale = nil;

+ (void)initialize
{
	autoupdatingLocale = [NSLocale autoupdatingCurrentLocale];
	defaultLanguageIdentifiers = @[@"en", @"ja", @"fr", @"de", @"es", @"it", @"nl", @"pl", @"sv", @"nb",
								  @"da", @"fi", @"ko", @"zh_Hans_CN", @"zh_Hant_TW", @"ru", @"bg", @"uk", @"cs", @"sk", @"hu"];
}

+ (BOOL)setSpellCheckerLanguage:(NSString*)language
{
	NSSpellChecker* sc = [NSSpellChecker sharedSpellChecker];
	// For some weird reasons, we need to turn ON and OFF the automatically identifies languages in order
	// for the popup menu to select the language. Otherwise, it will set the language once and won't change it subsequently.
	[sc setAutomaticallyIdentifiesLanguages:YES];
	BOOL success = [sc setLanguage:language];
	[sc setAutomaticallyIdentifiesLanguages:NO];
	if(!success) {
		NSLog(@"Cannot change the spelling language to %@", language);
	}		
	return success;
}

+ (NSArray*)emptyFoldersInLanguage:(NSString*)language path:(NSString*)path
{
	NSMutableArray *array = [NSMutableArray array];
	if(path != nil) {
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString *file;
		while (file = [enumerator nextObject]) {
			if([file isPathLanguageProject]) {
				NSString *language = [[file stringByDeletingPathExtension] lastPathComponent];
				if([array indexOfObject:language] == NSNotFound)
					[array addObject:language];
				[enumerator skipDescendents];
			}
		}		
	}
	return array;
}

+ (NSArray*)defaultLanguageIdentifiers
{
	return defaultLanguageIdentifiers;
}

+ (NSArray*)languagesInPath:(NSString*)path shallow:(BOOL)shallow
{
	NSMutableArray *array = [NSMutableArray array];
	if(path != nil) {
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
		for(NSString *file in enumerator) {
			NSString *absoluteFile = [path stringByAppendingPathComponent:file];
			if([absoluteFile isPathAlias]) continue;
			if([absoluteFile isPathSymbolic]) continue;
			
			if([file isPathLanguageProject]) {
				NSString *language = [[file stringByDeletingPathExtension] lastPathComponent];
				if([array indexOfObject:language] == NSNotFound)
					[array addObject:language];
				[enumerator skipDescendents];
			}
			
			if(shallow && [absoluteFile isPathDirectory]) {
				[enumerator skipDescendents];
			}
		}		
	}
	return array;	
}

+ (NSArray*)languagesInPath:(NSString*)path
{
	return [LanguageTool languagesInPath:path shallow:NO];
}

+ (NSArray*)legacyLanguagesInPath:(NSString*)path
{
    return [LanguageTool legacyLanguages:[LanguageTool languagesInPath:path]];
}

+ (NSString*)languageOfFile:(NSString*)file
{	
	NSEnumerator *enumerator = [[file pathComponents] reverseObjectEnumerator];
	NSString *component;
	while(component = [enumerator nextObject]) {
		if([component hasSuffix:LPROJ])
			return [component substringToIndex:[component length]-[LPROJ length]];
	}
	return @"";
}

+ (NSString*)fileByDeletingLanguageComponent:(NSString*)file
{
	NSMutableArray *components = [NSMutableArray arrayWithArray:[file pathComponents]];
	int i;
	for(i = [components count]-1; i>=0; i--) {
		if([components[i] hasSuffix:LPROJ]) {
			[components removeObjectAtIndex:i];
			break;
		}		
	}
	return [NSString pathWithComponents:components];
}

// Returns a list of legacy names who have corresponding ISO name in the same bundle

+ (NSArray*)nonNormalizedLanguagesInPath:(NSString*)path
{
    NSMutableArray *nonNormalizedLanguages = [NSMutableArray array];
    
    NSArray *languages = [LanguageTool languagesInPath:path];
    NSEnumerator *enumerator = [languages objectEnumerator];
    NSString *language;
    while(language = [enumerator nextObject]) {
        if([language isLegacyLanguage]) {
            NSString *isoName = [language isoLanguage];
            if(isoName && [languages containsObject:isoName] && ![language isEqualToString:isoName])
                [nonNormalizedLanguages addObject:language];                
        } else {
            NSString *legacyName = [language legacyLanguage];
            if(legacyName && [languages containsObject:legacyName] && ![language isEqualToString:legacyName])
                [nonNormalizedLanguages addObject:legacyName];                
        }
    }
    
    return nonNormalizedLanguages;    
}

#pragma mark -

static NSArray *languages = nil;
static NSMutableArray *legacyLanguages = nil;

+ (NSArray*)languages
{
	@synchronized(self) {
		if(languages == nil) {
			languages = @[@"English", @"en",
						 @"Japanese", @"ja",
						 @"French", @"fr",
						 @"German", @"de",
						 @"Spanish", @"es",
						 @"Italian", @"it",
						 @"Dutch", @"nl",
						 @"Portuguese", @"pt",
						 @"Swedish", @"sv",
						 @"Norwegian", @"no",
						 @"Danish", @"da",
						 @"Finnish", @"fi",
						 @"Korean", @"ko",
						 @"zh_CN", @"zh_CN",
						 @"zh_TW", @"zh_TW",
						 @"Russian", @"ru",
						 @"Bulgarian", @"bg",
						 @"Ukrainian", @"uk",
						 @"Czech", @"cs",
						 @"Slovak", @"sk",
						 @"Polish", @"pl",
						 @"Hungarian", @"hu"];
		}
	}
	return languages;
}

+ (NSString*)languageEquivalentToLanguage:(NSString*)a
{
	NSAssert([[LanguageTool languages] count] % 2 == 0, @"Languages equivalent array is not even");
	
	NSUInteger index = [[LanguageTool languages] indexOfObject:a];
	if(index == NSNotFound)
		return nil;
	
	if(index % 2 == 0)
		return [LanguageTool languages][index+1];
	else
		return [LanguageTool languages][index-1];
}

+ (BOOL)isLanguage:(NSString*)a equalsToLanguage:(NSString*)b
{
	if([a isEqualToString:b ignoreCase:YES]) {
		return YES;        
    }
    
    // Equivalence for "French" and "fr"
    if ([[LanguageTool languageEquivalentToLanguage:a] isEqualToString:b]) {
        return YES;
    }

    // Helps for "en_GB" == "en-GB"
    return [[NSLocale componentsFromLocaleIdentifier:a] isEqualToDictionary:[NSLocale componentsFromLocaleIdentifier:b]];
}

+ (NSArray*)equivalentLanguagesWithLanguage:(NSString*)base
{
	if(!base) {
		return nil;
	}
	
    NSString *equ = [LanguageTool languageEquivalentToLanguage:base];
    if(equ)
        return @[base, equ];
    else
        return @[base];
}

// "fr_CH" will be equal to "fr" or "French"
+ (BOOL)isLanguageCode:(NSString*)a equivalentToLanguageCode:(NSString*)b
{
	if(b == nil) return a == nil;
	
	NSString *lca = [NSLocale componentsFromLocaleIdentifier:a][NSLocaleLanguageCode];
	NSString *lcb = [NSLocale componentsFromLocaleIdentifier:b][NSLocaleLanguageCode];
	// Make sure to keep the original case of the language (because NSLocale will convert "English" to "english" for example)
	if([lca isEqualCaseInsensitiveToString:a]) {
		lca = a;
	}
	if([lcb isEqualCaseInsensitiveToString:b]) {
		lcb = b;
	}
	return [LanguageTool isLanguage:lca equalsToLanguage:lcb];
}

#pragma mark -

+ (NSArray*)availableLegacyLanguages
{
	@synchronized(self) {
		if(!legacyLanguages) {
			legacyLanguages = [[NSMutableArray alloc] init];
			NSArray *languages = [LanguageTool languages];
			unsigned index;
			for(index = 0; index < [languages count]; index+=2) {
				[legacyLanguages addObject:languages[index]];
			}
		}		
	}
    return legacyLanguages;
}

+ (NSString*)legacyLanguageForLanguage:(NSString*)language
{
    NSArray *languages = [LanguageTool languages];
    unsigned index;
    for(index = 1; index < [languages count]; index+=2) {
        if([languages[index] isEqualToString:language])
            return languages[index-1];
    }
    return nil;
}

+ (NSString*)isoLanguageForLanguage:(NSString*)language
{
    NSArray *languages = [LanguageTool languages];
    unsigned index;
    for(index = 0; index < [languages count]; index+=2) {
        if([languages[index] isEqualToString:language])
            return languages[index+1];
    }
    return nil;
}

+ (NSArray*)legacyLanguages:(NSArray*)languages
{
    // Try to return only the legacy languages if available (i.e. "French" instead of "fr", etc)
    
    NSArray *legacys = [LanguageTool availableLegacyLanguages];
    
    NSMutableArray *reduced = [NSMutableArray array];
    NSString *language;
    for(language in languages) {
        if([legacys containsObject:language]) {
            if(![reduced containsObject:language])
                [reduced addObject:language];            
        } else {
            // Non-legacy form
            NSString *legacy = [LanguageTool legacyLanguageForLanguage:language];
            if(legacy) {
                if(![reduced containsObject:legacy])
                    [reduced addObject:legacy];            
            } else {
                // No legacy form available, let the language as it is
                [reduced addObject:language];                            
            }
        }
    }
    return reduced;
}

+ (NSString*)displayNameForLanguage:(NSString*)language
{
	NSString *displayName = [autoupdatingLocale displayNameForKey:NSLocaleIdentifier value:language];
	if(!displayName) {
		displayName = [NSLocale canonicalLocaleIdentifierFromString:language];		
		displayName = [autoupdatingLocale displayNameForKey:NSLocaleIdentifier value:displayName];
	}
	return displayName?:language;
}

+ (NSString*)languageIdentifierForLanguage:(NSString*)language
{
	// get the language part of the identifier
	NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:language];
	return [autoupdatingLocale displayNameForKey:NSLocaleLanguageCode value:components[NSLocaleLanguageCode]];
}

#pragma mark -

+ (NSArray*)availableLanguageInfos
{
	NSMutableArray *languages = [NSMutableArray array];
	
	for(NSString *identifier in [NSLocale availableLocaleIdentifiers]) {
		LanguageInfoModel *model = [LanguageInfoModel infoWithIdentifier:identifier];
		[languages addObject:model];
	}			
	
	return [languages sortedArrayUsingSelector:@selector(compareDisplayName:)];
}

+ (void)fillAvailableLanguageIdentifiersToMenu:(NSMenu*)menu target:(id)target action:(SEL)action
{
	[menu removeAllItems];
	NSString *lastLanguageIdentifier = nil;
	int tag = 0;
	for(LanguageInfoModel *model in [LanguageTool availableLanguageInfos]) {
		if(!lastLanguageIdentifier) {
			lastLanguageIdentifier = model.languageIdentifier;
		} else if(![model.languageIdentifier isEqualToString:lastLanguageIdentifier]) {
			lastLanguageIdentifier = model.languageIdentifier;
			[menu addItem:[NSMenuItem separatorItem]];
		}
			
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:model.displayName action:nil keyEquivalent:@""];
		if(target)
			[item setTarget:target];
		if(action)
			[item setAction:action];
		[item setRepresentedObject:model];
		[item setTag:tag++];
		[menu addItem:item];		
	}
}

@end
