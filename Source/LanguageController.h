//
//  LanguageController.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractController.h"

@class FileController;
@class LanguageModel;
@class FileModel;
@class StringModel;

@interface LanguageController : AbstractController {
	LanguageModel		*mBaseLanguageModel;
	LanguageModel		*mLanguageModel;
	
	NSMutableArray		*mFileControllers;

	// volatile
	NSMutableDictionary	*mPath2FC;
	
	// Statistics (not saved)
	unsigned			mNumberOfFilteredFileControllers;
	unsigned			mNumberOfFoundFileControllers;
    unsigned            mTotalNumberOfStrings;
    unsigned            mNumberOfTranslatedStrings;
    unsigned            mNumberOfUntranslatedStrings;
	unsigned			mNumberOfToCheckStrings;
	float				mPercentCompleted;
	BOOL				mFilterShowLocalFiles;
}

- (void)setBaseLanguageModel:(LanguageModel*)model;
- (LanguageModel*)baseLanguageModel;

- (void)setLanguageModel:(LanguageModel*)model;
- (LanguageModel*)languageModel;

- (void)addToCache:(FileController*)fc;
- (void)removeFromCache:(FileController*)fc;

- (void)setFilterShowLocalFiles:(BOOL)flag;

- (void)addFileController:(FileController*)fileController;
- (void)deleteFileController:(FileController*)fileController removeFromDisk:(BOOL)removeFromDisk;

- (void)fileControllersDidChange;
- (void)filteredFileControllersDidChange;
- (void)baseStringModelDidChange:(StringModel*)model fileController:(FileController*)fc;

- (BOOL)isBaseLanguage;
- (NSString*)baseLanguage;
- (NSString*)displayBaseLanguage;

- (NSString*)language;
- (NSString*)displayLanguage;

- (int)totalNumberOfStrings;
- (int)totalNumberOfTranslatedStrings;
- (int)totalNumberOfNonTranslatedStrings;
- (int)totalNumberOfToCheckStrings;

- (float)percentCompleted;
- (NSString*)percentCompletedString;

- (int)numberOfFileControllers;
- (NSArray*)fileControllers;
- (NSArray*)filteredFileControllers;
- (NSImage*)allWarningsImage;

- (FileController*)fileControllerWithFileModel:(FileModel*)fileModel;
- (FileController*)fileControllerWithRelativePath:(NSString*)relativePath translate:(BOOL)translate;
- (FileController*)findFileControllerWithRelativePath:(NSString*)relativePath;

- (NSMutableArray*)fileControllersMatchingName:(NSString*)name;

- (FileController*)correspondingBaseFileControllerForFileController:(FileController*)fileController;
- (FileController*)fileControllerMatchingBaseFileController:(FileController*)baseFileController;

- (NSArray*)fileControllersToSynchToDisk;
- (NSArray*)fileControllersToSynchFromDisk;

@end
