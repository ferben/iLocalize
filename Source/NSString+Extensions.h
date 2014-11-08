//
//  NSString+Extensions.h
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@interface NSString (iLocalizePathAttributes)

/**
 Returns YES if the path represents an application that can be 
 launched by iLocalize.
 */
- (BOOL)isPathApplication;

- (BOOL)isPathInvisible;
- (BOOL)isPathPackage;
- (BOOL)isPathRegular;
- (BOOL)isPathSymbolic;
- (BOOL)isPathAlias;
- (BOOL)isPathFlat;
- (BOOL)isPathWritable;
- (BOOL)isPathDirectory;
- (BOOL)isPathBundle;

- (BOOL)isPathNib;
- (BOOL)isPathNibBundle;
- (BOOL)isPathNib2;
- (BOOL)isPathNib3;
- (BOOL)isPathNibCompiledForNibtool;
- (BOOL)isPathNibCompiledForIbtool;

- (BOOL)isPathStrings;
- (BOOL)isPathTXT;
- (BOOL)isPathHTML;
- (BOOL)isPathRTF;
- (BOOL)isPathRTFD;
- (BOOL)isPathImage;
- (BOOL)isPathplist;
- (BOOL)isPathLanguageProject;

- (BOOL)isValidResourceFile;

- (NSString*)firstPathComponent;
- (NSString*)stringByRemovingFirstPathComponent;

- (NSDate*)pathCreationDate;
- (NSDate*)pathModificationDate;

- (BOOL)isEqualCaseInsensitiveToString:(NSString*)string;
- (BOOL)isEqualToString:(NSString*)string ignoreCase:(BOOL)ignore;
- (BOOL)isEqualToPath:(NSString*)path;
- (BOOL)isEquivalentToPath:(NSString*)path;

- (BOOL)isPathContentEqualsToPath:(NSString*)path;

- (NSString*)stringByRemovingPrefixIgnoringCase:(NSString*)prefix;
- (NSString*)stringByRemovingPrefix:(NSString*)prefix;

- (NSString*)stringByRemovingSuffix:(NSString*)suffix;

- (NSImage*)imageOfPath;

@end

@interface NSString (iLocalizePathAction)
- (BOOL)removePathFromDisk:(NSError**)error;
- (BOOL)removePathFromDisk;
- (BOOL)movePathToTrash;
@end

@interface NSString (iLocalizeLanguage)
- (BOOL)isEquivalentToLanguageCode:(NSString*)language;
- (BOOL)isEquivalentToLanguage:(NSString*)language;
- (BOOL)isLegacyLanguage;
- (NSString*)legacyLanguage;
- (NSString*)isoLanguage;
- (NSString*)displayLanguageName;
- (NSString*)languageOfPath;
@end

@interface NSString (iLocalizeComparaison)
- (BOOL)isEqualToValue:(NSString*)otherValue options:(unsigned)options;
@end

@interface NSString (XML)
- (BOOL)containsValidXMLCharacters:(NSUInteger*)badCharacterLocation;
- (BOOL)xmlNeedsToBeEscaped;
- (NSString*)xmlEscaped;
- (NSString*)xmlUnescaped;
@end

@interface NSString (Drawing)
- (float)heightForWidth:(float)inWidth withAttributes:(NSDictionary *)inAttributes;
@end	
