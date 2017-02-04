//
//  EngineProvider.h
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class ResourceFileEngine;
@class ModelEngine;
@class LanguageEngine;
@class FileEngine;
@class SynchronizeEngine;
@class ReplaceEngine;
@class OptimizeEngine;
@class FindEngine;
@class CleanEngine;
@class CheckEngine;

@interface EngineProvider : NSObject
{
    ResourceFileEngine  *mResourceFileEngine;
        
    ModelEngine         *mModelEngine;
    
    LanguageEngine      *mLanguageEngine;
    FileEngine          *mFileEngine;
    
    SynchronizeEngine   *mSynchronizeEngine;
    ReplaceEngine       *mReplaceEngine;
    
    OptimizeEngine      *mOptimizeEngine;
    
    FindEngine          *mFindEngine;
    CleanEngine         *mCleanEngine;
    CheckEngine         *mCheckEngine;
}

@property (weak) id<ProjectProvider> projectProvider;

- (ResourceFileEngine *)resourceFileEngine;

- (ModelEngine *)modelEngine;

- (LanguageEngine *)languageEngine;
- (FileEngine *)fileEngine;

- (SynchronizeEngine *)synchronizeEngine;
- (ReplaceEngine *)replaceEngine;

- (OptimizeEngine *)optimizeEngine;

#ifndef TARGET_TOOL
- (FindEngine *)findEngine;
#endif

- (CleanEngine *)cleanEngine;
- (CheckEngine *)checkEngine;

@end
