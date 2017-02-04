//
//  XLIFFExportSettings.h
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIConstants.h"

@interface XLIFFExportSettings : NSObject
{
    // The files to export, this is an array of FileController
    NSArray     *files;
    
    // The format
    SEI_FORMAT   format;
    
    // The source language
    NSString    *sourceLanguage;
    
    // The target language
    NSString    *targetLanguage;
    
    // The xliff file that must be generated
    NSString    *targetFile;
}

@property (strong) NSArray *files;
@property SEI_FORMAT format;
@property (strong) NSString *sourceLanguage;
@property (strong) NSString *targetLanguage;
@property (strong) NSString *targetFile;

- (void)setData:(NSDictionary *)data;
- (NSDictionary *)data;

@end
