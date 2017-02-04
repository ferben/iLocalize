//
//  GlossaryTranslator.h
//  iLocalize3
//
//  Created by Jean on 27.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class StringController;
@class OperationWC;
@class LanguageController;

@interface GlossaryTranslator : NSObject
{
    OperationWC          *mOperation;
    LanguageController   *mLanguageController;
    
    NSMutableDictionary  *mCachedRootString;       // cache
    NSMutableDictionary  *mCachedRemainingString;  // cache
    
    BOOL                  mIgnoreCase;
    int                   mMaxCount;
    int                   mCurrentCount;
}

+ (GlossaryTranslator *)translator;

- (void)setIgnoreCase:(BOOL)flag;
- (void)setLanguageController:(LanguageController *)lc;

- (void)translateStringControllers:(NSArray *)scs withString:(NSString *)string base:(NSString *)base;
- (void)translateFileControllers:(NSArray *)fcs withString:(NSString *)string base:(NSString *)base;

- (void)translateStringControllers:(NSArray *)scs withGlossaries:(NSArray *)glossaries;
- (void)translateFileControllers:(NSArray *)fcs withGlossaries:(NSArray *)glossaries;

@end
