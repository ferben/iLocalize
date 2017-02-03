//
//  NSString+Extensions.m
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "NSString+Extensions.h"
#import "NibEngine.h"

#import "LanguageTool.h"
#import "FileTool.h"
#import "StringTool.h"

#import "PreferencesAdvanced.h"

#import "Constants.h"

@implementation NSString (iLocalizePathAttributes)

- (BOOL)isPathApplication
{
    NSString *ext = [self pathExtension];
    return [ext isEqualToString:@"app"] || [ext isEqualToString:@"ape"];
}
    
- (BOOL)isPathInvisible
{
    return [[self lastPathComponent] hasPrefix:@"."];
}

- (BOOL)isPathPackage
{
    return [[NSWorkspace sharedWorkspace] isFilePackageAtPath:self];
}

- (BOOL)isPathRegular
{
    return [[[[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil] fileType] isEqualToString:NSFileTypeRegular];
}

- (BOOL)isPathSymbolic
{
    return [[[[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil] fileType] isEqualToString:NSFileTypeSymbolicLink];
}

- (BOOL)isPathAlias
{
    Boolean isAlias = NO;
    
    NSURL *theURL = [NSURL fileURLWithPath:self];
    NSNumber *number = NULL;
    
    if ([theURL getResourceValue:&number forKey:NSURLIsAliasFileKey error:nil])
        isAlias = [number boolValue];
    
    return isAlias;
}

- (BOOL)isPathFlat
{
    return [self isPathSymbolic] || [self isPathRegular] || [self isPathAlias];
}

- (BOOL)isPathWritable
{
    return [[NSFileManager defaultManager] isWritableFileAtPath:self];
}

- (BOOL)isPathDirectory
{
    return [[[[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil] fileType] isEqualToString:NSFileTypeDirectory];
}

- (BOOL)isPathBundle
{
    return [self isPathPackage] || [self isPathDirectory];
}

- (BOOL)isPathNib
{
    return [[self pathExtension] isEqualToString:@"nib"] || [[self pathExtension] isEqualToString:@"xib"];
}

- (BOOL)isPathNibBundle
{
    return [self isPathNib] && ![self isPathFlat];
}

- (BOOL)isPathNib2
{
    if([[self pathExtension] isEqualToString:@"xib"]) return NO;

    return [[self stringByAppendingPathComponent:@"classes.nib"] isPathExisting] && [[self stringByAppendingPathComponent:@"info.nib"] isPathExisting];
}

- (BOOL)isPathNib3
{
    if([[self pathExtension] isEqualToString:@"xib"]) return YES;
    
    return [[self stringByAppendingPathComponent:@"keyedobjects.nib"] isPathExisting] && [[self stringByAppendingPathComponent:@"designable.nib"] isPathExisting];
}

/*
 
 Comparison of various nib files:
 
 normal-v2.nib            keyedobjects.nib    classes.nib    info.nib
 compiled-v2.nib        keyedobjects.nib
 compiled-ibtool.nib    keyedobjects.nib    classes.nib -> works fine for nibtool!
 normal-v3.nib            keyedobjects.nib    designable.nib
 compiled-v3.nib        keyedobjects.nib
 */
 
 
- (BOOL)isPathNibCompiledForNibtool
{
    if([[self pathExtension] isEqualToString:@"xib"]) return NO;
    
    return ![[self stringByAppendingPathComponent:@"classes.nib"] isPathExisting] && ![[self stringByAppendingPathComponent:@"info.nib"] isPathExisting];
}

- (BOOL)isPathNibCompiledForIbtool
{
    if([[self pathExtension] isEqualToString:@"xib"]) return NO;

    if([[self stringByAppendingPathComponent:@"designable.nib"] isPathExisting]) {
        // version 3 non-compiled file
        return NO;
    }
    if([[self stringByAppendingPathComponent:@"classes.nib"] isPathExisting] && [[self stringByAppendingPathComponent:@"info.nib"] isPathExisting]) {
        // version 2 non-compiled file
        return NO;
    }
    if([[self stringByAppendingPathComponent:@"designtime.nib"] isPathExisting] && [[self stringByAppendingPathComponent:@"runtime.nib"] isPathExisting]) {
        // version 3 iOS non-compiled file
        return NO;
    }
    return YES;
}

- (BOOL)isPathStrings
{
    return [[self pathExtension] isEqualToString:@"strings"];
}

- (BOOL)isPathTXT
{
    return [[self pathExtension] isEqualToString:@"txt"];
}

- (BOOL)isPathHTML
{
    return [[self pathExtension] isEqualToString:@"html"] || [[self pathExtension] isEqualToString:@"htm"];
}

- (BOOL)isPathRTF
{
    return [[self pathExtension] isEqualToString:@"rtf"];
}

- (BOOL)isPathRTFD
{
    return [[self pathExtension] isEqualToString:@"rtfd"];
}

- (BOOL)isPathImage
{
    return [[NSImage imageFileTypes] containsObject:[self pathExtension]];
}

- (BOOL)isPathplist
{
    return [[self pathExtension] isEqualToString:@"plist"];
}

- (BOOL)isPathLanguageProject
{
    return [[self pathExtension] isEqualToString:@"lproj"];    
}

- (BOOL)isValidResourceFile
{
    // Is file a backup nib file ?
    if([self hasSuffix:@"~.nib"])
        return NO;
    
    // Is file invisible ?
    if([self isPathInvisible])
        return NO;
    
    // FIX CASE 49: Is file a symbolic link?
    if([self isPathSymbolic])
        return NO;
    
    // Is file a package (like nib) ?
    if([self isPathPackage])
        return YES;
    
    // Is file a standard file ?
    if([self isPathRegular])
        return YES;
    
    return NO;
}

- (NSString*)firstPathComponent
{
    int offset = 0;
    if([self hasPrefix:@"/"])
        offset = 1;
    
    NSUInteger stop = [self rangeOfString:@"/" options:0 range:NSMakeRange(offset, [self length]-offset)].location;
    if(stop == NSNotFound)
        return [self substringFromIndex:offset];
    else
        return [self substringWithRange:NSMakeRange(offset, stop-offset)];
}

- (NSString*)stringByRemovingFirstPathComponent
{
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self pathComponents]];
    [components removeFirstObject];
    return [NSString pathWithComponents:components];
}

- (NSString*)stringByRemovingPrefixIgnoringCase:(NSString*)prefix
{
    NSRange range = [self rangeOfString:prefix options:NSAnchoredSearch|NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        return [self substringFromIndex:range.location+range.length];
    } else {
        return nil;
    }
}

- (NSString*)stringByRemovingPrefix:(NSString*)prefix
{
    if([self hasPrefix:prefix]) {
        return [self substringFromIndex:[prefix length]];
    } else {
        return NULL;
    }
}
    
- (NSString*)stringByRemovingSuffix:(NSString*)suffix
{
    if([self hasSuffix:suffix]) {
        return [self substringToIndex:[self length]-[suffix length]];
    } else {
        return NULL;
    }    
}

- (NSDate*)pathCreationDate
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil][NSFileCreationDate];
}

