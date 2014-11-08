//
//  OperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"
#import "OperationDriverWC.h"
#import "OperationViewController.h"
#import "Operation.h"
#import "OperationDispatcher.h"
#import "OperationProgressViewController.h"
#import "OperationErrorViewController.h"
#import "Stack.h"
#import "OperationWC.h"
#import "Operation.h"
#import "ProjectWC.h"

@interface OperationDriver (PrivateMethods)
- (void)executeOp:(id)op;
- (void)operationDidExecute:(id)op action:(NSUInteger)action;
@end

@implementation OperationDriver

@synthesize currentOperation;
@synthesize arguments;

+ (OperationDriver*)driverWithProjectProvider:(id<ProjectProvider>)provider
{
	OperationDriver *driver = [[self alloc] init];
	driver.provider = provider;
	return driver;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		opWC = [[OperationDriverWC alloc] init];
		opWC.driver = self;
		dispatcher = [[OperationDispatcher alloc] init];
		[[opWC window] setTitle:[self windowTitle]];		
	}
	return self;
}


- (NSString*)windowTitle
{
	return @"";
}

- (BOOL)isAssistant
{
	return NO;
}

- (id)operationForState:(int)state
{
	return nil;
}

- (int)previousState:(int)state
{
	return STATE_ERROR;
}

- (int)nextState:(int)state
{
	return STATE_ERROR;
}

- (void)operationCancel
{
	[opWC hide];
	self.currentOperation = nil;
}

- (void)operationGoBack
{
	int oldState = currentState;
	currentState = [self previousState:currentState];
	switch (currentState) {
		case STATE_INITIAL:
			[opWC setCanGoBack:NO];
			break;
			
		case STATE_END:
			[opWC setCanGoBack:NO];
			break;
			
		case STATE_ERROR:
			NSLog(@"Error: previous state is ERROR while old state was %d", oldState);
			break;
			
		default:
			[self executeOp:[self operationForState:currentState]];
			break;
	}
	[opWC setCanGoBack:[self previousState:currentState] != STATE_END];
}

- (void)operationNext
{
	int oldState = currentState;
	currentState = [self nextState:currentState];
	switch (currentState) {
		case STATE_INITIAL:
			break;
			
		case STATE_END:
			// no more operation, we are done.
			[self operationCancel];
			break;
			
		case STATE_ERROR:
			NSLog(@"Error: next state is ERROR while old state was %d", oldState);
			break;
			
		default:
			[self executeOp:[self operationForState:currentState]];
			break;
	}
	// Can go back only if there is a previous state and that the current operation
	// is not a progress operation.
	[opWC setCanGoBack:[self previousState:currentState] != STATE_END && [self.currentOperation isKindOfClass:[OperationViewController class]]];
}

- (OperationViewController*)errorOVC:(id)op
{
	OperationErrorViewController *vc = [OperationErrorViewController createInstance];
	[vc setLastOperation:[self nextState:currentState] == STATE_END];
	[vc addErrors:[op errors]];
	[vc addWarnings:[op warnings]];
	[opWC setCanGoBack:YES];
	return vc;
}

- (void)displayAlerts:(NSArray*)alerts
{
     // retain the operation driver because it might be released during the time the alert is displayed
    NSDictionary *dic = [alerts firstObject];
    NSAlert *alert = [NSAlert alertWithMessageText:dic[@"title"]
                                     defaultButton:NSLocalizedString(@"OK", nil)
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", dic[@"message"]];
    [alert beginSheetModalForWindow:[opWC visibleWindow]
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:(void*)CFBridgingRetain(self)];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self operationNext];
}

- (void)operationDidExecute:(id)op action:(NSUInteger)action
{
    if([[op alerts] count] > 0) {
        [self displayAlerts:[op alerts]];
    } else if([[op errors] count] > 0 || [[op warnings] count] > 0) {
		[self executeOp:[self errorOVC:op]];
	} else {
		switch (action) {
			case OPERATION_CANCEL:		
				[self operationCancel];
				break;
			case OPERATION_GO_BACK:					
				[self operationGoBack];
				break;
			case OPERATION_NEXT:		
				[self operationNext];
				break;
			default:
				NSLog(@"Unknown operation action %lu", (unsigned long) action);
				[self operationCancel];
				break;
		}			
	}
}

- (void)execute
{
    currentState = STATE_INITIAL;
    
    [self validate:^{
        [self operationNext];
    }];
}

- (void)executeWithArguments:(NSDictionary*)args
{
	self.arguments = args;
	[self execute];
}

- (void)validate:(dispatch_block_t)continueBlock
{
    continueBlock();
}

