//
//  TestProjectProvider.m
//  iLocalize3
//
//  Created by Jean on 5/20/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "CmdLineProjectProvider.h"
#import "FMManager.h"
#import "NibEngine.h"
#import "FMEngine.h"
#import "ProjectModel.h"
#import "ProjectPrefs.h"

@implementation CmdLineProjectProvider

- (id)init
{
	if(self = [super init]) {
		mProjectModel = [[ProjectModel alloc] init];
		mConsole = [[Console alloc] init];
		
		mProjectController = [[ProjectController alloc] init];
		[mProjectController setProjectProvider:self];
		
		mEngineProvider = [[EngineProvider alloc] init];
		[mEngineProvider setProjectProvider:self];
	}
	return self;
}

- (void)setUndoManagerEnabled:(BOOL)flag
{
	
}

- (BOOL)undoManagerEnabled
{
	return NO;
}

- (NSUndoManager*)projectUndoManager
{
	return nil;
}

- (ProjectModel*)projectModel
{
	return mProjectModel;
}

- (void)setProjectModel:(ProjectModel*)model
{
	[mProjectController rebuildFromModel];
}

- (ProjectPrefs*)projectPrefs
{
	return [[ProjectPrefs alloc] init];
}

- (Structure*)structure
{
	return nil;
}

- (Explorer*)explorer
{
	return nil;
}

- (Console*)console
{
	return mConsole;
}

- (HistoryManager*)historyManager
{
	return nil;
}

- (ProjectDocument*)projectDocument
{
	return nil;
}

- (ProjectWC*)projectWC
{
	return nil;
}

- (ProjectController*)projectController
{
	return mProjectController;
}

- (LanguageController*)selectedLanguageController
{
	return nil;
}

- (NSArray*)selectedFileControllers
{
	return nil;
}

- (NSArray*)selectedStringControllers
{
	return nil;
}

- (OperationWC*)operation
{
	return nil;
}

- (OperationDispatcher*)operationDispatcher
{
	return nil;
}

- (EngineProvider*)engineProvider
{
	return mEngineProvider;
}

- (FMEditor*)currentFileModuleEditor
{
	return nil;
}

- (FMEditor*)fileModuleEditorForFile:(NSString*)file
{
	return nil;
}

- (FMEngine*)fileModuleEngineForFile:(NSString*)file
{
	FMEngine *engine = [[FMManager shared] engineForFile:file];
	[engine setProjectProvider:self];
	return engine;
}

- (NSString*)sourceApplicationPath
{
	return nil;
}

- (NSString*)outputApplicationPath
{
	return nil;
}

- (NSString*)projectAppVersionString
{
	return nil;
}

- (NSString*)applicationExecutableName
{
	return nil;
}

- (void)beginOperation
{
	NSLog(@"Begin operation");
}

- (void)endOperation
{
	NSLog(@"End operation");
}

- (void)rearrangeFilesController
{
}

- (void)resetConflictingFilesDecision
{
}

- (void)setConflictingFilesDecision:(NSArray*)decision
{
}

- (int)decisionForConflictingRelativeFile:(NSString*)file
{
	NSLog(@"Decision for conflicting relative file %@", file);
	return 0;
}

- (void)setDirty
{
	
}

- (void)openFileWithExternalEditor:(NSString*)file
{
	
}

@end