- (NSDate*)pathModificationDate
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil] fileModificationDate];
}

- (BOOL)isEqualCaseInsensitiveToString:(NSString*)string
{
    if(!string)
        return NO;
    
    return [self caseInsensitiveCompare:string] == NSOrderedSame;
}

- (BOOL)isEqualToString:(NSString*)string ignoreCase:(BOOL)ignore
{
    if(!string)
        return NO;
    
    if(ignore)
        return [self isEqualCaseInsensitiveToString:string];
    else
        return [self isEqualToString:string];
}

- (BOOL)isEqualToPath:(NSString*)path
{
    if ([[self stringByStandardizingPath] isEqualToString:[path stringByStandardizingPath]]) {
        return YES;
    } else if([self hasSuffix:@"/"] && [path hasSuffix:@"/"])
        return [self isEqualToString:path];
    else if(![self hasSuffix:@"/"] && ![path hasSuffix:@"/"])
        return [self isEqualToString:path];
    else if([self hasSuffix:@"/"])
        return [[self substringToIndex:[self length]-1] isEqualToString:path];
    else
        return [self isEqualToString:[path substringToIndex:[path length]-1]];
}

- (BOOL)isEquivalentToPath:(NSString*)path
{
    @autoreleasepool {
        BOOL result = NO;
        for(NSString *equivalentPath in [FileTool equivalentLanguagePaths:path]) {
        if([self isEqualCaseInsensitiveToString:equivalentPath]) {
            result = YES;
            break;
        }
    }
    return result;
    }
}

