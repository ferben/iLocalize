//
//  XMLImportStringElement.h
//  iLocalize
//
//  Created by Jean Bovet on 4/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class StringController;

/**
 String to import.
 */
@interface XLIFFImportStringElement : NSObject {
	StringController *sc;
	NSString *translation;
}
@property (strong) StringController *sc;
@property (strong) NSString *translation;
@end
