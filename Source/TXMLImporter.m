//
//  TXMLImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "TXMLImporter.h"


@implementation TXMLImporter

/* Sample file:
 
<?xml version="1.0" encoding="UTF-8"?>
<txml locale="en" targetlocale="fr" version="1.0" createdby="iLocalize 4" datatype="regexp">
  <skeleton>/Users/bovet/Test.app/Contents/Resources/English.lproj/Localizable.strings</skeleton>
  <translatable blockId="1">
    <segment segmentId="1">
      <source>Main Window</source>
      <target score="100">Fenetre &quot;principale&quot;</target>
    </segment>
  </translatable>
  <skeleton>/Users/bovet/Test.app/Contents/Resources/English.lproj/Another.strings</skeleton>
  <translatable blockId="2">
    <segment segmentId="1">
      <source>Choose</source>
      <target score="100">Choisir</target>
    </segment>
  </translatable>
  <skeleton>/Users/bovet/Test.app/Contents/Resources/English.lproj/Another.strings</skeleton>
  <translatable blockId="3">
    <segment segmentId="1">
      <source>Button to choose the file</source>
      <target score="100">Bouton pour choisir le fichier</target>
    </segment>
  </translatable>
</txml>
 
 */

- (NSArray*)readableExtensions
{
	return @[@"txml"];
}

- (BOOL)canImportGenericDocument:(NSURL*)url error:(NSError**)error
{
	// Try to find the type of file by parsing its content
	self.document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:error];	
	if(!self.document) {
		return NO;
	}
	
	NSArray *nodes = [self documentNodesForXPath:@"/txml" error:error];
	if(nodes.count > 0) {
		return YES;
	}		
	
	self.document = nil;
	
	return NO;
}


- (BOOL)parseSourceLanguage:(NSError**)error
{
	NSArray *nodes = [self documentNodesForXPath:@"/txml" error:error];
	if(nil == nodes || IS_ERROR(error)) {
		return NO;
	} 
	
	NSXMLElement *element = [nodes firstObject];
	self.sourceLanguage = [[element attributeForName:@"locale"] stringValue];
	return YES;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/txml" error:error];
	if(IS_ERROR(error)) {
		return NO;
	} 
	
	NSXMLElement *element = [nodes firstObject];
	self.targetLanguage = [[element attributeForName:@"targetlocale"] stringValue];
    if (!self.targetLanguage) {
        // Old way of writing the attribute name.
        self.targetLanguage = [[element attributeForName:@"targetLocale"] stringValue];        
    }
	return YES;
}

- (BOOL)parseDocument:(NSError**)error
{
	NSArray *nodes = [self.document nodesForXPath:@"/txml" error:error];
	if(IS_ERROR(error)) {
		return NO;
	} 
	
	NSXMLElement *element = [nodes firstObject];
	NSString *file = nil;
	for(NSXMLNode *node in [element children]) {
		if([[node name] isEqualToString:@"skeleton"]) {
			file = [self readElementContent:node];
		}
		if([[node name] isEqualToString:@"translatable"]) {
            // File element can be missing, in that case the translatable elements are not scoped by file.
//			if(!file) {
//				NSString *message = NSLocalizedString(@"Missing <skeleton> element before <translatable> element. This element is required and contains the relative path of the file.", @"TXML Importer");
//				if(error) {
//					*error = [Logger errorWithMessage:message];
//				}
//				return NO;
//			}
			NSArray *segments = [node nodesForXPath:@"segment" error:error];
			if(!segments || IS_ERROR(error)) {
				return NO;
			} 

			for(NSXMLElement *segment in segments) {
				NSString *source = [self readElementContent:[[segment elementsForName:@"source"] firstObject]];
				NSString *target = [self readElementContent:[[segment elementsForName:@"target"] firstObject]];
				[self addStringWithKey:nil base:source translation:target file:file];
			}
		}
	}
	
	return YES;
}

@end