- (BOOL)isPathContentEqualsToPath:(NSString*)path
{
    if([[NSFileManager defaultManager] contentsEqualAtPath:self andPath:path]) {
        return YES;
    }
    
    // Ok, they are binary different. Now if these files are nib files, then let's do some more work to
    // compare them using their XML representation.
    if([self isPathNib] && [[NSUserDefaults standardUserDefaults] boolForKey:@"nibcompare"]) {
        NibEngine *engine = [NibEngine engineWithConsole:nil];
        NSError *error = nil;
        BOOL identical = [engine isNibFile:self identicalToFile:path error:&error];
        if(error) {
            NSLog(@"Error trying to compare two nib files (will use the standard comparison method): %@", [error description]); 
        } else {
            return identical;
        }
    }
    
    return NO;
}

- (NSImage*)imageOfPath
{
    return [[NSWorkspace sharedWorkspace] iconForFile:self];    
}

@end

@implementation NSString (iLocalizePathAction)

- (BOOL)removePathFromDisk:(NSError**)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:self error:error];    
}

- (BOOL)removePathFromDisk
{
    return [self removePathFromDisk:nil];
}

- (BOOL)movePathToTrash
{
    NSInteger tag;
    return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                        source:[self parentPath]
                                                   destination:@""
                                                         files:@[[self lastPathComponent]]
                                                           tag:&tag];    
}

@end

@implementation NSString (iLocalizeLanguage)

- (BOOL)isEquivalentToLanguageCode:(NSString*)language
{
    return [LanguageTool isLanguageCode:self equivalentToLanguageCode:language];
}

- (BOOL)isEquivalentToLanguage:(NSString*)language
{
    return [LanguageTool isLanguage:self equalsToLanguage:language];
}

- (BOOL)isLegacyLanguage
{
    return [[LanguageTool availableLegacyLanguages] containsObject:self];
}

- (NSString*)legacyLanguage
{
    if([self isLegacyLanguage]) 
        return self;
    else
        return [LanguageTool legacyLanguageForLanguage:self];
}

- (NSString*)isoLanguage
{
    if([self isLegacyLanguage])    
        return [LanguageTool isoLanguageForLanguage:self];    
    else
        return self;
}

- (NSString*)displayLanguageName
{
    NSString *name = [LanguageTool displayNameForLanguage:self];
    return [[[name substringToIndex:1] uppercaseString] stringByAppendingString:[name substringFromIndex:1]];
}

- (NSString*)languageOfPath
{
    return [FileTool languageOfPath:self];
}

@end

@implementation NSString (iLocalizeComparaison)

- (BOOL)isEqualToValue:(NSString*)otherValue options:(unsigned)options
{
    return [StringTool isString:self equalIgnoringEscapeToString:otherValue ignoreCase:(options & ILStringIgnoreCase) > 0];
}

@end

@implementation NSString (XML)

/**
 Returns YES if the string contains only valid characters for XML.
 See http://www.w3.org/TR/xml/#charsets.
 Range is:
 #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]    
 */
- (BOOL)containsValidXMLCharacters:(NSUInteger*)badCharacterLocation
{
    for(int index = 0; index < [self length]; index++) {
        unichar c = [self characterAtIndex:index];
        if(c == 0x9) continue;
        if(c == 0xA) continue;
        if(c == 0xD) continue;

        if(c >= 0x20 && c<= 0xD7FF) continue;
        if(c >= 0xE000 && c<= 0xFFDD) continue;
//        if(c >= 0x10000 && c<= 0x10FFFF) continue;

        if(badCharacterLocation) {
            *badCharacterLocation = index;            
        }
        
        return NO;
    }
    return YES;    
}

/**
 Returns true if one of the illegal character of an XML string is found.
 */
