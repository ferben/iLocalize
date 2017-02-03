//
//  GlossaryFolderDiff.h
//  iLocalize
//
//  Created by Jean Bovet on 4/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class GlossaryFolder;
@class GlossaryNotification;

/**
 Class that can analyze the content of a folder and do a diff
 with the in-memory content of that folder.
 */
@interface GlossaryFolderDiff : NSObject {
    // The disk representation of the glossaries
    NSMutableDictionary *diskGlossaries;

    // The various files
    NSMutableArray *newFiles;
    NSMutableArray *modifiedFiles;
    NSMutableArray *unmodifiedFiles;
    NSMutableArray *deletedFiles;
    
    NSArray *allowedExtensions;
}

@property (strong) NSArray *allowedExtensions;

+ (GlossaryFolderDiff*)diffWithAllowedExtensions:(NSArray*)allowedExtensions;

/**
 Returns a dictionary of url=>ILGlossary that are located in the folder, up to 3 level deep.
 */
- (NSDictionary*)glossariesInFolder:(GlossaryFolder*)folder;

/**
 Analyzes a folder and returns the number of items that are going to be
 applied to the folder.
 */
- (NSUInteger)analyzeFolder:(GlossaryFolder*)folder;

/**
 Applies to the folder the previous analyze results.
 @param callback will be invoked as many times as the number returned by analyzeFolder
 */
- (GlossaryNotification*)applyToFolder:(GlossaryFolder*)folder callback:(CancellableCallbackBlock)callback;

@end
