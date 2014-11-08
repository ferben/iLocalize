//
//  RebaseEngineDiff.h
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ProjectController;
@class ImportDiff;
@class BundleSource;

@interface ImportBundlePreviewOp : Operation {
    NSMutableArray      *mFilesToAdd;
    NSMutableArray      *mFilesToUpdate;
    NSMutableArray      *mFilesToDelete;
    NSMutableArray      *mFilesIdentical;
    
    BundleSource        *sourcePath;
	ImportDiff          *importDiff;
}

@property (strong) ImportDiff *importDiff;
@property (strong) BundleSource *sourcePath;

- (BOOL)needsToRebase;

// Exposed for Unit Testing
- (NSArray*)filesToAdd;
- (NSArray*)filesToUpdate;
- (NSArray*)filesToDelete;
- (NSArray*)filesIdentical;

@end

