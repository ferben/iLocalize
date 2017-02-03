//
//  ProjectController.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractController.h"

@class LanguageController;
@class FileController;

@class StringModel;
@class ProjectProvider;
@class ExplorerItem;
@class DirtyContext;

@interface ProjectController : AbstractController
{
    NSMutableArray        *mLanguageControllers;

    // Temporary state (not saved)
    NSInteger           mCurrentLanguageIndex;
    BOOL                mDirtyEnable;
    DirtyContext        *dirtyContext;
    NSInteger            dirtyCount;
    BOOL                markDirty;
}

@property (weak) id<ProjectProvider> projectProvider;

- (void)setDirtyEnable:(BOOL)flag;
- (void)notifyDirty;

- (void)addLanguageController:(LanguageController *)languageController;
- (void)removeLanguageController:(LanguageController *)languageController;

- (void)setCurrentLanguageIndex:(NSInteger)index;
- (NSInteger)currentLanguageIndex;

- (void)languagesDidChange;
- (void)baseStringModelDidChange:(StringModel *)model fileController:(FileController *)fc;

- (BOOL)isLanguageExisting:(NSString *)language;
- (NSString *)baseLanguage;
- (NSMutableArray *)languages;
- (NSArray *)displayLanguages;

- (LanguageController *)baseLanguageController;
- (NSMutableArray *)languageControllers;
- (LanguageController *)languageControllerForLanguage:(NSString *)language;

- (FileController *)correspondingBaseFileControllerForFileController:(FileController *)fileController;

- (NSString *)relativePathForSmartPath:(NSString *)smartPath language:(NSString *)language;
- (NSString *)relativeBaseLanguagePathForSmartPath:(NSString *)smartPath;
- (NSArray *)smartPaths;

- (NSArray *)needsToBeSavedFileControllers;
- (NSArray *)needsToBeReloadedFileControllers;

@end
