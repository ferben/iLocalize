//
//  XLIFFImportPreviewOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class XLIFFImportSettings;
@class XMLImporter;

/**
 This operation parses the XLIFF file and assign to each of its file and string
 its corresponding FileController and StringController.
 */
@interface XLIFFImportPreviewOperation : Operation {
	XLIFFImportSettings *settings;
}

@property (strong) XLIFFImportSettings *settings;

// accessor for unit tests
- (XMLImporter*)parse:(NSError**)error;

@end
