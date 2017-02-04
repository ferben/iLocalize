//
//  FMControllerStrings.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMController.h"

@interface FMControllerStrings : FMController
{
    NSMutableArray       *mStringControllers;
    
    NSMutableArray       *mCachedVisibleStringControllers;  // cache only
    NSMutableDictionary  *mCachedStringControllers;         // cache only
    
    // Statistics (not saved)
    NSUInteger            mNumberOfStrings;
    NSUInteger            mNumberOfTranslatedStrings;
    NSUInteger            mNumberOfNonTranslatedStrings;
    NSUInteger            mNumberOfToCheckStrings;
    NSUInteger            mNumberOfInvariantStrings;
    NSUInteger            mNumberOfBaseModifiedStrings;
    NSUInteger            mNumberOfLockedStrings;
    NSUInteger            mNumberOfAutoTranslatedStrings;
    int                   mNumberOfAutoInvariantStrings;
}

@end