- (BOOL)xmlNeedsToBeEscaped
{
    for(int index = 0; index < [self length]; index++) {
        unichar c = [self characterAtIndex:index];
        if(c == '<') return YES;
        if(c == '>') return YES;
        if(c == '\'') return YES;
        if(c == '"') return YES;
        if(c == '&') return YES;
    }
    return NO;
}

/**
 Returns a new string in which all illegal XML characters have been escaped.
 See http://xml.silmaril.ie/specials.html.
 <, >, &, ' and " will be escaped properly.
 */
- (NSString*)xmlEscaped
{
    if(![self xmlNeedsToBeEscaped]) return self;
    
    NSMutableString *m = [NSMutableString stringWithCapacity:[self length]];
    for(int index = 0; index < [self length]; index++) {
        unichar c = [self characterAtIndex:index];
        if(c == '&') {
            unichar c1 = [self length] > index+1 ? [self characterAtIndex:index+1] : 0;
            unichar c2 = [self length] > index+2 ? [self characterAtIndex:index+2] : 0;
            unichar c3 = [self length] > index+3 ? [self characterAtIndex:index+3] : 0;
            unichar c4 = [self length] > index+4 ? [self characterAtIndex:index+4] : 0;
            if(c1 == 'l' && c2 == 't' && c3 == ';') {
                [m appendFormat:@"%C", c];                
            } else if(c1 == 'g' && c2 == 't' && c3 == ';') {
                [m appendFormat:@"%C", c];
            } else if(c1 == 'a' && c2 == 'm' && c3 == 'p' && c4 == ';') {
                [m appendFormat:@"%C", c];
            } else {
                // alone
                [m appendString:@"&amp;"];
            }
        } else if(c == '<') {
            [m appendString:@"&lt;"];
        } else if(c == '>') {
            [m appendString:@"&gt;"];                
        } else if(c == '"') {
            [m appendString:@"&quot;"];                
        } else if(c == '\'') {
            [m appendString:@"&apos;"];                
        } else {
            [m appendFormat:@"%C", c];
        }
    }
    return m;
}

/**
 Unescape all the escaped characters from this XML string.
 */
- (NSString*)xmlUnescaped
{
    NSMutableString *m = [NSMutableString stringWithCapacity:[self length]];
    for(int index = 0; index < [self length]; index++) {
        unichar c0 = [self characterAtIndex:index];
        unichar c1 = [self length] > index+1 ? [self characterAtIndex:index+1] : 0;
        unichar c2 = [self length] > index+2 ? [self characterAtIndex:index+2] : 0;
        unichar c3 = [self length] > index+3 ? [self characterAtIndex:index+3] : 0;
        unichar c4 = [self length] > index+4 ? [self characterAtIndex:index+4] : 0;
        unichar c5 = [self length] > index+5 ? [self characterAtIndex:index+5] : 0;
        if(c0 == '&' && c1 == 'q' && c2 == 'u' && c3 == 'o' && c4 == 't' && c5 == ';') {
            [m appendString:@"\""];
            index += 5;
        } else if(c0 == '&' && c1 == 'a' && c2 == 'p' && c3 == 'o' && c4 == 's' && c5 == ';') {
            [m appendString:@"'"];
            index += 5;
        } else if(c0 == '&' && c1 == 'l' && c2 == 't' && c3 == ';') {
            [m appendString:@"<"];
            index += 3;
        } else if(c0 == '&' && c1 == 'g' && c2 == 't' && c3 == ';') {
            [m appendString:@">"];
            index += 3;
        } else if(c0 == '&' && c1 == 'a' && c2 == 'm' && c3 == 'p' && c4 == ';') {
            [m appendString:@"&"];
            index += 4;
        } else {
            [m appendFormat:@"%C", c0];
        }
        
    }
    return m;    
}

@end

@implementation NSString (Drawing)

- (float)heightForWidth:(float)inWidth withAttributes:(NSDictionary *)inAttributes {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self attributes:inAttributes];

    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:string];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(inWidth, FLT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager setBackgroundLayoutEnabled:[NSThread isMainThread]];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    float height = [layoutManager usedRectForTextContainer:textContainer].size.height;
    
    
    return height;
}

@end
