//
//  ProjectDetailsController.h
//  iLocalize
//
//  Created by Jean on 12/29/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@class AZSplitView;
@class ProjectWC;
@class ProjectDetails;

@interface ProjectDetailsController : NSViewController
{
    // view of the buttons (owned)
    IBOutlet NSMatrix    *mButtonMatrix;
    
    // split view that need to be manipulated (show/hide) - not owned
    AZSplitView          *__weak splitView;
    
    // container view for the details view - not owned
    NSView               *__weak containerView;

    ProjectWC            *__unsafe_unretained projectWC;

    NSMutableDictionary  *mProjectDetails;
    NSView               *mCurrentDetailsView;

    NSInteger             detailsIndex;
    NSInteger             lastDetailsIndex;
    
    // Queue for all the toggle request in order to execute
    // them one at a time, serially.
    NSMutableArray       *toggleRequests;
    NSNull               *currentToggleRequest;
}

@property (assign) ProjectWC *projectWC;
@property (weak) AZSplitView *splitView;
@property (weak) NSView *containerView;
@property (strong) NSNull *currentToggleRequest;

+ (ProjectDetailsController *)newInstance:(ProjectWC *)projectWC;

- (NSView *)buttonView;
- (NSArray *)keyViews;

- (void)update;

- (void)showInfoView:(CallbackBlock)block;

- (void)showDetailsAtIndex:(int)index;
- (void)hideDetailsAtIndex:(int)index;
- (BOOL)isDetailsVisibleAtIndex:(int)index;

- (BOOL)canExecuteCommand:(SEL)command;
- (void)executeCommand:(SEL)command;

- (IBAction)toggleButton:(id)sender;

@end
