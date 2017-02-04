//
//  ImportEngine.h
//  iLocalize3
//
//  Created by Jean on 14.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Operation.h"

@interface ImportLanguagesOp : Operation
{
    NSArray   *languages;
    BOOL       identical;
    BOOL       layouts;
    BOOL       copyOnlyIfExists;
    NSString  *sourcePath;
}

@property (strong) NSArray *languages;
@property BOOL identical;
@property BOOL layouts;
@property BOOL copyOnlyIfExists;
@property (strong) NSString *sourcePath;

/**
 Exposed here because it is used by the ImportFilesLocalizedOp operation.
 */
- (void)updateFileControllers:(NSArray *)fileControllers layout:(BOOL)layout usingCorrespondingFiles:(NSArray *)files resolveConflict:(BOOL)resolveConflict;

@end
