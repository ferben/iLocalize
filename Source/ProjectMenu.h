//
//  ProjectMenu.h
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@class ProjectWC;
@class ProjectFilesController;
@class ProjectExplorerController;
@class ProjectDetailsController;
@class ProjectDocument;

@interface ProjectMenu : NSResponder

@property (assign) ProjectWC *projectWC;

+ (id)newInstance:(ProjectWC*)projectWC;

- (void)awake;
- (void)destroy;

- (ProjectDocument*)projectDocument;
- (ProjectFilesController*)projectFiles;
- (ProjectExplorerController*)projectExplorer;
- (ProjectDetailsController*)projectDetails;

- (NSWindow*)window;

@end
