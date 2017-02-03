//
//  XMLParser.m
//  Tests
//
//  Created by Jean on 9/3/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "XMLParser.h"

@implementation XMLParser

+ (void)parseString:(NSString *)string
{
    XMLParser *parser = [[XMLParser alloc] init];
    [parser setString:string];
    [parser parse];
}

+ (void)parseFile:(NSString *)file
{
    return [XMLParser parseString:[NSString stringWithContentsOfFile:file usedEncoding:nil error:nil]];
}

- (id)init
{
    if (self = [super init])
    {
        mDelegate = nil;
        mString = nil;
        mScanner = nil;
        
        mIdentifierSet = [[NSMutableCharacterSet alloc] init];
        [mIdentifierSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
        [mIdentifierSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"-_"]];
        
        mQuotesSet = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
    }
    
    return self;
}


- (void)setDelegate:(id<XMLParserDelegate>)delegate
{
    mDelegate = delegate;
}

- (void)setString:(NSString *)string
{
    mString = string;
}

- (BOOL)scanAttributesOfElement:(NSString *)element
{
    // Attribute encountered
    NSString *attributeName;
    
    while ([mScanner scanCharactersFromSet:mIdentifierSet intoString:&attributeName])
    {
        if (![mScanner scanString:@"=" intoString:nil])
        {
            NSLog(@"Element: %@, Attribut: %@", element, attributeName);
            
            [mDelegate parser:self error:[NSString stringWithFormat:@"NSString [element: %@] [attribute: %@] - No '=' found between attribute name and content", element, attributeName]];
            mError = YES;
            return NO;
        }
        
        // check begin of attribute content
        if (![mScanner scanCharactersFromSet:mQuotesSet intoString:nil])
        {
            NSLog(@"Element: %@, Attribut: %@", element, attributeName);
            
            [mDelegate parser:self error:[NSString stringWithFormat:@"NSString [element: %@] [attribute: %@] - Attribute content does not begin with a '\"' or '\'' sign", element, attributeName]];
            mError = YES;
            return NO;
        }
        
        NSString *attributeContent;        
        NSUInteger startLocation = [mScanner scanLocation];
        
        // check end of attribute string
        if (![mScanner scanUpToCharactersFromSet:mQuotesSet intoString:&attributeContent])
        {
            NSLog(@"Element: %@, Attribut: %@", element, attributeName);
            
            [mDelegate parser:self error:[NSString stringWithFormat:@"NSString [element: %@] [attribute: %@] - Attribute content does not end with a '\"' or '\'' sign", element, attributeName]];
            mError = YES;
            return NO;
        }
        
        NSUInteger endLocation = [mScanner scanLocation];
        [mScanner scanCharactersFromSet:mQuotesSet intoString:nil];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[INFO_START_LOCATION] = [NSNumber numberWithInteger:startLocation];
        info[INFO_END_LOCATION] = [NSNumber numberWithInteger:endLocation];
        [mDelegate parser:self element:element attributeName:attributeName content:attributeContent info:info];
    }
    
    return YES;
}

- (BOOL)scanContent
{
    if ([mScanner scanString:@"<![CDATA[" intoString:nil])
    {
        // CDATA
        [mScanner scanUpToString:@"]]>" intoString:nil];
        
        if (![mScanner scanString:@"]]>" intoString:nil])
        {
            [mDelegate parser:self error:@"CDATA does not end with ]]>"];
            mError = YES;
            return NO;
        }
        
        return YES;
    }
    else
    {
        NSString *content;
        
        if ([mScanner scanUpToString:@"<" intoString:&content])
        {
            [mDelegate parser:self content:[content xmlUnescaped]];
            return YES;
        }
        
        return NO;
    }
}

- (BOOL)scanTag
{
    // COMMENT
    // Comment: <!-- ... -->
    if ([mScanner scanString:@"<!--" intoString:nil])
    {
        NSString *comment;
        [mScanner scanUpToString:@"-->" intoString:&comment];
        
        if (![mScanner scanString:@"-->" intoString:nil])
        {
            [mDelegate parser:self error:@"Comment does not end with -->"];
            mError = YES;
            return NO;
        }
        
        [mDelegate parser:self comment:comment];
        return YES;
    }
    // DOCTYPE
    // Example: <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html401/sgml/loosedtd.html">
    else if ([mScanner scanString:@"<!DOCTYPE" intoString:nil])
    {
        [mScanner scanUpToString:@">" intoString:nil];
        
        if (![mScanner scanString:@">" intoString:nil])
        {
            [mDelegate parser:self error:@"DOCTYPE does not end with >"];
            mError = YES;
            return NO;
        }
        
        return YES;        
    }
    // TAG
    else if(![mScanner scanString:@"<" intoString:nil])
    {
        // Content?
        return [self scanContent];
    }

    BOOL closingTag = [mScanner scanString:@"/" intoString:nil];

    NSString *name;
    
    if (![mScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@" \n\r\t>/"] intoString:&name])
        return NO;
    
    if ([mScanner scanString:@"/>" intoString:nil])
    {
        // Empty element
        [mDelegate parser:self beginElement:name];
        [mDelegate parser:self endElement:name];
        return YES;
    }
    else if ([mScanner scanString:@">" intoString:nil])
    {
        // Complete element
        if (closingTag)
        {
            [mDelegate parser:self endElement:name];
        }
        else
        {
            [mDelegate parser:self beginElement:name];
        }
        
        return YES;
    }
    else
    {
        [mDelegate parser:self beginElement:name];

        if (![self scanAttributesOfElement:name])
            return NO;
        
        // handle special case for <?xml ... ?>
        // Example: <?xml version="1.0" encoding="utf-8"?>
        if ([name isEqualToString:@"?xml"] && [mScanner scanString:@"?>" intoString:nil])
        {
            return YES;
        }
        
        if ([mScanner scanString:@">" intoString:nil])
        {
            return YES;
        }
        
        if ([mScanner scanString:@"/>" intoString:nil])
        {
            [mDelegate parser:self endElement:name];
            return YES;
        }
        [mDelegate parser:self error:@"No end of element found after attributes parsing"];
        mError = YES;
        return NO;
    }
}

- (BOOL)scanHeader
{
    // <?xml version="1.0" encoding="UTF-8"?>
    if ([mScanner scanString:@"<?xml" intoString:nil])
    {
        [mDelegate parser:self beginElement:@"?xml"];
        [self scanAttributesOfElement:@"?xml"];
        
        if (![mScanner scanString:@"?>" intoString:nil])
        {
            [mDelegate parser:self error:@"<?xml does not end with ?>"];
            mError = YES;
            return NO;
        }
        
        [mDelegate parser:self endElement:@"?xml"];
        return YES;
    }
    // <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    else if ([mScanner scanString:@"<!DOCTYPE" intoString:nil])
    {
        [mScanner scanUpToString:@">" intoString:nil];
        
        if (![mScanner scanString:@">" intoString:nil])
        {
            [mDelegate parser:self error:@"<!DOCTYPE does not end with >"];
            mError = YES;
            return NO;
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)parse
{
    mAbort = NO;
    mError = NO;
    
    mScanner = [[NSScanner alloc] initWithString:mString];
        
    while ([self scanHeader])
    {
        if (mAbort)
            return YES;
    }
    
    while ([self scanTag])
    {
        if (mAbort)
            return YES;
    }
    
    return !mError;
}

- (void)abort
{
    mAbort = YES;
}

- (BOOL)isAbort
{
    return mAbort;
}

@end
