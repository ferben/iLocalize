//
//  NewProjectEngine.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ProjectModel;
@class NewProjectSettings;

@interface NewProjectOperation : Operation
{
    NewProjectSettings  *settings;
}

@property (strong) NewProjectSettings *settings;

/**
 These methods is exposed for the Unit Tests in order
 to create a project without having to create the
 project window and showing it.
 */
- (void)prepareProjectModel:(ProjectModel *)model;
- (void)createProject;

@end
