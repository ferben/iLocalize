//
//  XMLStringsEngine.m
//  iLocalize
//
//  Created by Jean on 9/7/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "XMLStringsEngine.h"
#import "StringModel.h"
#import "StringsContentModel.h"
#import "Constants.h"

@implementation XMLStringsEngine

+ (BOOL)canHandleContent:(NSString*)c
{
	return [c hasPrefix:@"<?xml version=\"1.0\""];
}

- (id)init
{
	if(self = [super init]) {
		mModelClass = [StringModel class];
	}
	return self;
}


#pragma mark NSXMLParser Delegate

/*
 <plist version="1.0">
 <dict>
	<key> (%i of %i)</key>
	<string> (%1$i z %2$i)</string>
	<key> (Autoreply)</key>
	<string> (odpowiedź automatyczna)</string> 
 
 */

- (StringsContentModel*)parseText:(NSString*)text modelClass:(Class)c
{
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding]];
	mModelClass = c;
	[parser setDelegate:self];
	[parser parse];	
	return mEntries;
}

- (int)format
{
	return mFormat;
}

- (void)setKey:(NSString*)key
{
	mKey = key;
}

- (void)setValue:(NSString*)value
{
	mValue = value;
}

- (void)createEntry
{
	StringModel *sm = [[mModelClass alloc] init];
	[sm setKey:mKey as:STRING_XML atRow:-1];
	[sm setValue:mValue as:STRING_XML atRow:-1];
	[mEntries addStringModel:sm];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	mContentHeaders = 0;
	mParsingKey = NO;
	mParsingContent = NO;
	mFormat = STRINGS_FORMAT_APPLE_STRINGS;
	mEntries = [[StringsContentModel alloc] init];
}

- (NSString*)elementAtLevel:(int)level
{
	switch(mFormat) {
		case STRINGS_FORMAT_APPLE_XML:
			return level==0?@"plist":@"dict";
		case STRINGS_FORMAT_ABVENT_XML:
			return level==0?@"AbventLocalizableStrings":@"LocalizableString";
	}
	return nil;	
}

- (NSString*)keyElement
{
	switch(mFormat) {
		case STRINGS_FORMAT_APPLE_XML:
			return @"key";
		case STRINGS_FORMAT_ABVENT_XML:
			return @"ID";
	}
	return nil;	
}

- (NSString*)contentElement
{
	switch(mFormat) {
		case STRINGS_FORMAT_APPLE_XML:
			return @"string";
		case STRINGS_FORMAT_ABVENT_XML:
			return @"text";
	}
	return nil;	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
	qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"plist" ignoreCase:YES] && mFormat == 0) {
		mFormat = STRINGS_FORMAT_APPLE_XML;
	}
	if([elementName isEqualToString:@"AbventLocalizableStrings" ignoreCase:YES] && mFormat == 0) {
		mFormat = STRINGS_FORMAT_ABVENT_XML;
	}
		
	if([elementName isEqualToString:[self keyElement] ignoreCase:YES]) {
		mParsingKey = YES;
		mContent = [NSMutableString string];
	}		
	if([elementName isEqualToString:[self contentElement] ignoreCase:YES]) {
		mParsingContent = YES;
		mContent = [NSMutableString string];
	}		
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(mParsingKey || mParsingContent) {
		[mContent appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([elementName isEqualToString:[self keyElement] ignoreCase:YES]) {
		[self setKey:mContent];
		mContent = nil;
		mParsingKey = NO;			
	}		
	if([elementName isEqualToString:[self contentElement] ignoreCase:YES]) {
		[self setValue:mContent];
		[self createEntry];
		mContent = nil;
		mParsingContent = NO;
	}		
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"Parser error at line %ld and column %ld: %@", [parser lineNumber], [parser columnNumber], parseError);
}

@end
