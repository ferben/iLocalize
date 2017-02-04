//
//  LanguageTool.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@interface LanguageTool : NSObject
{
}

+ (BOOL)setSpellCheckerLanguage:(NSString *)language;

+ (NSArray *)defaultLanguageIdentifiers;

+ (NSArray *)languagesInPath:(NSString *)path shallow:(BOOL)shallow;
+ (NSArray *)languagesInPath:(NSString *)path;
+ (NSArray *)legacyLanguagesInPath:(NSString *)path;
+ (NSString *)languageOfFile:(NSString *)file;
+ (NSString *)fileByDeletingLanguageComponent:(NSString *)file;

+ (NSArray *)nonNormalizedLanguagesInPath:(NSString *)path;

+ (NSString *)languageEquivalentToLanguage:(NSString *)a;
+ (BOOL)isLanguage:(NSString *)a equalsToLanguage:(NSString *)b;
+ (NSArray *)equivalentLanguagesWithLanguage:(NSString *)base;
+ (BOOL)isLanguageCode:(NSString *)a equivalentToLanguageCode:(NSString *)b;

+ (NSArray *)availableLegacyLanguages;
+ (NSString *)legacyLanguageForLanguage:(NSString *)language;
+ (NSString *)isoLanguageForLanguage:(NSString *)language;
+ (NSArray *)legacyLanguages:(NSArray *)languages;

+ (NSString *)displayNameForLanguage:(NSString *)language;
+ (NSString *)languageIdentifierForLanguage:(NSString *)language;

+ (NSArray *)availableLanguageInfos;
+ (void)fillAvailableLanguageIdentifiersToMenu:(NSMenu *)menu target:(id)target action:(SEL)action;

@end
