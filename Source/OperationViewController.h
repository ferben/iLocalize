//
//  OperationViewController.h
//  iLocalize
//
//  Created by Jean Bovet on 2/11/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

typedef void(^ValidateContinueCallback)(BOOL);

@class OperationWindowController;
@class OperationDriverWC;

/**
 This class represents a single operation view controller that 
 manages a single view.
 */
@interface OperationViewController : NSViewController {
    // If YES, this flag indicates that this view controlller should be bypassed,
    // that is, not made visible to user but to have its validateContinue to be invoked
    // in order to execute any validation code that is located in it.
    BOOL bypass;
}

// This view controller can either be in an operation window controller
@property (assign) OperationWindowController *windowController;
// Or in the standard operation driver window controller
@property (assign) OperationDriverWC *driverWC;

@property (weak) id<ProjectProvider> projectProvider;
@property BOOL bypass;

/**
 Creates new autoreleased instance.
 */
+ (id)createInstance;

/**
 Initialize the view controller with the given nib name
 */
- (id)initWithNibName:(NSString*)name;

/**
 Returns the arguments that were specified when launching the operation driver
 or null if no arguments.
 */
- (NSDictionary*)arguments;

/**
 Returns the visible window where this view is located. If this view is not visible (bypass), then
 the window is the project window.
 */
- (NSWindow*)visibleWindow;

/**
 Returns the window where this view is located
 */
- (NSWindow*)window;

/**
 Returns the size of the view.
 */
- (NSSize)viewSize;

/**
 Returns true if the view can resize
 */
- (BOOL)canResize;

/**
 Returns the title of the Next button. If nil is returned, the button will use
 its default name.
 */
- (NSString*)nextButtonTitle;

/**
 Returns YES if the Next button is enabled, NO to disable it. This method is invoked
 after the stateChanged() method is invoked.
 */
- (BOOL)canContinue;

/**
 Returns YES if the Go Back button is enabled, NO to disable it. This method is invoked
 after the stateChanged() method is invoked.
 */
- (BOOL)canGoBack;

/**
 Invoke this method to indicate that a state has changed. The canContinue() method will
 be invoked because of that.
 */
- (void)stateChanged;

/**
 Method invoked when the view begins to dynamically resize.
 */
- (void)beginResizing;

/**
 Method invoked when the view ends its dynamic resize.
 */
- (void)endResizing;

/**
 This method is invoked when the view is about to be displayed in the operation window.
 */
- (void)willShow;

/**
 This method is invoked when the user cancels the operation window when this view is presented.
 The view can take the opportunity to save its state at this point
 */
- (void)willCancel;

/**
 This method is invoked to validate the controller before continuing.
 The callback must be invoked.
 */
- (void)validateContinue:(ValidateContinueCallback)callback;

/**
 This method is invoked to ask the view if all the requirements are
 fullfiled so it can be closed (for the next view or operation to take place).
 */
- (void)willContinue;

/**
 Shows a modal sheet with the given operation view controller.
 */
- (void)runModalOperationViewController:(OperationViewController*)vc;

@end
