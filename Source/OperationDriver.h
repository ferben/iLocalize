//
//  OperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

// Constants for the results of the operation
#define OPERATION_CANCEL 0
#define OPERATION_GO_BACK 1
#define OPERATION_NEXT 2

// Constants for the states of the state machine driver.
// Error
#define STATE_ERROR -1
// Initial state
#define STATE_INITIAL -2
// End state (no state will follow)
#define STATE_END -3

typedef void(^OperationCompletionCallbackBlock)(NSUInteger action);

@class Operation;
@class OperationDriverWC;
@class OperationDispatcher;

/**
 This class drives the sequence of operations, invoking one operation at a time
 and displaying the corresponding view for each operation.
 
 This class must be subclassed to provide the sequence of operations by 
 overriding the method nextOperation.
 */
@interface OperationDriver : NSObject {
    OperationDriverWC *opWC;
    OperationDispatcher *dispatcher;
    
    // Current operation (can be an Operation or an OperationVC
    id currentOperation;
    
    // Current state of the driver. This state will transition to other states,
    // as defined by the subclass of this driver.
    int currentState;
    
    // The optional arguments
    NSDictionary *arguments;
}

@property (weak) id<ProjectProvider> provider;
@property (strong) id currentOperation;
@property (strong) NSDictionary *arguments;

+ (OperationDriver*)driverWithProjectProvider:(id<ProjectProvider>)provider;

/**
 Returns the title of the window.
 */
- (NSString*)windowTitle;

/**
 Returns YES if this driver is a driver for an assistant. The iLocalize icon
 will be displayed on the left-side of all the views.
 */
- (BOOL)isAssistant;

/**
 This method returns the operation corresponding to the specified state.
 
 Note: this method must be overriden by the subclass.
 */
- (id)operationForState:(int)state;

/**
 This method returns the previous state of the driver for the specified state.
 
 Note: this method must be overriden by the subclass.
 */
- (int)previousState:(int)state;

/**
 This method returns the next state of the driver for the specified state.
 
 Note: this method must be overriden by the subclass.
 */
- (int)nextState:(int)state;

/**
 This method is invoked when the operation is cancelled.
 */
- (void)operationCancel;

/**
 Executes the sequence of operation.
 */
- (void)execute;

/**
 Executes the sequence of operation with the specified arguments.
 The arguments will be available in all the OperationViewController.
 */
- (void)executeWithArguments:(NSDictionary*)args;

/**
 This method is invoked once before the driver executes
 to give a chance to the driver implementation to validate
 any state needed.
 @param continueBlock The block to invoke to continue the driver operation
 */
- (void)validate:(dispatch_block_t)continueBlock;

- (void)notifyNewProjectProvider:(id<ProjectProvider>)_provider;

@end
