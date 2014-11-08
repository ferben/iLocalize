//
//  StringTool.m
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "StringTool.h"
#import "ControlCharactersParser.h"
#import "PreferencesLocalization.h"
#import "Constants.h"

@implementation StringTool

static BOOL ignoreControlCharacters = NO;

+ (void)setIgnoreControlCharacters:(BOOL)flag
{
	ignoreControlCharacters = flag;
}

+ (int)numberOfNewLineInString:(NSString*)s
{
	int count = 0;
	unsigned index;
	for(index=0; index<[s length]; index++) {
		unichar c0 = [s characterAtIndex:index];
		unichar c1 = 0;
		if(index+1<[s length])
			c1 = [s characterAtIndex:index+1];
		
		if(c0 == CR && c1 == LF) {
			// Windows
			count++;
			index++;
		} else if(c0 == LF)	// Unix
			count++;
		else if(c0 == CR)	// Mac
			count++;
	}
	return count;
}

+ (NSString*)convertLineEndingsString:(NSString*)s from:(int)endings to:(int)ending
{
	// Converts both invisible and visible CR/LF line endings
	
	NSMutableString *ms = [NSMutableString string];
	
	NSString *to = nil;
	NSString *tos = nil;
	switch(ending) {
		case MAC_LINE_ENDINGS:
			to = MAC_EOL;
			tos = @"\\r";
			break;
		case UNIX_LINE_ENDINGS:
			to = UNIX_EOL;
			tos = @"\\n";
			break;
		case WINDOWS_LINE_ENDINGS:
			to = WINDOWS_EOL;
			tos = @"\\r\\n";
			break;
	}
	
	BOOL fromMac = endings & (1 << MAC_LINE_ENDINGS);
	BOOL fromUnix = endings & (1 << UNIX_LINE_ENDINGS);
	BOOL fromWindows = endings & (1 << WINDOWS_LINE_ENDINGS);
			
	unsigned index;
	for(index=0; index<[s length]; index++) {
		unichar c0 = [s characterAtIndex:index];
		unichar c1 = 0;
		if(index+1<[s length])
			c1 = [s characterAtIndex:index+1];
		
		NSString *s0 = nil;
		if(index+2<[s length])
			s0 = [s substringWithRange:NSMakeRange(index, 2)];
		
		NSString *s1 = nil;
		if(index+4<[s length])
			s1 = [s substringWithRange:NSMakeRange(index+2, 2)];
				
		if(c0 == CR && c1 == LF) {
			// Windows
			index++;
			if(fromWindows)
				[ms appendString:to];
			else
				[ms appendString:WINDOWS_EOL];
		} else if([s0 isEqualToString:@"\\r"] && [s1 isEqualToString:@"\\n"]) {
			// Windows (visible)
			index+=3;
			if(fromWindows)
				[ms appendString:tos];
			else
				[ms appendString:s0];
		} else if(c0 == LF) {
			// Unix
			if(fromUnix)
				[ms appendString:to];
			else
				[ms appendString:UNIX_EOL];
		} else if([s0 isEqualToString:@"\\n"]) {
			// Unix (visible)
			index++;
			if(fromUnix)
				[ms appendString:tos];
			else
				[ms appendString:@"\\n"];	
		} else if(c0 == CR) {
			// Mac
			if(fromMac)
				[ms appendString:to];
			else
				[ms appendString:MAC_EOL];
		} else if([s0 isEqualToString:@"\\r"]) {
			// Mac (visible)
			index++;
			if(fromMac)
				[ms appendString:tos];
			else
				[ms appendString:@"\\r"];
		} else {
			[ms appendString:[s substringWithRange:NSMakeRange(index, 1)]];
		}
	}
	
	return ms;	
}

/**
 Returns a new string where all the double-quotes have been escaped. For example:
 Hello"World => Hello\"World
 Hello\"World => Hello\"World
 */
+ (NSString*)escapeDoubleQuoteInString:(NSString*)s
{
	NSMutableString *ms = [NSMutableString stringWithCapacity:[s length]];
	BOOL escaped = NO;
	for(unsigned index=0; index<[s length]; index++) {
		unichar c = [s characterAtIndex:index];
		if(c == '"' && !escaped) {
			[ms appendString:@"\\"];			
		}
				
		if(c == '\\') {
			if(!escaped) {
				escaped = YES;
			} else {
				escaped = NO;
			}

		} else {
			escaped = NO;
		}

		
		[ms appendString:[s substringWithRange:NSMakeRange(index, 1)]];
	}
	
	return ms;
}

