//
//  ProjectDetails.h
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectWC.h"
#import "ProjectProvider.h"

@interface ProjectDetails : NSViewController
{
    NSUInteger   resizingMask;
    BOOL         displayed;
}

@property (assign) ProjectWC *projectWC;

- (id<ProjectProvider>)projectProvider;

- (BOOL)displayed;

- (void)setResizableFlag:(BOOL)flag;

// This menu will be displayed in the divider part of the details split view
- (NSMenu *)actionMenu;

// Returns the view that should be inserted in the key view loop.
// Usually this is the table view that contains the information
- (NSView *)keyView;

- (void)awakeFromNib;

- (void)close;

- (void)willShow;
- (void)willHide;
- (void)didHide;

- (void)update;

- (void)begin;
- (void)commit;

- (void)addDetail:(NSString *)detail;
- (void)addDetail:(NSString *)detail value:(NSString *)value;
- (void)addSection:(NSString *)title;
- (void)addSeparator;

- (BOOL)canExecuteCommand:(SEL)command;
- (void)executeCommand:(SEL)command;

@end
