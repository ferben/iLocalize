//
//  OperationDriverWC.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriverWC.h"
#import "OperationViewController.h"
#import "OperationProgressViewController.h"
#import "OperationDriver.h"
#import "Operation.h"

@implementation OperationDriverWC

@synthesize showControls;
@synthesize vc;
@synthesize callback;

- (id)init
{
	if((self = [super initWithWindowNibName:@"OperationDriver"])) {
		assistantInPlace = NO;
	}
	return self;
}


- (void)awakeFromNib
{
	boxOriginY = box.frame.origin.y;
	controlsHeight = boxOriginY;
	originalMinSize = [self.window minSize];
	[self setCanGoBack:NO];
}

- (void)cancelOperation
{
	[self.vc willCancel];
	self.callback(OPERATION_CANCEL);
}

- (void)windowWillClose:(NSNotification *)notif
{
	if([notif object] == [self window]) {
		[self cancelOperation];
	}
}

- (BOOL)isControlsHidden
{
	return [cancelButton isHidden];
}

- (void)setCanGoBack:(BOOL)flag
{
	canGoBack = flag;
	[goBackButton setEnabled:flag];
}

- (NSImage*)assistantImage
{
	return [NSImage imageNamed:@"GlobeAssistant"];
}

- (BOOL)isProgressView
{
	return [vc isKindOfClass:[OperationProgressViewController class]];
}

- (void)prepareAssistantWindow
{
	if(!self.driver.isAssistant) return;
	
	if(assistantInPlace) return;
	assistantInPlace = YES;
	
	NSImage *assistantImage = [self assistantImage];
	NSSize assistantImageSize = [assistantImage size];
	
	NSRect imageViewFrame = NSZeroRect;
	imageViewFrame.origin.x = 0;
	imageViewFrame.origin.y = [[self.window contentView] frame].size.height-assistantImageSize.height;
	imageViewFrame.size = assistantImageSize;
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageViewFrame];
	[imageView setAutoresizingMask:NSViewMinYMargin];
	[imageView setImageAlignment:NSImageAlignTopLeft];
	[imageView setImageFrameStyle:NSImageFrameNone];
	[imageView setImage:assistantImage];
	
	// Add the image view under the box
	[[[self window] contentView] addSubview:imageView positioned:NSWindowBelow relativeTo:box];
	
	// Resize the box
	int offsetWidth = 147; // offset to move the box up to the point where the image is faded.
	[box setFrame:NSMakeRect(offsetWidth, boxOriginY, box.frame.size.width-offsetWidth, box.frame.size.height)];
	
	NSPoint cancelOrigin = cancelButton.frame.origin;
	cancelOrigin.x += offsetWidth - cancelOrigin.x;
	[cancelButton setFrameOrigin:cancelOrigin];
}

- (void)prepareWindowLayout
{
	// Only prepare if the control states have changed.
	if(!self.showControls && [self isControlsHidden]) {
		return;
	}
	
	// The window content frame
	NSRect windowContentFrame = [self.window contentRectForFrameRect:self.window.frame];

	// The size of the view to show in the box
	NSSize viewSize = [self.vc viewSize];

	// Compute the size of the box
	NSRect boxFrame = box.frame;	
	CGFloat boxDeltaHeight;
	if(self.showControls) {
		boxDeltaHeight = boxFrame.origin.y - boxOriginY;
		boxFrame.origin.y = boxOriginY;
	} else {
		int offset = 5;
		boxDeltaHeight = boxFrame.origin.y - (-offset);
		boxFrame.origin.y = -offset;
	}
	boxFrame.size.height += boxDeltaHeight;
	[box setFrame:boxFrame];
	
	// First let's define the minimum height of the window content
	CGFloat minWindowContentHeight = 80; 
	if(self.driver.isAssistant) {
		if(self.showControls) {
			minWindowContentHeight = MAX(minWindowContentHeight, [self assistantImage].size.height + controlsHeight + 20);			
		} else {
			minWindowContentHeight = MAX(minWindowContentHeight, [self assistantImage].size.height + 20);
		}
	}

	// Compute the width of the window content
	CGFloat windowContentWidth;
	if([self isProgressView]) {
		windowContentWidth = windowContentFrame.size.width;
	} else {
		windowContentWidth = box.frame.origin.x + viewSize.width;		
	}
		
	// Compute the height of the window content
	CGFloat windowContentHeight;
	if (self.showControls) {
		windowContentHeight = viewSize.height + controlsHeight;
	} else {
		windowContentHeight = viewSize.height;
	}
	windowContentHeight = MAX(windowContentHeight, minWindowContentHeight);
		
	windowContentFrame.size.width = windowContentWidth;
	windowContentFrame.size.height = windowContentHeight;
	
	// Compute the frame size of the window based on the content size
	NSRect windowFrame = [self.window frameRectForContentRect:windowContentFrame];
	
	// Adjust the position of the window so it stays at the same place on the screen
	CGFloat deltaY = self.window.frame.size.height - windowFrame.size.height;
	windowFrame.origin.y += deltaY;
	
	// Resizable of the window
	[[self window] setShowsResizeIndicator:![self isProgressView]];

	// Visibility of the controls;
	[cancelButton setHidden:!self.showControls];
	[goBackButton setHidden:!self.showControls];
	[nextButton setHidden:!self.showControls];
	
	// Resize the window
	[[self window] setMinSize:windowFrame.size];
	[[self window] setFrame:windowFrame display:YES animate:YES];
}

- (void)show:(OperationViewController*)_vc callback:(OperationCompletionCallbackBlock)_callback
{
	// Remove the content view because it looks weird when the window resizes
	// Note: do it now because removing the view will deallocate stuff in the previous self.vc
	[box setContentView:nil];

	// 
	self.vc = _vc;
	self.callback = _callback;
	
	// Note: trigger the loadView if it was not already done so (it is done already in OperationProgressViewController for example.
	[self.vc view]; 
	[self.vc willShow];
	[self.vc stateChanged];
	
	// Resize the window to fit the new view
	[self prepareAssistantWindow];
	[self prepareWindowLayout];

	// Set the new view
	[box setContentView:self.vc.view];

	// Show the window
	if(![self isVisible]) {
        if(self.vc.bypass) {
            [self operationNext:self];
        } else {
            if(self.parentWindow != nil) {
                [self showAsSheet];
            } else {
                [self showAndCenter:![self isVisible]];
            }		            
        }
	}
}

- (void)viewControllerStateChanged:(OperationViewController*)_vc
{
	if(canGoBack) {
		[goBackButton setEnabled:[_vc canGoBack]];		
	} else {
		[goBackButton setEnabled:NO];
	}

	[nextButton setTitle:[_vc nextButtonTitle]];
	[nextButton setEnabled:[_vc canContinue]];
}

- (NSWindow*)visibleWindow
{
    NSWindow *w = [self window];
    if(![w isVisible]) {
        w = [self parentWindow];
    }
    return w;
}

- (IBAction)operationCancel:(id)sender
{
	[self hide];
	[self cancelOperation];
}

- (IBAction)operationGoBack:(id)sender
{
	[self.vc willCancel];
	self.callback(OPERATION_GO_BACK);	
}

- (IBAction)operationNext:(id)sender
{
	[self.vc validateContinue:^(BOOL ok) {
		if(ok) {
			[self.vc willContinue];
            self.callback(OPERATION_NEXT);						            
		}
	}];
}

@end
