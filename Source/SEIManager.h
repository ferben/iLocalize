//
//  SEIManager.h
//  iLocalize
//
//  Created by Jean Bovet on 4/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIConstants.h"

@class XMLImporter;
@class XMLExporter;

@interface SEIManager : NSObject {
    NSMutableArray *formats;
}

+ (SEIManager*)sharedInstance;

- (void)populatePopup:(NSPopUpButton*)popup;
- (void)selectPopup:(NSPopUpButton*)popup itemForFormat:(SEI_FORMAT)format;
- (SEI_FORMAT)selectedFormat:(NSPopUpButton*)popup;
- (NSString*)writableExtensionForFormat:(SEI_FORMAT)format;

/**
 Returns all the importable extensions.
 */
- (NSArray*)allImportableExtensions;

/**
 Returns the format corresponding to the doc type.
 */
- (SEI_FORMAT)formatOfDocType:(NSString*)docType defaultFormat:(SEI_FORMAT)defaultFormat;

/**
 Returns the format of the given file.
 */
- (SEI_FORMAT)formatOfFile:(NSURL*)url error:(NSError**)error;

/**
 Returns the proper importer for the given file type.
 */
- (XMLImporter*)importerForFile:(NSURL*)url error:(NSError**)error;

/**
 Returns the proper exporter for the given format.
 */
- (XMLExporter*)exporterForFormat:(SEI_FORMAT)format;

@end
