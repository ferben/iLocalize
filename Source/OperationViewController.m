//
//  OperationViewController.m
//  iLocalize
//
//  Created by Jean Bovet on 2/11/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "OperationDriverWC.h"
#import "OperationWindowController.h"

@implementation OperationViewController

@synthesize bypass;

+ (id)createInstance
{
	return [[self alloc] init];
}

- (id)initWithNibName:(NSString*)name
{
	if((self = [super initWithNibName:name bundle:nil])) {
	}
	return self;
}


- (NSArray*)errors
{
	return nil;
}

- (NSArray*)warnings
{
	return nil;
}

- (NSArray*)alerts
{
	return nil;
}

- (NSDictionary*)arguments
{
	return self.driverWC.driver.arguments;
}

- (NSWindow*)visibleWindow
{
    return [self.driverWC visibleWindow];
}

- (NSWindow*)window
{
    return [self.driverWC window];
}

- (NSSize)viewSize
{
	return self.view.frame.size;
}

- (BOOL)canResize
{
	return YES;
}

- (NSString*)nextButtonTitle
{
	return NSLocalizedString(@"Next", nil);
}

- (BOOL)canGoBack
{
	return YES;
}

- (BOOL)canContinue
{
	return YES;
}

- (void)stateChanged
{
	[self.driverWC viewControllerStateChanged:self];		
	[self.windowController viewControllerStateChanged:self];
}

- (void)beginResizing
{
	
}

- (void)endResizing
{
	
}

- (void)willShow
{
	
}

- (void)willCancel
{
	
}

- (void)validateContinue:(ValidateContinueCallback)callback
{
	callback(YES);
}

- (void)willContinue
{
	
}

- (void)runModalOperationViewController:(OperationViewController*)vc
{
	OperationWindowController *wc = [[OperationWindowController alloc] init];
	wc.viewController = vc;
	[wc runModalSheetForWindow:[self window]];
}

@end
