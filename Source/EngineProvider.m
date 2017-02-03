//
//  EngineProvider.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "EngineProvider.h"

#import "ResourceFileEngine.h"

#import "ModelEngine.h"

#import "LanguageEngine.h"
#import "FileEngine.h"

#import "SynchronizeEngine.h"
#import "ReplaceEngine.h"
#import "ImportLanguagesOp.h"

#import "NewProjectOperation.h"
#import "ImportRebaseBundleOp.h"

#import "OptimizeEngine.h"

#ifndef TARGET_TOOL
#import "FindEngine.h"
#endif
#import "CleanEngine.h"
#import "CheckEngine.h"

@interface EngineProvider (PrivateMethods)
- (void)createEngines;
- (void)linkEngines;
@end

@implementation EngineProvider

- (id)init
{
    if(self = [super init]) {
        [self createEngines];
        [self linkEngines];
    }
    return self;
}


- (void)createEngines
{
    mResourceFileEngine    = [[ResourceFileEngine alloc] init];
        
    mModelEngine = [[ModelEngine alloc] init];

    mLanguageEngine = [[LanguageEngine alloc] init];
    mFileEngine = [[FileEngine alloc] init];

    mSynchronizeEngine = [[SynchronizeEngine alloc] init];
    mReplaceEngine = [[ReplaceEngine alloc] init];

    mOptimizeEngine = [[OptimizeEngine alloc] init];

#ifndef TARGET_TOOL
    mFindEngine = [[FindEngine alloc] init];
#endif
    mCleanEngine = [[CleanEngine alloc] init];
    mCheckEngine = [[CheckEngine alloc] init];
}

- (void)linkEngines
{
    [mResourceFileEngine setEngineProvider:self];
    
    [mModelEngine setEngineProvider:self];

    [mLanguageEngine setEngineProvider:self];
    [mFileEngine setEngineProvider:self];
    
    [mSynchronizeEngine setEngineProvider:self];
    [mReplaceEngine setEngineProvider:self];
        
    [mOptimizeEngine setEngineProvider:self];

#ifndef TARGET_TOOL
    [mFindEngine setEngineProvider:self];
#endif
    [mCleanEngine setEngineProvider:self];
    [mCheckEngine setEngineProvider:self];
}

- (ResourceFileEngine*)resourceFileEngine
{
    return mResourceFileEngine;
}

- (ModelEngine*)modelEngine
{
    return mModelEngine;
}

- (LanguageEngine*)languageEngine
{
    return mLanguageEngine;
}

- (FileEngine*)fileEngine
{
    return mFileEngine;
}

- (SynchronizeEngine*)synchronizeEngine
{
    return mSynchronizeEngine;
}

- (ReplaceEngine*)replaceEngine
{
    return mReplaceEngine;
}

- (OptimizeEngine*)optimizeEngine
{
    return mOptimizeEngine;
}

#ifndef TARGET_TOOL
- (FindEngine*)findEngine
{
    return mFindEngine;
}
#endif

- (CleanEngine*)cleanEngine
{
    return mCleanEngine;
}

- (CheckEngine*)checkEngine
{
    return mCheckEngine;
}

@end
