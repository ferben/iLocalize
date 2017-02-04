//
//  TestProjectProvider.h
//  iLocalize3
//
//  Created by Jean on 5/20/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"
#import "EngineProvider.h"
#import "Console.h"
#import "ProjectController.h"
#import "LanguageController.h"

@class ProjectWC;
@class ProjectPrefs;
@class Explorer;
@class HistoryManager;
@class ProjectDocument;
@class ProjectModel;

@interface CmdLineProjectProvider : NSObject <ProjectProvider>
{
    ProjectModel       *mProjectModel;
    Console            *mConsole;
    ProjectController  *mProjectController;
    EngineProvider     *mEngineProvider;
}

- (void)setProjectModel:(ProjectModel *)model;

@end
