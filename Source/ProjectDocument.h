//
//  ProjectDocument.h
//  iLocalize3
//
//  Created by Jean on 29.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"
#import "CheckProjectDelegate.h"

@class NewProjectSettings;
@class ConsoleWC;

@interface ProjectDocument : NSDocument <ProjectProvider,CheckProjectDelegate>
{
    // Models    
    ProjectModel         *mProjectModel;
    ProjectPrefs         *mProjectPrefs;
    Console              *mConsole;

    // Models (not saved, built dynamically)
    Structure            *mStructure;
    Explorer             *mExplorer;
    
    // Controllers    
    ProjectController    *mProjectController;
    
    // Windows    
    ConsoleWC            *mConsoleWindowController;
    
    // Operations    
    OperationDispatcher  *mOperationDispatcher;
    OperationWC          *mOperationWC;
    
    // Engines
    EngineProvider       *mEngineProvider;
    
    // File Modules
    NSMutableDictionary  *mFMEditors;
    NSMutableDictionary  *mFMEngines;
    
    // Conflicting file resolver
    NSMutableArray       *mConflictingFilesDecision;

    // Version of the OS where the document has been created
    NSUInteger            mOSVersion;
            
    BOOL                  mUndoManagerEnabled;
    
    // Boolean indicating when an operation is running
    BOOL                  operationRunning;
}

@property BOOL operationRunning;

- (void)createProjectDidCancel;
- (void)createProjectDidEnd;

- (void)rebuildExplorer;

- (void)updateDirty;

@end
