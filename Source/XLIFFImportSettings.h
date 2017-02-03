//
//  XLIFFImportSettings.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@interface XLIFFImportSettings : NSObject
{
	// XLIFF file to import
	NSString *file;
	
	// Files to apply the XLIFF to.
	NSArray *targetFiles;
	
	// An array of XMLImportFileElement
	NSArray *fileElements;
    
    // Use the xliff "resname" instead of the source to match the translations
    BOOL useResnameInsteadOfSource;
}

@property (strong) NSString *file;
@property (strong) NSArray *targetFiles;
@property (strong) NSArray *fileElements;
@property (nonatomic) BOOL useResnameInsteadOfSource;

- (void)setData:(NSDictionary *)data;
- (NSDictionary *)data;

@end
