//
//  RebaseEngine.h
//  iLocalize3
//
//  Created by Jean on 07.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ProjectController;
@class FileController;
@class ImportDiff;

/**
 This operation perform a rebase of the project using
 the specified bundle and the specified differences.
 */
@interface ImportRebaseBundleOp : Operation {
    NSString        *mHistoryFilePath;
    BOOL            mUsePreviousLayout;
    ImportDiff      *mImportDiff;
}

@property BOOL usePreviousLayout;
@property (strong) ImportDiff *importDiff;

/**
 This method is exposed because it is also used by the ImportFilesBaseLanguageOp
 */
- (void)rebaseFileControllers:(NSArray*)fileControllers usingCorrespondingFiles:(NSArray*)files;

/**
 This method rebases an array of base file controllers. It is used by other classes which
 is why it is exposed here.
 */
- (void)rebaseBaseFileControllers:(NSArray*)fileControllers keepLayout:(BOOL)layout;

@end
