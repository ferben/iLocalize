//
//  StringTool.h
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@interface StringTool : NSObject
{
}

+ (void)setIgnoreControlCharacters:(BOOL)flag;
+ (NSUInteger)numberOfNewLineInString:(NSString *)s;
+ (NSString *)convertLineEndingsString:(NSString *)s from:(int)endings to:(int)ending;
+ (NSString *)escapeDoubleQuoteInString:(NSString *)s;
+ (NSString *)removeDoubleQuoteInString:(NSString *)s;
+ (NSString *)unescapeDoubleQuoteInString:(NSString *)s;
+ (BOOL)isString:(NSString *)a equalToString:(NSString *)b ignoreEscapeDifferences:(BOOL)ignoreEscapeDifferences ignoreCase:(BOOL)ignoreCase;
+ (BOOL)isString:(NSString *)a equalIgnoringEscapeToString:(NSString *)b ignoreCase:(BOOL)ignoreCase;

@end
