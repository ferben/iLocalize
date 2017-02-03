//
//  OperationWC.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@class Stack;
@class Operation;

@interface OperationWC : AbstractWC
{
	IBOutlet NSTextField			*mTitleField;
	IBOutlet NSTextField			*mInfoField;
	IBOutlet NSProgressIndicator	*mProgressIndicator;
	IBOutlet NSButton				*mCancelButton;
        
	BOOL							mShouldCancel;
	Stack							*mIndeterminateStack;
}

// New operation dialogs are using this instance
// instead of this OperationWC. So we need to
// redirect the increment from this OperationWC instance
// to the new operation instance so the new progress view
// gets refreshed.
@property (weak) Operation *operation;

- (void)setTitle:(NSString *)title;
- (void)setProgress:(float)progress;

- (void)setIndeterminate:(BOOL)flag;
- (BOOL)isIndeterminate;

- (void)pushIndeterminate:(BOOL)flag;
- (void)popIndeterminate;

- (void)setCancellable:(BOOL)flag;
- (BOOL)shouldCancel;

- (void)setMaxSteps:(NSUInteger)steps;
- (void)increment;

- (IBAction)cancel:(id)cancel;

@end
