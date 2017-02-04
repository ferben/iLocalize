//
//  ProjectStatusBarController.h
//  iLocalize
//
//  Created by Jean Bovet on 3/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class ProjectWC;

@interface ProjectStatusBarController : NSViewController
{
    IBOutlet NSTextField  *leftSideTextField;
    IBOutlet NSTextField  *rightSideTextField;
}

@property (assign) ProjectWC *projectWC;

+ (ProjectStatusBarController *)newInstance:(ProjectWC *)projectWC;

- (void)update;

@end
