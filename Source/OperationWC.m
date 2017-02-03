//
//  OperationWC.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationWC.h"
#import "Stack.h"
#import "Operation.h"

@implementation OperationWC

- (id)init
{
	if (self = [super initWithWindowNibName:@"Operation"])
    {
		[self window];
		mShouldCancel = NO;
		mIndeterminateStack = [[Stack alloc] init];
	}
	
    return self;
}


- (void)setTitle:(NSString *)title
{
	[mTitleField setStringValue:title];
	[mTitleField display];
}

- (void)setInfo:(NSString *)info
{
	// If called from another thread, perform the update on the main thread:
	// we are sure it will be correctly updated!
	[mInfoField performSelectorOnMainThread:@selector(setStringValue:)
								 withObject:info
							  waitUntilDone:YES];
	[mInfoField display];
}

- (void)setProgress:(float)progress
{
	[mProgressIndicator setDoubleValue:progress];
}

- (void)setIndeterminate:(BOOL)flag
{
	[mProgressIndicator setUsesThreadedAnimation:flag];
	[mProgressIndicator setIndeterminate:flag];
}

- (BOOL)isIndeterminate
{
	return [mProgressIndicator isIndeterminate];
}

- (void)pushIndeterminate:(BOOL)flag
{
	[mIndeterminateStack pushObject:@([self isIndeterminate])];
	[self setIndeterminate:flag];
}

- (void)popIndeterminate
{
	NSNumber *flag = [mIndeterminateStack popObject];
    
	if (flag)
    {
		[self setIndeterminate:[flag boolValue]];
	}
}

- (void)setCancellable:(BOOL)flag
{
	NSRect frame = [[self window] frame];
    
	if (flag)
    {
		frame.size.height = 128+20;
	}
    else
    {
		frame.size.height = 86+20;
	}
	
	[[self window] setFrame:frame display:YES];
	[mCancelButton setHidden:!flag];
}

- (BOOL)shouldCancel
{
	if (self.operation.cancel)
    {
		return YES;
	}
	
    if (![mCancelButton isHidden])
		return mShouldCancel;
	else
		return NO;
}

- (void)setMaxSteps:(NSUInteger)steps
{
	[mProgressIndicator setDoubleValue:0];
	[mProgressIndicator setMinValue:0];
	[mProgressIndicator setMaxValue:steps];
	[self setIndeterminate:NO];
}

- (void)increment
{
	[self.operation progressIncrement];
	[mProgressIndicator incrementBy:1];
	[mProgressIndicator display];
}

- (void)willShow
{
	mShouldCancel = NO;
	[mProgressIndicator startAnimation:self];
}

- (void)willHide
{
	[mProgressIndicator stopAnimation:self];
}

- (IBAction)cancel:(id)cancel
{
	mShouldCancel = YES;
}

@end
