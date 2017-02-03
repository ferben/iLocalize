//
//  AbstractController.h
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class ProjectModel;
@class Console;
@class DirtyContext;

@interface AbstractController : NSObject
{
    BOOL    mOperationRunning;
    
    // temporary - cache only
    long            mLabelIndexes;
    NSMutableString    *mLabelString;
}

@property (nonatomic, weak) id parent;

+ (id)controller;

- (void)beginOperation;
- (void)endOperation;

- (void)rebuildFromModel;

/**
 This method is invoked to indicate the beginning of an operation
 that might dirty the state of this controller.
 */
- (void)beginDirty;

/**
 This method is invoked to indicate the end of an operation that
 might dirty the state of this controller.
 */
- (void)endDirty;

/**
 This method is invoked to indicate that this controller is dirty.
 */
- (void)markDirty;

/**
 Pushes the source that is dirty. This will be accumulated at the project
 controller into the dirty context and when the setDirty is triggered,
 this context is sent with the dirty notification.
 Note that this method will actually accumulate the different fields
 of the context until the dirty notification is triggered after which
 the context is reset.
 */
- (void)pushDirtySource:(id)source;

/**
 This method is invoked when a dirty notification is triggered. Such a notification
 is triggered when the dirty count reaches 0 (in other words, when the number of endDirty
 matches the number of beginDirty) AND the mark dirty is YES.
 This is to avoid multiple dirty notification during one "transation".
 */
- (void)dirtyTriggered;

- (id<ProjectProvider>)projectProvider;
- (ProjectModel *)projectModel;

- (NSUndoManager *)undoManager;

- (NSString *)absoluteProjectPathFromRelativePath:(NSString *)relativePath;
- (NSString *)relativePathFromAbsoluteProjectPath:(NSString *)absolutePath;
- (NSArray *)relativePathsFromAbsoluteProjectPaths:(NSArray *)absolutePaths;

- (NSSet *)labelIndexes;
- (void)updateLabelIndexes;
- (long)labels;

@end
