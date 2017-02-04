//
//  ProjectDetailsPath.h
//  iLocalize
//
//  Created by Jean Bovet on 1/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectDetails.h"
#import "ProjectProvider.h"

@class ProjectWC;
@class AZPathNode;

@interface ProjectStructureViewController : NSViewController
{
    @public
    IBOutlet NSTreeController  *controller;
    IBOutlet NSOutlineView     *outlineView;
}

@property (assign) ProjectWC *projectWC;

+ (ProjectStructureViewController *)newInstance:(ProjectWC *)projectWC;

/**
 Returns a tree of path structure. This method is used internally as well
 by the project export view controller.
 */
+ (AZPathNode *)pathTreeForProjectProvider:(id<ProjectProvider>)pp;

- (void)update;

@end
