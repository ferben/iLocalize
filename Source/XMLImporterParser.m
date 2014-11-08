//
//  XMLImporterParser.m
//  iLocalize
//
//  Created by Jean Bovet on 4/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLImporterParser.h"
#import "Stack.h"

@implementation XMLImporterParser

@synthesize startElementCallback;
@synthesize endElementCallback;
@synthesize errorElementCallback;

- (id) init
{
	self = [super init];
	if (self != nil) {
		elements = [[Stack alloc] init];
		textContent = nil;
	}
	return self;
}


- (BOOL)parseURL:(NSURL*)url
{
	[elements clear];
	aborted = NO;
	textContent = nil;
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[parser setDelegate:self];
	BOOL success = [parser parse];
	parser = nil;
	return success;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
	[elements pushObject:elementName];
	if(startElementCallback && !startElementCallback(elements, attributeDict)) {
		aborted = YES;
		[parser abortParsing];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if(endElementCallback && !endElementCallback(elements, [textContent copy])) {
		aborted = YES;
		[parser abortParsing];
	}	
	[elements popObject];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	if(aborted) return;
	
	NSString *description = [[parser parserError] localizedDescription];
	if(!description) {
		switch ([parseError code]) {
			case NSXMLParserInvalidCharacterError:
				description = @"Invalid character detected";
				break;
		}
	}
	NSString *message = [NSString stringWithFormat:@"Error %ld, Description: %@, Line: %ld, Column: %ld", [parseError code],
						 description, [parser lineNumber], [parser columnNumber]];
	NSError *completeError = [Logger errorWithMessage:message];
	
	if(errorElementCallback) errorElementCallback(completeError);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[textContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
	[textContent appendString:whitespaceString];	
}

- (void)setParseText:(BOOL)flag
{
	textContent = nil;
	if(flag) {
		textContent = [[NSMutableString alloc] init];
	}
}

@end
