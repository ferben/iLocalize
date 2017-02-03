//
//  LanguageController.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "LanguageController.h"
#import "ProjectController.h"
#import "FileController.h"
#import "StringController.h"

#import "LanguageModel.h"
#import "FileModel.h"
#import "FileModelContent.h"
#import "StringsContentModel.h"

#import "ExplorerItem.h"
#import "ExplorerFilter.h"

#import "FMManager.h"
#import "FMController.h"

#import "SmartPathParser.h"
#import "FileTool.h"
#import "LanguageTool.h"
#import "DirtyContext.h"

#import "Constants.h"

@interface LanguageController (PrivateMethods)
- (void)computeStatistics;
@end

@implementation LanguageController

+ (void)initialize
{
//    [LanguageController setKeys:[NSArray arrayWithObjects:@"fileControllers", nil]
//					triggerChangeNotificationsForDependentKey:@"filteredFileControllers"];
//		
//    [LanguageController setKeys:[NSArray arrayWithObjects:@"fileControllers", @"localFileControllers", nil]
//					triggerChangeNotificationsForDependentKey:@"numberOfFiles"];
//	
//    [LanguageController setKeys:[NSArray arrayWithObjects:@"fileControllers", @"localFileControllers", nil]
//					triggerChangeNotificationsForDependentKey:@"selfValue"];
//	
//    [LanguageController setKeys:[NSArray arrayWithObjects:@"fileControllers", @"filteredFileControllers", @"localFileControllers", @"filteredLocalFileControllers", nil]
//					triggerChangeNotificationsForDependentKey:@"fileInfo"];
}

