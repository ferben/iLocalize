//
//  Operation.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class OperationDriver;
@class OperationProgressViewController;
@class ProjectController;
@class ProjectModel;
@class Console;
@class EngineProvider;

/**
 This is the base class that every operation must extend. It provides
 basic features such as progress notification and cancellation.
 */
@interface Operation : NSObject
{
    BOOL             cancel;
    
    // Array of errors that happened with this operation
    NSMutableArray  *errors;
    NSMutableArray  *warnings;
    NSMutableArray  *alerts;
        
    // Keeping track of the progress
    NSUInteger       progressMax;
    NSUInteger       progress;
}

@property (weak) OperationDriver *driver;
@property (weak) OperationProgressViewController *operationProgressVC;
@property (weak) id<ProjectProvider> projectProvider;

// Main operation. Usually it is nil except when this operation
// runs as a sub-operation of another operation.
@property (weak) Operation *mainOperation;

/**
 Returns true when the operation needs to cancel as soon as possible.
 */
@property BOOL cancel;

/**
 Creates a new autoreleased operation
 */
+ (id)operation;

/**
 Returns the project controller.
 */
- (ProjectController *)projectController;

/**
 Returns the project model.
 */
- (ProjectModel *)projectModel;

/**
 Returns the engine provider.
 */
- (EngineProvider *)engineProvider;

/**
 Returns the console.
 */
- (Console *)console;

/**
 Sets the specified operation as a sub-operation. A sub operation will report
 all its activity to its main operation. This is used when one operation
 is using another operation to perform its operation.
 */
- (void)setSubOperation:(Operation *)subop;

/**
 Sets the name of the operation.
 */
- (void)setOperationName:(NSString *)name;

/**
 Sets the progress of the operation, between 0 and 1.
 */
- (void)setOperationProgress:(float)progress;

/**
 Sets the maximum value of the progress.
 */
- (void)setProgressMax:(NSUInteger)max;

/**
 Increments the progress value. Usually one will use setProgressMax with progressIncrement
 or setOperationProgress but not both at the same time.
 */
- (void)progressIncrement;

/**
 Returns YES if the operation requires the interface of the main project to be disconnected.
 This is needed when some of the objects being used in the UI are removed during the operation
 to avoid a crash if the UI is refreshed during the operation.
 */
- (BOOL)needsDisconnectInterface;

/**
 Invoke this method when a new project provider is available. This method is usually
 invoked by the New Project Assistant when the project provider is available after
 the document has been created.
 */
- (void)notifyNewProjectProvider:(id<ProjectProvider>)provider;

/**
 Notifies the project that is is dirty.
 */
- (void)notifyProjectDidBecomeDirty;

/**
 Returns the list of errors.
 */
- (NSArray *)errors;

/**
 Notifies that an exception occurred.
 */
- (void)notifyException:(NSException *)exception;

/**
 Notifies that an error occurred.
 */
- (void)notifyError:(NSError *)error;

/**
 Returns the list of warnings.
 */
- (NSArray *)warnings;

/**
 Notifies that a warning occurred. The operation will continue.
 */
- (void)notifyWarning:(NSError *)error;

/**
 Returns the list of alerts.
 */
- (NSArray *)alerts;

/**
 Reports an information that is going to be displayed in an alert.
 */
- (void)reportInformativeAlertWithTitle:(NSString *)title message:(NSString *)message;

#pragma mark Subclass

/**
 Execute this operation. The subclass must override this method.
 */
- (void)execute;

/**
 This method is called when the execution is about to start.
 Note: it is invoked on the main thread.
 */
- (void)willExecute;

/**
 This method is called when the execution completed, even in case of an exception.
 Note: it is invoked on the main thread.
 */
- (void)didExecute;

/**
 Returns true if the operation can be cancelled.
 */
- (BOOL)cancellable;

@end
