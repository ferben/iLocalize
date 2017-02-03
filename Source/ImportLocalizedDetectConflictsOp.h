//
//  ImportLocalizedDetectConflictsOp.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

/**
 This operation detects any conflicts when updating the localized languages.
 */
@interface ImportLocalizedDetectConflictsOp : Operation {
    // Either there is a list of FileConflictItem
    NSArray *fileConflictItems;
    
    // Or there is a list of language and the localized bundle
    NSArray *languages;
    NSString *localizedBundle;
    
    // Array of conflicting file items
    NSMutableArray *conflictingFileItems;
}

@property (strong) NSArray *fileConflictItems;
@property (strong) NSArray *languages;
@property (strong) NSString *localizedBundle;

/**
 Returns an array of FileConflictItem objects.
 */
- (NSArray*)conflictingFileItems;

@end
