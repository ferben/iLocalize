//
//  OperationProgressViewController.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class Operation;

/**
 This class manages a view controller with a progress bar that is used
 to display the progress of an operation.
 */
@interface OperationProgressViewController : OperationViewController {
	IBOutlet NSTextField *nameField;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *cancelButton;
}

@property (weak) Operation *operation;

/**
 Creates a new instance of this view controller that will manage
 the progress of the specified operation.
 */
+ (OperationProgressViewController*)createWithOperation:(Operation*)op;

/**
 Sets the name of the operation.
 */
- (void)setOperationName:(NSString*)name;

/**
 Sets the progress of the operation, between 0 and 1.
 */
- (void)setOperationProgress:(float)progress;

/**
 Invoked by the user when he wants to cancel the operation.
 */
- (IBAction)cancel:(id)sender;

@end
