//
//  MultipleFileMatchItem.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileMatchItem.h"
#import "FileController.h"

@implementation FileMatchItem

- (id)initWithFile:(NSString *)file matchingFileControllers:(NSArray *)controllers
{
    if (self = [super init])
    {
        mFile = file;
        mMatchingFileControllers = controllers;
        mMatchingIndex = 0;
        
        mRelativePaths = [[NSMutableArray alloc] init];
        
        FileController *fileController;
        
        for (fileController in mMatchingFileControllers)
        {
            [mRelativePaths addObject:[fileController relativeFilePath]];
        }                    
    }
    
    return self;
}


+ (id)itemWithFile:(NSString *)file matchingFileControllers:(NSArray *)controllers
{
    return [[FileMatchItem alloc] initWithFile:file matchingFileControllers:controllers];
}

- (NSUInteger)numberOfMatchingFiles
{
    return [mMatchingFileControllers count];
}

- (NSString *)file
{
    return mFile;
}

- (FileController *)matchingFileController
{
    return mMatchingFileControllers[mMatchingIndex];
}

- (NSArray *)matchingFiles
{
    return mRelativePaths;
}

- (void)setMatchingValue:(id)value
{
    mMatchingIndex = [value integerValue];
}

- (id)matchingValue
{
    return @(mMatchingIndex);
}

@end