+ (NSSet *)keyPathsForValuesAffectingFilteredFileControllers
{
	return [NSSet setWithObjects:@"fileControllers", nil];
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfFiles
{
	return [NSSet setWithObjects:@"fileControllers", @"localFileControllers", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelfValue
{
	return [NSSet setWithObjects:@"fileControllers", @"localFileControllers", nil];
}

+ (NSSet *)keyPathsForValuesAffectingFileInfo
{
	return [NSSet setWithObjects:@"fileControllers", @"localFileControllers", @"localFileControllers", @"filteredLocalFileControllers", nil];
}

#pragma mark -

- (id)init
{
	if (self = [super init])
    {
		mBaseLanguageModel = NULL;
		mLanguageModel = NULL;
		mFileControllers = [[NSMutableArray alloc] init];
		mPath2FC = [[NSMutableDictionary alloc] init];
		mNumberOfFilteredFileControllers = 0;
		mNumberOfFoundFileControllers = 0;
		mFilterShowLocalFiles = NO;
	}
	
    return self;
}


- (void)endOperation
{
    [super endOperation];
	[self filteredFileControllersDidChange];
    [self computeStatistics];
}

#pragma mark -

- (void)addToCache:(FileController *)fc
{
	mPath2FC[[fc relativeFilePath]] = fc;
}

- (void)removeFromCache:(FileController *)fc
{
	[mPath2FC removeObjectForKey:[fc relativeFilePath]];
}

- (FileController *)lookupInCache:(NSString *)relativePath
{
	FileController *fc = mPath2FC[relativePath];
	
    if (fc == nil)
    {
		fc = [self findFileControllerWithRelativePath:relativePath];
		
        if (fc)
        {
			[self addToCache:fc];
		}
	}
    
	return fc;
}

#pragma mark -

- (void)setFilterShowLocalFiles:(BOOL)flag
{
	mFilterShowLocalFiles = flag;
	[self filteredFileControllersDidChange];
}

- (void)addFileController:(FileController *)fileController
{	
	[fileController setParent:self];
	[fileController rebuildFromModel];
    
	@synchronized(mFileControllers)
    {
		[mFileControllers addObject:fileController];		
	}
	
    [self addToCache:fileController];
}

- (void)deleteFileController:(FileController *)fileController removeFromDisk:(BOOL)removeFromDisk
{
	if (removeFromDisk)
    {
		[[fileController absoluteFilePath] removePathFromDisk];		
	}
	
    [mLanguageModel deleteFileModel:[fileController fileModel]];
	
    @synchronized(mFileControllers)
    {
		[mFileControllers removeObject:fileController];					
	}
}

- (void)rebuildFileControllers
{
	@synchronized(mFileControllers)
    {
		[mFileControllers removeAllObjects];		
	}

	// Add all the regular files
	for (FileModel *baseFileModel in [mBaseLanguageModel fileModels])
    {
		// Skip the files local to the base language
		if ([baseFileModel isLocal])
            continue;
		
		// Ignore file without corresponding file model which is the case if they are
		// old local file placeholder.
		if (![mLanguageModel fileModelForBaseFileModel:baseFileModel])
            continue;
		
		FileController *fileController = [[FMManager shared] defaultControllerForFile:[baseFileModel filename]];		
		[fileController setBaseFileModel:baseFileModel];
		[fileController setFileModel:[mLanguageModel fileModelForBaseFileModel:baseFileModel]];
		
        [self addFileController:fileController];
	}			
	
	// Add all the local files
	for (FileModel *fileModel in [mLanguageModel fileModels])
    {
		if ([fileModel isLocal])
        {
			FileController *fileController = [[FMManager shared] defaultControllerForFile:[fileModel filename]];		
			[fileController setBaseFileModel:nil];
			[fileController setFileModel:fileModel];

            [self addFileController:fileController];
		}
	}
}

- (void)rebuildFromModel
{
	[self rebuildFileControllers];	
	[self computeStatistics];
}

#pragma mark -

- (void)setBaseLanguageModel:(LanguageModel *)model
{
	mBaseLanguageModel = model;
}

- (LanguageModel *)baseLanguageModel
{
	return mBaseLanguageModel;
}

- (void)setLanguageModel:(LanguageModel *)model
{
	mLanguageModel = model;
}

- (LanguageModel *)languageModel
{
	return mLanguageModel;
}

#pragma mark -

- (void)statisticsDidChange
{
	[self willChangeValueForKey:@"percentCompleted"];
	[self didChangeValueForKey:@"percentCompleted"];

	[self willChangeValueForKey:@"selfValue"];
	[self didChangeValueForKey:@"selfValue"];
	
	[self willChangeValueForKey:@"languageInfo"];
	[self didChangeValueForKey:@"languageInfo"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationLanguageStatsDidChange object:self];
}

- (void)fileControllersDidChange
{
	[self willChangeValueForKey:@"fileControllers"];
	[self didChangeValueForKey:@"fileControllers"];

	[self willChangeValueForKey:@"localFileControllers"];
	[self didChangeValueForKey:@"localFileControllers"];

	[self filteredFileControllersDidChange];
}

- (void)filteredFileControllersDidChange
{
	[self willChangeValueForKey:@"filteredFileControllers"];
	[self didChangeValueForKey:@"filteredFileControllers"];

	[self willChangeValueForKey:@"filteredLocalFileControllers"];
	[self didChangeValueForKey:@"filteredLocalFileControllers"];
}

- (void)baseStringModelDidChange:(StringModel *)model fileController:(FileController *)fc
{
	FileController *fileController = [self fileControllerWithRelativePath:[fc relativeFilePath] translate:YES];
	[fileController baseStringModelDidChange:model];
}

#pragma mark -

- (BOOL)isBaseLanguage
{
	return (mBaseLanguageModel == mLanguageModel);
}

- (NSString *)baseLanguage
{
	return [mBaseLanguageModel language];
}

- (NSString *)displayBaseLanguage
{
	return [[self baseLanguage] displayLanguageName];
}

- (NSString *)language
{
	return [mLanguageModel language];
}

- (NSString *)displayLanguage
{
	return [[self language] displayLanguageName];
}

#pragma mark -

- (void)markDirty
{
    if (!mOperationRunning)
    {
    	[self computeStatistics];		
	}	
	
    [super markDirty];
}

- (void)computeStatistics
{
    mTotalNumberOfStrings = 0;
    mNumberOfTranslatedStrings = 0;
    mNumberOfUntranslatedStrings = 0;
	mNumberOfToCheckStrings = 0;
        
	for (FileController *fc in [self fileControllers])
    {
		float f = [fc percentCompleted];
	
        if (f == -1)
			continue;
		
        mTotalNumberOfStrings += [fc numberOfStrings];
        mNumberOfTranslatedStrings += [fc numberOfTranslatedStrings];
        mNumberOfUntranslatedStrings += [fc numberOfNonTranslatedStrings];
		mNumberOfToCheckStrings += [fc numberOfToCheckStrings];
	}
	    	
	if (mTotalNumberOfStrings == 0)
    {
		mPercentCompleted = 100;
	}
    else
    {
		mPercentCompleted = 100.0 * mNumberOfTranslatedStrings / mTotalNumberOfStrings;
	}

	[self statisticsDidChange];
}

- (float)percentCompleted
{
	return [self isBaseLanguage]?100:mPercentCompleted;
}

- (NSString *)percentCompletedString
{
	float value = [self percentCompleted];
    
	if (value < 100)
    {
		return [NSString stringWithFormat:@"%3.0f%%", value>=99.5?99:value];
	}
    else
    {
		return @"";
	}		
}

- (NSUInteger)totalNumberOfStrings
{
    return mTotalNumberOfStrings;
}

- (NSUInteger)totalNumberOfTranslatedStrings
{
    return mNumberOfTranslatedStrings;
}

- (NSUInteger)totalNumberOfNonTranslatedStrings
{
    return mNumberOfUntranslatedStrings;
}

- (NSUInteger)totalNumberOfToCheckStrings
{
	return mNumberOfToCheckStrings;
}

#pragma mark -

- (NSString *)fileInfo
{	
	NSString *fileString = NSLocalizedString(@"File", NULL);
	NSString *filesString = NSLocalizedString(@"Files", NULL);
	NSUInteger total = [[self fileControllers] count];
    
	if (total == mNumberOfFoundFileControllers)
		return [NSString stringWithFormat:@"%ld %@", total, (total > 1) ? filesString : fileString];
	else
		return [NSString stringWithFormat:NSLocalizedString(@"%ld of %ld %@", @"File Content Info"), mNumberOfFoundFileControllers, total, (total > 1) ? filesString : fileString];
}

- (NSUInteger)numberOfFileControllers
{
	return [[self fileControllers] count];
}

- (NSArray *)fileControllers
{
	NSArray *safe = nil;
	
    @synchronized(mFileControllers)
    {
		safe = [NSArray arrayWithArray:mFileControllers];
	}
	
    return safe;
}

- (NSSet *)allWarningNumbers
{
	NSMutableSet *warnings = [NSMutableSet set];
    
	for (FileController *fc in [self fileControllers])
    {
		for (StringController *sc in [fc stringControllers])
        {
			if ([sc statusWarning])
            {
				[warnings addObject:@STRING_STATUS_WARNING];
			}
			
            if ([sc statusBaseModified])
            {
				[warnings addObject:@(100 + STRING_STATUS_BASE_MODIFIED)];
			}
            
			if ([sc statusToCheck])
            {
				[warnings addObject:@(100 + STRING_STATUS_TOCHECK)];
			}
		}
		
		if ([fc statusNotFound])
        {
			[warnings addObject:@FILE_STATUS_NOT_FOUND];
		}
		
        if ([fc statusCheckLayout])
        {
			[warnings addObject:@FILE_STATUS_CHECK_LAYOUT];
		}
		
        if ([fc statusWarning])
        {
			[warnings addObject:@FILE_STATUS_WARNING];
		}
	}

    return warnings;
}

- (NSImage *)allWarningsImage
{
	if ([self isBaseLanguage])
        return nil;
	
	NSMutableArray* warnings = [NSMutableArray array];
	NSEnumerator *e = [[self allWarningNumbers] objectEnumerator];
	NSNumber *n;
    
	while (n = [e nextObject])
    {
		switch ([n intValue])
        {
			case 100 + STRING_STATUS_BASE_MODIFIED:
				[warnings addObject:[NSImage imageNamed:@"string_base_modified"]];
				break;
                
			case 100 + STRING_STATUS_TOCHECK:
				[warnings addObject:[NSImage imageNamed:@"string_auto_translated"]];
				break;

			case FILE_STATUS_NOT_FOUND:
				[warnings addObject:[NSImage imageNamed:@"_warning_red"]];
				break;
                
			case FILE_STATUS_CHECK_LAYOUT:
				[warnings addObject:[NSImage imageNamed:@"_file_check_layout"]];
				break;
                
			// string warning is the same as file warning
			// case STRING_STATUS_WARNING:
			case FILE_STATUS_WARNING:
				[warnings addObject:[NSImage imageNamed:@"_warning"]];
				break;
		}
	}

    if ([warnings count] == 0)
    {
		return nil;
	}
    else
    {
		return [warnings imageUnion];		
	}
}

#pragma mark -

- (NSArray *)filteredFileControllers
{
	NSArray *array = [self fileControllers];
	NSPredicate * p = [NSPredicate predicateWithFormat:@"local == %d", mFilterShowLocalFiles?1:0];
	array = [array filteredArrayUsingPredicate:p];
	mNumberOfFilteredFileControllers = [array count];
	mNumberOfFoundFileControllers = [array count];
    
	return array;
}

- (FileController *)fileControllerWithFileModel:(FileModel *)fileModel
{
	BOOL optimized = YES;
    
	if (optimized)
    {
		return [self lookupInCache:[fileModel relativeFilePath]];
	}
    else
    {
		for (FileController *fileController in [self fileControllers])
        {
			if ([fileController fileModel] == fileModel)
				return fileController;
		}
        
		return nil;			
	}
}

- (FileController *)fileControllerWithRelativePath:(NSString *)relativePath translate:(BOOL)translate
{
	NSString *localizedRelativePath = relativePath;
    
	if (translate)
    {
		localizedRelativePath = [FileTool translatePath:relativePath toLanguage:[self language]];		
	}

	BOOL optimized = YES;
	
    if (optimized)
    {
		return [self lookupInCache:localizedRelativePath];
	}
    else
    {
		return [self findFileControllerWithRelativePath:localizedRelativePath];
	}
}

- (FileController *)findFileControllerWithRelativePath:(NSString *)relativePath
{
	for (FileController *fileController in [self fileControllers])
    {
        if ([[fileController relativeFilePath] isEquivalentToPath:relativePath])
			return fileController;        
	}
    
	return nil;			
}

- (NSMutableArray *)fileControllersMatchingName:(NSString *)name
{
	NSMutableArray *matches = [NSMutableArray array];
    
	for (FileController *fileController in [self fileControllers])
    {
		if ([[[fileController relativeFilePath] lastPathComponent] isEqualCaseInsensitiveToString:name])
			[matches addObject:fileController];
	}
    
	return matches;
}

#pragma mark -

- (FileController *)correspondingBaseFileControllerForFileController:(FileController *)fileController
{
	return [[self parent] correspondingBaseFileControllerForFileController:fileController];
}

- (FileController *)fileControllerMatchingBaseFileController:(FileController *)baseFileController
{
	return [self fileControllerWithRelativePath:[baseFileController relativeFilePath] translate:YES];
}

#pragma mark -

- (NSArray *)fileControllersToSynchToDisk
{
	NSMutableArray *array = [NSMutableArray array];
	
    for (FileController *fileController in [self fileControllers])
    {
		if ([fileController statusSynchToDisk])
			[array addObject:fileController];
	}		
	
    return array;
}

- (NSArray *)fileControllersToSynchFromDisk
{
	NSMutableArray *array = [NSMutableArray array];
	
    for (FileController *fileController in [self fileControllers])
    {
		if ([fileController statusSynchFromDisk])
			[array addObject:fileController];
	}
    
	return array;
}

@end
