//
//  AbstractEngine.h
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "EngineProvider.h"
#import "ProjectProvider.h"

@class ProjectController;
@class ProjectModel;

@class FMEngine;

@interface AbstractEngine : NSObject {
	EngineProvider	*mEngineProvider;
}

- (void)setEngineProvider:(EngineProvider*)factory;
- (EngineProvider*)engineProvider;
- (id<ProjectProvider>)projectProvider;

- (ProjectController*)projectController;
- (ProjectModel*)projectModel;
- (ProjectPrefs*)projectPrefs;
- (Console*)console;
- (OperationWC*)operation;

- (FMEngine*)fileModuleEngineForFile:(NSString*)file;

- (void)notifyProjectDidBecomeDirty;
- (void)notifyAllFileControllersDidChange;
- (void)notifyProjectSelectLanguage:(NSString*)language;

@end
