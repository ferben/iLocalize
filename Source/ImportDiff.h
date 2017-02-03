//
//  ImportDiff.h
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportDiffItem.h"

@interface ImportDiff : NSObject {
    NSString *source;
    
    // Array of ImportDiffItem objects.
    NSMutableArray *items;
}

@property (strong) NSString *source;

- (void)clear;

- (void)addFilesToAdd:(NSArray*)files;
- (void)addFilesToDelete:(NSArray*)files;
- (void)addFilesToUpdate:(NSArray*)files;
- (void)addFilesIdentical:(NSArray*)files;

- (NSArray*)allFilesToAdd;
- (NSArray*)allFilesToDelete;
- (NSArray*)allFilesToUpdate;
- (NSArray*)allFilesIdentical;

- (NSArray*)allExistingFiles;

/**
 Returns an array of ImportDiffItem objects.
 */
- (NSArray*)items;

@end
