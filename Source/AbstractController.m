//
//  AbstractController.m
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractController.h"
#import "ProjectModel.h"
#import "ProjectWC.h"
#import "ProjectLabels.h"

#import "Console.h"
#import "OperationWC.h"

#import "EngineProvider.h"

@implementation AbstractController

+ (id)controller
{
	return [[self alloc] init];
}

- (id)init
{
	if(self = [super init]) {
		mLabelIndexes = -1;
		mLabelString = nil;
	}
	return self;
}


#pragma mark -

- (void)beginOperation
{
    mOperationRunning = YES;
}

- (void)endOperation
{
    mOperationRunning = NO;
}

#pragma mark -

- (void)rebuildFromModel
{
	// Used by subclasses to rebuild themself from the model
}

- (void)beginDirty
{
	[self pushDirtySource:self];
	[[self parent] beginDirty];
}

- (void)endDirty
{
	[[self parent] endDirty];
}

- (void)markDirty
{
	[[self parent] markDirty];	
}

- (void)pushDirtySource:(id)source
{
	[[self parent] pushDirtySource:source];	
}

- (void)dirtyTriggered
{
}

- (id<ProjectProvider>)projectProvider
{
	// Should be subclassed at some point (i.e. ProjectController)
	return [[self parent] projectProvider];
}

- (ProjectModel *)projectModel
{
	return [[self projectProvider] projectModel];	
}

- (NSUndoManager *)undoManager
{
	return [[self projectProvider] projectUndoManager];
}

// Used by custom cell to fetch the controller object

- (NSValue *)selfValue
{
	return [NSValue valueWithNonretainedObject:self];
}

#pragma mark -

- (NSString *)absoluteProjectPathFromRelativePath:(NSString *)relativePath
{
	if (relativePath)
    {
		return [[self projectModel] absoluteProjectPathFromRelativePath:relativePath];		
	}
    else
    {
		return nil;
	}
}

- (NSString *)relativePathFromAbsoluteProjectPath:(NSString *)absolutePath
{
	return [[self projectModel] relativePathFromAbsoluteProjectPath:absolutePath];
}

- (NSArray *)relativePathsFromAbsoluteProjectPaths:(NSArray *)absolutePaths
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSString *absolutePath;
    
	for (absolutePath in absolutePaths)
    {
		NSString *relativePath = [self relativePathFromAbsoluteProjectPath:absolutePath];
        
		if (relativePath)
			[array addObject:relativePath];
	}
    
	return array;
}

#pragma mark -
#pragma mark Labels

- (NSSet *)labelIndexes
{
	return nil;
}

- (void)updateLabelIndexes
{
	if (mLabelString == nil)
    {
		mLabelString = [[NSMutableString alloc] init];
	}
	
	mLabelIndexes = 0;
    
	for (NSNumber *index in [self labelIndexes])
    {
		mLabelIndexes = mLabelIndexes | (1 << [index intValue]);
		NSString *identifier = [[[[self projectProvider] projectWC] projectLabels] labelIdentifierForIndex:[index intValue]];
        
		if (identifier)
        {
			[mLabelString appendString:identifier];
		}
	}		
}

- (long)labels
{
	if (mLabelIndexes == -1)
    {
		[self updateLabelIndexes];		
	}
    
	return mLabelIndexes;
}

@end
