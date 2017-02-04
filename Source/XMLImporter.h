//
//  XMLImporter.h
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "StringControllerProtocol.h"
#import "SEIConstants.h"
#import "AZXMLParser.h"

@class AZOrderedDictionary;
@class SEIFormat;

@interface XMLImporter : NSObject
{
    SEI_FORMAT            format;
    NSXMLDocument        *document;
    NSString             *sourceLanguage;
    NSString             *targetLanguage;
    
    /**
     Dictionary of array of XMLImporterElement. Each key in the dictionary identifies one file.
     */
    AZOrderedDictionary  *elementsPerFile;
    
    /**
     Array of XMLImporterElement that do not belong to a file.
     */
    NSMutableArray       *elementsWithoutFile;
    
    // Internal flag indicating that the XML parser failed
    // for a unknown reason (see ?) and that we should retry
    // to re-initialize the document at least one time.
    BOOL                _internalParsingErrorRetry;
}

@property SEI_FORMAT format;

@property (nonatomic) BOOL useFastXMLParser;
@property (nonatomic, strong) AZXMLParser *azXMLParser;

@property (strong) NSXMLDocument *document;
@property (strong) NSString *sourceLanguage;
@property (strong) NSString *targetLanguage;
@property (strong) AZOrderedDictionary *elementsPerFile;
@property (strong) NSMutableArray *elementsWithoutFile;

/**
 Returns a new instance.
 */
+ (XMLImporter *)importer;

/**
 Array of extensions that are generic (e.g. xml). The importer will need to parse the document
 to determine if it supports the document.
 */
- (NSArray *)genericExtensions;

/**
 Returns an array of extensions this importer recognizes.
 */
- (NSArray *)readableExtensions;

/**
 Returns true if the document can be imported.
 */
- (BOOL)canImportDocument:(NSURL *)url error:(NSError **)error;

/**
 Main entry point to import a document.
 */
- (BOOL)importDocument:(NSURL *)url error:(NSError **)error;

/**
 Returns an array of all the elements in this importer, regardless if they 
 are scoped by file or not.
 */
- (NSArray *)allElements;

/**
 Returns the element text content.
 */
- (NSString *)readElementContent:(NSXMLNode *)element;

/**
 Adds a string to the specified file.
 @param key The key (only defined in some format, such as xliff). Otherwise nil.
 @param base The base string
 @param translation The target string
 @param file The relative path of the file that contains this string or null if the string doesn't belong to a file (glossary)
 */
- (void)addStringWithKey:(NSString *)key base:(NSString *)base translation:(NSString *)translation file:(NSString *)file;

/**
 Returns the nodes found at the xpath query. This is a convenient
 method that takes care of retrying in case there is an error
 with the NSXMLDocument parsing
 */
- (NSArray *)documentNodesForXPath:(NSString *)xpath error:(NSError **)error;

// For subclasses

- (BOOL)parseSourceLanguage:(NSError **)error;
- (BOOL)parseTargetLanguage:(NSError **)error;
- (BOOL)parseDocument:(NSError **)error;

@end
