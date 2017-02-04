//
//  AnalyzeBundleOp.h
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

#define PROBLEM_COMPILE_NIBS     @"PROBLEM_COMPILE_NIBS"
#define PROBLEM_OUTSIDE_NIBS     @"PROBLEM_OUTSIDE_NIBS"
#define PROBLEM_DUPLICATE_FILES  @"PROBLEM_DUPLICATE_FILES"
#define PROBLEM_READONLY_FILES   @"PROBLEM_READONLY_FILES"

@class AZPathNode;

@interface AnalyzeBundleOp : Operation
{
    AZPathNode           *node;
    NSArray              *files;
    
    NSMutableArray       *mProblems;
    NSMutableArray       *mOutsideNibs;
    NSMutableArray       *mCompiledNibs;
    NSMutableArray       *mDuplicateFiles;
    NSMutableArray       *mReadOnlyFiles;
    NSMutableDictionary  *mVisitedLanguages;
}

/**
 Set this property to analyze a bundle.
 */
@property (strong) AZPathNode *node;

/**
 Set this property to analyze an array of files.
 */
@property (strong) NSArray *files;

- (BOOL)hasProblems;
- (NSArray *)problems;

@end
