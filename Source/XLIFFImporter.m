//
//  XLIFFImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImporter.h"


@implementation XLIFFImporter

/* Sample file:
 
 <?xml version="1.0"?>
 <xliff version="1.1">
 <file original="InfoPlist.strings" source-language="en" target-language="en" path="/Contents/Frameworks/libecw.framework/Versions/A/Resources/English.lproj/InfoPlist.strings">
 <body>
 <trans-unit id="CFBundleName">
 <source>image_lib</source>
 <target>image_lib</target>
 </trans-unit>
 <trans-unit id="CFBundleShortVersionString">
 <source>1.0</source>
 <target>1.0</target>
 </trans-unit>
 <trans-unit id="CFBundleGetInfoString">
 <source>image_lib version 1.0, Copyright 2004 __MyCompanyName__.</source>
 <target>image_lib version 1.0, Copyright 2004 __MyCompanyName__.</target>
 </trans-unit>
 </body>
 </file>
 </xliff>
 
 */

- (NSArray*)readableExtensions
{
	return @[@"xlf", @"xliff", @"xlif"];
}

- (BOOL)canImportGenericDocument:(NSURL*)url error:(NSError**)error
{
	// Try to find the type of file by parsing its content
	self.document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:error];
	if(!self.document) {
		return NO;
	}
	
	NSArray *nodes = [self documentNodesForXPath:@"/xliff" error:error];
	if(nodes.count > 0) {
		return YES;
	}
	
	self.document = nil;

	return NO;
}

- (BOOL)parseSourceLanguage:(NSError**)error
{
	NSArray *nodes = [self documentNodesForXPath:@"/xliff/file" error:error];
//	if(nil == nodes || IS_ERROR(error)) {
//		return NO;
//	} 
	
	NSXMLElement *element = [nodes firstObject];
	self.sourceLanguage = [[element attributeForName:@"source-language"] stringValue];
	return YES;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/xliff/file" error:error];
//	if(IS_ERROR(error)) {
//		return NO;
//	} 
	
	NSXMLElement *element = [nodes firstObject];
	self.targetLanguage = [[element attributeForName:@"target-language"] stringValue];
	return YES;
}

- (BOOL)parseDocument:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/xliff/file" error:error];
//	if(IS_ERROR(error)) {
//		return NO;
//	} 
	
	for(NSXMLElement *fileElement in nodes) {
		NSString *file = [[fileElement attributeForName:@"path"] stringValue];
		NSArray *transUnitList = [fileElement nodesForXPath:@"body/trans-unit" error:error];
		if(IS_ERROR(error)) {
			return NO;
		} 
		for(NSXMLElement *transUnitElement in transUnitList) {
            NSString *key = [[transUnitElement attributeForName:@"resname"] stringValue];
			NSString *source = [self readElementContent:[[transUnitElement elementsForName:@"source"] firstObject]];
			NSString *target = [self readElementContent:[[transUnitElement elementsForName:@"target"] firstObject]];
			[self addStringWithKey:key base:source translation:target file:file];
		}
	}	
	
	return YES;
}

@end
