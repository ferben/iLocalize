//
//  ILGImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ILGImporter.h"


@implementation ILGImporter

/* Sample file:
 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>displaySourceLanguage</key>
	<string>English</string>
	<key>displayTargetLanguage</key>
	<string>Swedish</string>
	<key>entries</key>
	<array>
		<dict>
			<key>source</key>
			<string>hdhomerun2</string>
			<key>target</key>
			<string>hdhomerun3</string>
		</dict>
		<dict>
			<key>source</key>
			<string>EyeTVImporter version 1.0, Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
			<key>target</key>
			<string>EyeTVImporter version 1.0, Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
		</dict>
		<dict>
			<key>source</key>
			<string>Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
			<key>target</key>
			<string>Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
		</dict>
	</array>
	<key>sourceLanguage</key>
	<string>English</string>
	<key>targetLanguage</key>
	<string>sv</string>
</dict>
</plist>
 
 */

- (NSArray*)readableExtensions
{
	return @[@"ilg"];
}

- (BOOL)parseSourceLanguage:(NSError**)error
{
	NSArray *nodes = [self documentNodesForXPath:@"/plist/dict" error:error];
	if(nil == nodes || IS_ERROR(error)) {
		return NO;
	} 
	
	// Get the nodes under dict
	nodes = [[nodes firstObject] children];
	for(int index=0; index<nodes.count; index++ ) {
		NSXMLNode *node = nodes[index];
		if([[node name] isEqual:@"key"] && [[self readElementContent:node] isEqual:@"sourceLanguage"]) {
			NSXMLNode *nextNode = nodes[index+1];
			self.sourceLanguage = [[self readElementContent:nextNode] isoLanguage];
			break;
		}
	}
	return self.sourceLanguage != nil;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/plist/dict" error:error];
	if(IS_ERROR(error)) {
		return NO;
	} 
	
	// Get the nodes under dict
	nodes = [[nodes firstObject] children];
	for(int index=0; index<nodes.count; index++ ) {
		NSXMLNode *node = nodes[index];
		if([[node name] isEqual:@"key"] && [[self readElementContent:node] isEqual:@"targetLanguage"]) {
			NSXMLNode *nextNode = nodes[index+1];
			self.targetLanguage = [[self readElementContent:nextNode] isoLanguage];
			break;
		}
	}
	return self.targetLanguage != nil;
}

- (BOOL)parseDocument:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/plist/dict/array" error:error];
	if(IS_ERROR(error)) {
		return NO;
	} 
	
	// Get the nodes under array: dict nodes
	NSArray *dictNodes = [[nodes firstObject] children];
	for(NSXMLNode *dictNode in dictNodes) {
		NSArray *contentNodes = [dictNode children];
		NSString *source = nil;
		NSString *target = nil;
		for(int index=0; index<contentNodes.count; index++ ) {
			NSXMLNode *node = contentNodes[index];
			if([[node name] isEqual:@"key"] && [[self readElementContent:node] isEqual:@"source"]) {
				NSXMLNode *nextNode = contentNodes[index+1];
				source = [self readElementContent:nextNode];
			}
			if([[node name] isEqual:@"key"] && [[self readElementContent:node] isEqual:@"target"]) {
				NSXMLNode *nextNode = contentNodes[index+1];
				target = [self readElementContent:nextNode];
			}
		}	
		[self addStringWithKey:nil base:source translation:target file:nil];
	}
		
	return YES;
}

@end
