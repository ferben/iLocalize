//
//  ProjectController.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "ProjectModel.h"
#import "ExplorerItem.h"
#import "LanguageTool.h"
#import "DirtyContext.h"
#import "Constants.h"

@implementation ProjectController

- (id)init
{
	if(self = [super init]) {
		mLanguageControllers = [[NSMutableArray alloc] init];

		mCurrentLanguageIndex = 0;
				
		dirtyContext = [[DirtyContext alloc] init];
		dirtyCount = 0;
		
		[self setDirtyEnable:YES];
	}
	return self;
}


#pragma mark -

- (void)beginOperation
{
    [super beginOperation];
    [mLanguageControllers makeObjectsPerformSelector:@selector(beginOperation) withObject:NULL];
}

- (void)endOperation
{
    [mLanguageControllers makeObjectsPerformSelector:@selector(endOperation) withObject:NULL];
    [super endOperation];
}

#pragma mark -

- (void)addLanguageController:(LanguageController*)languageController
{
	[languageController setParent:self];
	[languageController rebuildFromModel];
	[mLanguageControllers addObject:languageController];	
	[self languagesDidChange];
}

- (void)removeLanguageController:(LanguageController*)languageController
{
	[mLanguageControllers removeObject:languageController];	
	[self languagesDidChange];
}

#pragma mark -

- (void)rebuildFromModel
{
	[mLanguageControllers removeAllObjects];
			
	NSEnumerator *enumerator = [[[self projectModel] languageModels] objectEnumerator];
	LanguageModel *languageModel;
	while((languageModel = [enumerator nextObject])) {
		LanguageController *languageController = [LanguageController controller];
		[languageController setBaseLanguageModel:[[self projectModel] baseLanguageModel]];
		[languageController setLanguageModel:languageModel];				
		[self addLanguageController:languageController];
	}		
	
	[self languagesDidChange];
}

#pragma mark -

- (void)setCurrentLanguageIndex:(int)index
{
	mCurrentLanguageIndex = index;
}

- (int)currentLanguageIndex
{
	return mCurrentLanguageIndex;
}

#pragma mark -

- (void)setDirtyEnable:(BOOL)flag
{
	mDirtyEnable = flag;
}

- (void)beginDirty
{
	if(dirtyCount == 0) {
		markDirty = NO;
	}
	dirtyCount++;
	[self pushDirtySource:self];
}

- (void)endDirty
{
	dirtyCount--;
	if(dirtyCount == 0) {
		[self notifyDirty];		
	} else if(dirtyCount < 0) {
		ERROR(@"Dirty count is negative (%ld)", dirtyCount);
		[self notifyDirty];		
		dirtyCount = 0;
	}
}

- (void)markDirty
{
	markDirty = YES;
}

- (void)pushDirtySource:(id)source
{
	[dirtyContext pushSource:source];
}

- (void)notifyDirtyOnMainThread:(DirtyContext*)dc
{
	if([NSThread isMainThread]) {
		[self dirtyTriggered];		
		[[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationProjectControllerDidBecomeDirty object:self userInfo:@{@"context": dc}];
	} else {
		[self performSelector:@selector(notifyDirtyOnMainThread:) onThread:[NSThread mainThread] withObject:dc waitUntilDone:NO];
	}	
}

- (void)notifyDirty
{	
	if(markDirty) {
		markDirty = NO;
		if(mDirtyEnable) {
			[self pushDirtySource:self];
			[self notifyDirtyOnMainThread:[dirtyContext copy]];
			[dirtyContext reset];
		}		
	}
}

- (void)languagesDidChange
{
	[self willChangeValueForKey:@"languageControllers"];
	[self didChangeValueForKey:@"languageControllers"];
}

- (void)baseStringModelDidChange:(StringModel*)model fileController:(FileController*)fc
{
	NSEnumerator *enumerator = [[self languageControllers] objectEnumerator];
	LanguageController *lc;
	while(lc = [enumerator nextObject]) {
		[lc baseStringModelDidChange:model fileController:fc];
	}
}

#pragma mark -

- (BOOL)isLanguageExisting:(NSString*)language
{
	return [self languageControllerForLanguage:language] != NULL;
}

- (NSString*)baseLanguage
{
	return [[self baseLanguageController] language]; 
}

- (NSMutableArray*)languages
{
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *enumerator = [[self languageControllers] objectEnumerator];
	LanguageController *controller;
	while(controller = [enumerator nextObject]) {
		[array addObject:[controller language]];
	}
	return array;	
}

- (NSArray*)displayLanguages
{
	NSMutableArray *array = [NSMutableArray array];
	[[self languageControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[array addObject:[obj displayLanguage]];		
	}];
	return array;	
}

#pragma mark -

- (LanguageController*)baseLanguageController
{
	return [self languageControllerForLanguage:[[self projectModel] baseLanguage]];
}

- (NSMutableArray*)languageControllers
{
	return mLanguageControllers;
}

- (LanguageController*)languageControllerForLanguage:(NSString*)language
{
	NSEnumerator *enumerator = [[self languageControllers] objectEnumerator];
	LanguageController *languageController;
	while(languageController = [enumerator nextObject]) {
		NSArray *equivalentLanguages = [LanguageTool equivalentLanguagesWithLanguage:[languageController language]];
		if([equivalentLanguages containsObject:language])
			return languageController;
	}
	return NULL;
}

- (FileController*)correspondingBaseFileControllerForFileController:(FileController*)fileController
{
	if([fileController isBaseFileController]) {
		return fileController;		
	} else {		
		return [[self baseLanguageController] fileControllerWithFileModel:[fileController baseFileModel]];
	}
}

#pragma mark -

- (NSString*)relativePathForSmartPath:(NSString*)smartPath language:(NSString*)language
{
	NSEnumerator *enumerator = [[[self languageControllerForLanguage:language] fileControllers] objectEnumerator];
	FileController *fileController;
	while(fileController = [enumerator nextObject]) {
		if([[fileController smartPath] isEqualToString:smartPath])
			return [fileController relativeFilePath];
	}	
	return NULL;	
}

- (NSString*)relativeBaseLanguagePathForSmartPath:(NSString*)smartPath
{
	NSEnumerator *enumerator = [[[self baseLanguageController] fileControllers] objectEnumerator];
	FileController *fileController;
	while(fileController = [enumerator nextObject]) {
		if([[fileController smartPath] isEqualToString:smartPath])
			return [fileController relativeFilePath];
	}	
	return NULL;
}

- (NSArray*)smartPaths
{
	NSMutableArray *array = [NSMutableArray array];
	NSEnumerator *enumerator = [[[self baseLanguageController] fileControllers] objectEnumerator];
	FileController *fileController;
	while(fileController = [enumerator nextObject]) {
		NSString *smartPath = [fileController smartPath];
		if(![array containsObject:smartPath])
			[array addObject:smartPath];
	}
	return array;
}

#pragma mark -

- (NSArray*)needsToBeSavedFileControllers
{
	NSMutableArray *array = [NSMutableArray array];
	for(LanguageController *lc in mLanguageControllers) {
		[array addObjectsFromArray:[lc fileControllersToSynchToDisk]];		
	}
	return array;
}

- (NSArray*)needsToBeReloadedFileControllers
{
	NSMutableArray *array = [NSMutableArray array];
	for(LanguageController *lc in mLanguageControllers) {
		[array addObjectsFromArray:[lc fileControllersToSynchFromDisk]];
	}	
	return array;
}

@end