/**
 Returns a new string where all the double-quotes have been removed. For example:
 Hello"World => Hello World
 Hello\"World => Hello World
 */
+ (NSString*)removeDoubleQuoteInString:(NSString*)s
{
	NSMutableString *ms = [NSMutableString stringWithCapacity:[s length]];
	BOOL escaped = NO;
	for(unsigned index=0; index<[s length]; index++) {
		unichar c = [s characterAtIndex:index];
		if(c == '"') {
            if(escaped) {
                // remove the escape character
                [ms deleteCharactersInRange:NSMakeRange(ms.length-1, 1)];
                escaped = NO;
            }
            [ms appendString:@" "];
            continue;
		}
        
		if(c == '\\') {
			if(!escaped) {
				escaped = YES;
			} else {
				escaped = NO;
			}
            
		} else {
			escaped = NO;
		}
        
		
		[ms appendString:[s substringWithRange:NSMakeRange(index, 1)]];
	}
	
	return ms;
}

/**
 Unescape any escaped double-quote in the string:
 "Hello\"World" => Hello"World
 "Hello\nWorld" => Hello\nWorld
 "Hello\\World" => Hello\\World
 
 The behavior before version 4 was:
 1) \\ -> \
 2) \" -> "
 
 But in version 4, only the escape before a double-quote is removed.
 */
+ (NSString*)unescapeDoubleQuoteInString:(NSString*)s
{
	NSMutableString *ms = [NSMutableString stringWithCapacity:[s length]];
	BOOL escaped = NO;
	for(unsigned index=0; index<[s length]; index++) {
		unichar c = [s characterAtIndex:index];
		
		if(escaped) {
			escaped = NO;		
			if(c != '"') {
				// keep the backslash
				[ms appendString:@"\\"];
			}
			[ms appendFormat:@"%C", c];
		} else if(c == '\\') {
			escaped = YES;			
		} else {
			[ms appendFormat:@"%C", c];
		}
	}
	
	return ms;
}

BOOL sameControlChar(unichar a, unichar b)
{
    if(a == 'n' && b == '\n')
        return YES;
    if(a == 'r' && b == '\r')
        return YES;
    if(a == 't' && b == '\t')
        return YES;
    return NO;
}

+ (BOOL)isString:(NSString*)a equalToString:(NSString*)b ignoreEscapeDifferences:(BOOL)ignoreEscapeDifferences ignoreCase:(BOOL)ignoreCase
{
    BOOL equals = [a isEqualToString:b ignoreCase:ignoreCase];
    if(equals || !ignoreEscapeDifferences)
        return equals;
    
    // Compare two strings by ignore the difference between a control character and its equivalent escape form.
    // Example: Hello\nWorld will be the same as Hello␊World
        
    if(ignoreCase) {
        a = [a lowercaseString];
        b = [b lowercaseString];
    }
    
    int la = [a length];
    int lb = [b length];
    
    int i = 0;
    int j = 0;
    while(i < la && j < lb) {
        unichar ca = [a characterAtIndex:i];
        unichar cb = [b characterAtIndex:j];
        if(ca == '\\' && cb != '\\') {
            i++;
			if(i >= la) {
				return NO;
			}
			
            ca = [a characterAtIndex:i];
            if(!sameControlChar(ca, cb)) {
                return NO;				
			}
        } else if(ca != '\\' && cb == '\\') {
            j++;
			if(j >= lb) {
				return NO;
			}

            cb = [b characterAtIndex:j];
            if(!sameControlChar(cb, ca)) {
                return NO;				
			}
        } else if(ca != cb) {
            return NO;
        }
        
        i++;
        j++;
    }
    return (i == la) && (j == lb);
}

+ (BOOL)isString:(NSString*)a equalIgnoringEscapeToString:(NSString*)b ignoreCase:(BOOL)ignoreCase
{
    return [StringTool isString:a equalToString:b ignoreEscapeDifferences:ignoreControlCharacters ignoreCase:ignoreCase];
}

@end
