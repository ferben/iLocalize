//
//  XMLParser.h
//  Tests
//
//  Created by Jean on 9/3/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#define INFO_START_LOCATION @"start"
#define INFO_END_LOCATION @"end"

@class XMLParser;

@protocol XMLParserDelegate

- (void)parser:(XMLParser *)parser beginElement:(NSString *)name;
- (void)parser:(XMLParser *)parser endElement:(NSString *)name;
- (void)parser:(XMLParser *)parser element:(NSString *)element attributeName:(NSString *)name content:(NSString *)content info:(id)info;
- (void)parser:(XMLParser *)parser content:(NSString *)content;
- (void)parser:(XMLParser *)parser comment:(NSString *)comment;
- (void)parser:(XMLParser *)parser error:(NSString *)reason;

@end

@interface XMLParser : NSObject
{
	id<XMLParserDelegate> mDelegate;
	NSString *mString;
	NSScanner *mScanner;
	NSMutableCharacterSet *mIdentifierSet;
    NSCharacterSet *mQuotesSet;
	BOOL mError;
	BOOL mAbort;
}

+ (void)parseString:(NSString *)string;
+ (void)parseFile:(NSString *)file;
- (void)setString:(NSString *)string;
- (void)setDelegate:(id<XMLParserDelegate>)delegate;
- (BOOL)parse;
- (void)abort;
- (BOOL)isAbort;

@end
