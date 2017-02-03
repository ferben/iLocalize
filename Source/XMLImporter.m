//
//  XMLImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLImporter.h"
#import "XMLImporterElement.h"
#import "AZOrderedDictionary.h"

@implementation XMLImporter

@synthesize format;
@synthesize document;
@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize elementsPerFile;
@synthesize elementsWithoutFile;

+ (XMLImporter*)importer
{
    return [[self alloc] init];
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        _internalParsingErrorRetry = NO;
        self.elementsPerFile = [[AZOrderedDictionary alloc] init];
        self.elementsWithoutFile = [NSMutableArray array];
    }
    return self;
}


- (void)addStringWithKey:(NSString*)key base:(NSString*)base translation:(NSString*)translation file:(NSString*)file
{
    if(!base) return;
    
    if(!translation) {
        translation = base;
    }
    
    XMLImporterElement *element = [[XMLImporterElement alloc] init];
    element.file = file.length>0?file:nil;
    element.key = key;
    element.source = base;
    element.translation = translation;
    if(file.length>0) {
        NSMutableArray *elements = [self.elementsPerFile objectForKey:file];
        if(!elements) {
            elements = [NSMutableArray array];
            [self.elementsPerFile setObject:elements forKey:file];
        }
        [elements addObject:element];
    } else {
        [self.elementsWithoutFile addObject:element];
    }

}

- (NSString*)readElementContent:(NSXMLNode*)element
{
    if(!element) return nil;
    
    NSMutableString *content = [NSMutableString string];
    int i;
    for(i=0;i<[element childCount];i++) {
        NSXMLNode *c = [element childAtIndex:i];
        switch (c.kind) {
            case NSXMLTextKind:
                [content appendString:[c stringValue]];
                break;
                
            case NSXMLElementKind:
                [content appendString:[self readElementContent:c]];
                break;
                
            default:
                break;
        }
    }
    return content;
}

- (NSArray*)genericExtensions
{
    return @[@"xml"];
}

- (NSArray*)readableExtensions
{
    return nil;
}

- (BOOL)canImportGenericDocument:(NSURL*)url error:(NSError**)error
{
    // subclass can customize
    return NO;
}

- (BOOL)canImportDocument:(NSURL*)url error:(NSError**)error
{
    BOOL can = NO;
    NSString *extension = [[url path] pathExtension];
    if([[self readableExtensions] containsObject:extension]) {
        can = YES;
    } else if([[self genericExtensions] containsObject:extension]) {
        can = [self canImportGenericDocument:url error:error];
    }
    return can;
}

- (BOOL)importDocument:(NSURL*)url error:(NSError**)error
{
    NSUInteger retryCount = 2;
retry:
    retryCount--;
    self.document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:error];
    if(!self.document) {
        return NO;
    }
    
    _internalParsingErrorRetry = NO;
    if(![self parseSourceLanguage:error]) {
        if (_internalParsingErrorRetry && retryCount > 0) {
            NSLog(@"Internal parsing error for %@, retrying one time...", url);
            goto retry;
        }
        if(error && !*error) {
            *error = [Logger errorWithMessage:NSLocalizedString(@"Unable to find the source language", @"XML Importer")];
        }
        return NO;
    }
    
    if(![self parseTargetLanguage:error]) {
        if(error && !*error) {
            *error = [Logger errorWithMessage:NSLocalizedString(@"Unable to find the target language", @"XML Importer")];
        }
        return NO;
    }
    
    if(![self parseDocument:error]) {
        return NO;
    }
    
    return YES;
}

- (NSArray*)allElements
{
    NSMutableArray *elements = [NSMutableArray array];
    for(NSArray *e in [elementsPerFile allValues]) {
        [elements addObjectsFromArray:e];        
    }
    [elements addObjectsFromArray:elementsWithoutFile];
    return elements;
}

- (NSArray*)documentNodesForXPath:(NSString*)xpath error:(NSError**)error {
    NSError *err = nil;
    NSArray *nodes = [self.document nodesForXPath:xpath error:&err];
    if (nil == nodes && nil == err) {
        NSLog(@"Internal xpath evaluation error with NSXMLDocument: `%@` for file `%@`", xpath, self.document.URI);
        _internalParsingErrorRetry = YES;
    }
    if (err && *error) {
        *error = err;
    }
    return nodes;
}

#pragma mark Subclass

- (BOOL)parseSourceLanguage:(NSError**)error
{
    return NO;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
    return NO;
}

- (BOOL)parseDocument:(NSError**)error
{
    return NO;
}

@end
