//
//  ProjectDetailsController.m
//  iLocalize
//
//  Created by Jean on 12/29/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetailsController.h"
#import "ProjectDetails.h"
#import "ProjectDetailsProject.h"
#import "ProjectDetailsFile.h"
#import "ProjectDetailsString.h"
#import "ProjectDetailsGlossary.h"
#import "ProjectDetailsAlternate.h"

#import "AZSplitView.h"

@interface ProjectDetailsController (PrivateMethods)
- (ProjectDetails *)projectDetailsAtIndex:(NSInteger)index;
- (void)executeNextToggleRequest;
- (void)toggleRequestFinished;
@end

@implementation ProjectDetailsController

@synthesize projectWC;
@synthesize splitView;
@synthesize containerView;
@synthesize currentToggleRequest;

+ (ProjectDetailsController*)newInstance:(ProjectWC*)projectWC
{
	ProjectDetailsController *controller = [[ProjectDetailsController alloc] initWithNibName:@"ProjectViewDetails" bundle:nil];
	controller.projectWC = projectWC;
	return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		mProjectDetails = [[NSMutableDictionary alloc] init];		
		mCurrentDetailsView = nil;
		detailsIndex = -1;
		lastDetailsIndex = -1;
		toggleRequests = [[NSMutableArray alloc] init];
		self.currentToggleRequest = nil;
	}
	return self;
}

- (void)awakeFromNib
{
	// Deselect all the buttons
	[mButtonMatrix deselectAllCells];
	
	// Load all the details and add their view
	[containerView setAutoresizesSubviews:YES];
	for(int i=0; i<5; i++) {
		ProjectDetails *pd = [self projectDetailsAtIndex:i];
		[pd.view setFrameSize:containerView.frame.size];
		[containerView addSubview:pd.view];
		[pd.view setHidden:YES];
	}
	
	// Show the glossary view
	[self showDetailsAtIndex:0];
}

- (void)dealloc
{
	[mProjectDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[obj close];
	}];
}

- (NSView*)buttonView
{
	return mButtonMatrix;
}

- (NSArray*)keyViews
{
    NSMutableArray *keyViews = [NSMutableArray array];
    for(int i=0; i<5; i++) {
		ProjectDetails *pd = [self projectDetailsAtIndex:i];
        if([pd keyView]) {
            [keyViews addObject:[pd keyView]];            
        }
    }
    return keyViews;
}

- (ProjectDetails*)projectDetailsAtIndex:(NSInteger)index
{
	ProjectDetails *details = mProjectDetails[@(index)];

    if (!details)
    {
		switch (index)
        {
			case 0:
				details = [[ProjectDetailsGlossary alloc] initWithNibName:@"ProjectInfoViewGlossary" bundle:nil];
				details.title = NSLocalizedString(@"Glossaries Translations", nil);				
				break;
			case 1:
				details = [[ProjectDetailsAlternate alloc] initWithNibName:@"ProjectInfoViewAlternate" bundle:nil];
				details.title = NSLocalizedString(@"Alternate Translations", nil);				
				break;
			case 2:
				details = [[ProjectDetailsString alloc] initWithNibName:@"ProjectInfoViewString" bundle:nil];
				details.title = NSLocalizedString(@"String Information", nil);				
				break;
			case 3:
				details = [[ProjectDetailsFile alloc] initWithNibName:@"ProjectInfoViewFile" bundle:nil];
				details.title = NSLocalizedString(@"File Information", nil);				
				break;
			case 4:
				details = [[ProjectDetailsProject alloc] initWithNibName:@"ProjectInfoViewProject" bundle:nil];
				details.title = NSLocalizedString(@"Project Information", nil);				
				break;
		}
		
        if (details)
        {
			details.projectWC = self.projectWC;
			mProjectDetails[@(index)] = details;
		}
	}

    return details;
}

#pragma mark -

- (void)update
{
	if([NSThread isMainThread]) {
		[mProjectDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[obj update];
		}];		
	} else {
		[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
	}	
}

- (void)showInfoView:(CallbackBlock)block
{
	[splitView collapse:NO animation:YES completionBlock:block];
}

- (void)hideInfoView:(CallbackBlock)block
{
	[splitView collapse:YES animation:YES completionBlock:block];
}

- (void)showDetailsAtIndex:(int)index
{
	// index already visible?
	if(detailsIndex == index) return;
	
	[mButtonMatrix selectCellAtRow:0 column:index];
	[self toggleButton:mButtonMatrix];
}

- (void)hideDetailsAtIndex:(int)index
{
	// index already hidden?
	if(detailsIndex != index) return;
	
	[mButtonMatrix deselectAllCells];	
	[self toggleButton:mButtonMatrix];
}

- (BOOL)isDetailsVisibleAtIndex:(int)index
{
	return detailsIndex == index;
}

- (BOOL)canExecuteCommand:(SEL)command
{
    return [[self projectDetailsAtIndex:detailsIndex] canExecuteCommand:command];
}

- (void)executeCommand:(SEL)command
{
    [[self projectDetailsAtIndex:detailsIndex] executeCommand:command];
}

- (void)executeToggleRequest
{
	detailsIndex = [mButtonMatrix selectedColumn];	
	if(lastDetailsIndex != detailsIndex) {
		lastDetailsIndex = detailsIndex;
	} else {
		lastDetailsIndex = -1;
		detailsIndex = -1;
		[mButtonMatrix performSelector:@selector(deselectAllCells) withObject:nil afterDelay:0];
	}
	
	ProjectDetails *pd = [self projectDetailsAtIndex:detailsIndex];
	if(pd) {
		// Hide the previous view
		[mCurrentDetailsView setHidden:YES];
        [[self projectDetailsAtIndex:lastDetailsIndex] didHide];
		
		// Set the new view
		mCurrentDetailsView = [pd view];
		
		// And make it visible
		[mCurrentDetailsView setHidden:NO];
		
		splitView.title = [pd title];
		splitView.actionMenu = [pd actionMenu];
		[splitView setNeedsDisplay:YES];
		
		// Indicate to the view that it will become visible
		[pd willShow];		
		
		// show the details and set the resizable flag after the animation completes
		[self showInfoView:^() {
			[pd setResizableFlag:YES];
			[self toggleRequestFinished];
		}];		
	} else {
		// Make sure all the details are properly notified of the fact that the details view is being collapsed.
		[mProjectDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[obj willHide];
			[obj setResizableFlag:NO];				
		}];
		[self hideInfoView:^() {
            [mProjectDetails enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [obj didHide];
            }];
			[self toggleRequestFinished];
		}];
	}		
}

- (void)toggleRequestFinished
{
	@synchronized(toggleRequests) {
		self.currentToggleRequest = nil;
		[self executeNextToggleRequest];
	}
}

- (void)executeNextToggleRequest
{
	@synchronized(toggleRequests) {
		if(self.currentToggleRequest == nil) {
			self.currentToggleRequest = [toggleRequests firstObject];
            [toggleRequests removeFirstObject];
			if(self.currentToggleRequest) {
				[self executeToggleRequest];
			}
		}
	}
}

- (IBAction)toggleButton:(id)sender
{
	@synchronized(toggleRequests) {
		[toggleRequests addObject:[NSNull null]];
	}
	[self executeNextToggleRequest];
}

@end