/**
 This hack is to ensure that the old OperationWC notifies the new Operation when
 it progresses. This is because some old operations might be invoked from the new Operation
 so until we get rid of all the old operations, we need this hack.
 */
- (void)setInstallOldOperationWCHack:(BOOL)install operation:(Operation*)op
{
	OperationWC *oldOpWC = [self.provider operation];
	if(install) {
		oldOpWC.operation = op;
	} else {
		oldOpWC.operation = nil;
	}
}

- (void)notifyNewProjectProvider:(id<ProjectProvider>)provider
{
	self.provider = provider;
	[self setInstallOldOperationWCHack:YES operation:self.currentOperation];
}

- (void)disconnectInterface
{
	[self.provider.projectWC performSelectorOnMainThread:@selector(disconnectInterface) withObject:nil waitUntilDone:YES];
}

- (void)reconnectInterface
{
	[self.provider.projectWC performSelectorOnMainThread:@selector(connectInterface) withObject:nil waitUntilDone:YES];	
	[self.provider.projectWC performSelectorOnMainThread:@selector(refreshStructure) withObject:nil waitUntilDone:YES];	
	[self.provider.projectWC performSelectorOnMainThread:@selector(updateProjectStatus) withObject:nil waitUntilDone:YES];	
	[self.provider.projectWC performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:YES];	
}

typedef void(^Block)();

- (void)executeOp:(id)op
{
	// Need to retain the operation
	self.currentOperation = op;

	if(op == nil) {
		[self operationDidExecute:op action:OPERATION_NEXT];
		return;
	}

	if([op isKindOfClass:[OperationViewController class]]) {
		((OperationViewController*)op).driverWC = opWC;
		((OperationViewController*)op).projectProvider = self.provider;
		opWC.showControls = YES;
		opWC.parentWindow = [[self.provider projectWC] window];
		[opWC show:op callback:^(NSUInteger action) {
			[self operationDidExecute:op action:action];
		}];
	} else if([op isKindOfClass:[Operation class]]) {
		((Operation*)op).driver = self;
		((Operation*)op).projectProvider = self.provider;
		
		// Create a timer that will display the operation view controller only if the operation lasts more than 0.5 seconds.
		OperationProgressViewController *ovc = [OperationProgressViewController createWithOperation:op];
		opWC.parentWindow = [[self.provider projectWC] window];
		
		NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(showOperationProgressViewControllerFired:) userInfo:ovc repeats:NO];
		NSDate *startDate = [NSDate date];
		
		if(self.provider) {
			// Install the hack now if the project provider is available. Otherwise, it will be installed
			// later on in notifyNewProjectProvider.
			[self setInstallOldOperationWCHack:YES operation:op];			
		}
		
		if([op needsDisconnectInterface]) {
			[self disconnectInterface];			
		}
		// Invoke willExecute on the main thread.
		[op performSelectorOnMainThread:@selector(willExecute) withObject:nil waitUntilDone:YES];
		
		// Dispatch the operation for execution
		dispatcher.projectProvider = self.provider;
		[dispatcher dispatch:op callback:^(NSUInteger action) {
			// This block contains the code that will complete the operation.
			Block block = ^ void() {
				[self setInstallOldOperationWCHack:NO operation:op];
				if([op needsDisconnectInterface]) {
					[self reconnectInterface];			
				}				
				// Invoke didExecute on the main thread.
				[op performSelectorOnMainThread:@selector(didExecute) withObject:nil waitUntilDone:YES];
				[self operationDidExecute:op action:action];
			};
			
			if([t isValid]) {
				// If the timer hasn't fired yet, invalidate it so the progress view controller doesn't show up.
				[t invalidate];
				// Execute the completion block.
				block();
			} else {
				// However, if it is already invalidated, then the progress view controller is displayed.
				// Make sure that the view is displayed for at least 2 seconds before continuing in order
				// to avoid the rapid transition from one view controller to another if the operation executes
				// under 2 seconds.
				NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
				
				// Compute how much time left we need to leave the view.
				NSTimeInterval remainingTime = MAX(0, 2 - elapsedTime);
								
				// The completion block will be executed later on.
				[self performSelector:@selector(operationDidComplete:) withObject:[block copy] afterDelay:remainingTime];
			}

		}];
	} else {
		NSLog(@"Unknown operation %@", op);
	}
}

- (void)showOperationProgressViewControllerFired:(NSTimer*)timer
{
	// Create the operation view controller that will display the progress of the operation
	OperationProgressViewController *ovc = [timer userInfo];
	opWC.showControls = NO;
	[opWC show:ovc callback:nil];	
}

- (void)operationDidComplete:(Block)block
{
	block();
}

@end
