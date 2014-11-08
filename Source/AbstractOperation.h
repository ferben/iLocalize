//
//  AbstractOperation.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"
#import "OperationDispatcher.h"

@class EngineProvider;

@class TableViewCustom;
@class ProjectFilesController;
@class ProjectExplorerController;

@class ProjectController;
@class LanguageController;

@class AbstractWC;
@class OperationWC;

@class Console;

@interface AbstractOperation : NSObject {
	id <ProjectProvider>		mProjectProvider;
	NSMutableDictionary			*mAbstractWCInstances;
	CallbackBlock				didCloseCallback;
}

@property (copy) CallbackBlock didCloseCallback;

+ (id)operationWithProjectProvider:(id<ProjectProvider>)provider;

- (id<ProjectProvider>)projectProvider;
- (ProjectController*)projectController;
- (ProjectWC*)projectWC;
- (ProjectFilesController*)projectFiles;
- (ProjectExplorerController*)projectExplorer;
- (NSWindow*)projectWindow;

- (NSPopUpButton*)languagesPopUp;

- (NSArrayController*)languagesController;
- (NSArrayController*)filesController;

- (LanguageController*)selectedLanguageController;

- (AbstractWC*)instanceOfAbstractWCName:(NSString*)className;
- (OperationWC*)operation;
- (OperationDispatcher*)operationDispatcher;
- (EngineProvider*)engineProvider;
- (Console*)console;

- (void)refreshListOfFiles;

- (void)close;

@end
