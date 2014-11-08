//
//  AbstractEngine.m
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"
#import "EngineProvider.h"
#import "FMManager.h"

#import "ProjectWC.h"

#import "ProjectController.h"
#import "ProjectModel.h"

#import "Console.h"
#import "ConsoleItem.h"

#import "OperationWC.h"

@implementation AbstractEngine

- (id)init
{
	if(self = [super init]) {
		mEngineProvider = NULL;
	}
	return self;
}


- (void)setEngineProvider:(EngineProvider*)factory
{
	mEngineProvider = factory;
}

- (EngineProvider*)engineProvider
{
	return mEngineProvider;
}

- (id<ProjectProvider>)projectProvider
{
	return [[self engineProvider] projectProvider];
}

- (ProjectController*)projectController
{
	return [[self projectProvider] projectController];
}

- (ProjectModel*)projectModel
{
	return [[self projectProvider] projectModel];
}

- (ProjectPrefs*)projectPrefs
{
	return [[self projectProvider] projectPrefs];
}

- (Console*)console
{
	return [[self projectProvider] console];
}

- (OperationWC*)operation
{
	return [[self projectProvider] operation];
}

- (FMEngine*)fileModuleEngineForFile:(NSString*)file
{
	return [[self projectProvider] fileModuleEngineForFile:file];
}

#pragma mark -

- (void)notifyProjectDidBecomeDirty
{
	if(![[NSThread currentThread] isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyProjectDidBecomeDirty) withObject:nil waitUntilDone:NO];
	} else {
		[[self projectProvider] setDirty];			
	}
}

- (void)notifyAllFileControllersDidChange
{
	if(![[NSThread currentThread] isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyAllFileControllersDidChange) withObject:nil waitUntilDone:NO];
	} else {
		[[[[self projectProvider] projectController] languageControllers] makeObjectsPerformSelector:@selector(fileControllersDidChange)];	
	}
}

- (void)notifyProjectSelectLanguage:(NSString*)language
{
	if(![[NSThread currentThread] isMainThread]) {
		[self performSelectorOnMainThread:@selector(notifyProjectSelectLanguage:) withObject:language waitUntilDone:NO];
	} else {
		LanguageController *lc = [[self projectController] languageControllerForLanguage:language];
		[[[[self projectProvider] projectWC] languagesController] setSelectedObjects:@[lc]];
	}
}

@end
