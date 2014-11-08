//
//  SEIFormat.h
//  iLocalize
//
//  Created by Jean Bovet on 4/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIConstants.h"
#import "XMLImporter.h"
#import "XMLExporter.h"

@interface SEIFormat : NSObject {
	/**
	 Format ID.
	 */
	SEI_FORMAT format;
	
	/**
	 Display name of the format. E.g. ILG (iLocalize Glossary)
	 */
	NSString *displayName;

	/**
	 Name of the importer class.
	 */
	NSString *importerClassName;

	/**
	 Name of the exporter class.
	 */
	NSString *exporterClassName;
	
	/**
	 Array of extensions that identifies this format.
	 */
	NSArray *readableExtensions;
	
	/**
	 Extension to use when writing this format to a file.
	 */
	NSString *writableExtension;
}

@property SEI_FORMAT format;
@property (strong) NSString *displayName;
@property (strong) NSString *importerClassName;
@property (strong) NSString *exporterClassName;
@property (strong) NSArray *readableExtensions;
@property (strong) NSString *writableExtension;

- (XMLImporter*)createImporter;
- (XMLExporter*)createExporter;

- (BOOL)writable;

@end
