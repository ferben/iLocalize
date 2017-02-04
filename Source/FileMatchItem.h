//
//  MultipleFileMatchItem.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class FileController;

@interface FileMatchItem : NSObject
{
    NSString        *mFile;
    NSArray         *mMatchingFileControllers;
    NSUInteger       mMatchingIndex;
    
    // For display only (used by pop-up menu)
    NSMutableArray  *mRelativePaths;
}

+ (id)itemWithFile:(NSString *)file matchingFileControllers:(NSArray *)controllers;

- (NSUInteger)numberOfMatchingFiles;
- (NSString *)file;
- (FileController *)matchingFileController;
- (NSArray *)matchingFiles;
- (void)setMatchingValue:(id)value;
- (id)matchingValue;

@end
