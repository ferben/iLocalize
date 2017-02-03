//
//  OperationWindowController.m
//  iLocalize
//
//  Created by Jean Bovet on 4/1/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationWindowController.h"
#import "OperationViewController.h"

@implementation OperationWindowController

@synthesize viewController;

- (id)init
{
    if(self = [super initWithWindowNibName:@"OperationWindowController"]) {
        [self loadWindow];
        originalContentMaxSize = [self.window contentMaxSize];
        
    }
    return self;
}


- (void)refresh
{
    NSSize viewSize = [self.viewController viewSize];
    NSRect windowContentRect = [self.window contentRectForFrameRect:self.window.frame];
    CGFloat oldHeight = windowContentRect.size.height;
    windowContentRect.size.width = viewSize.width;
    windowContentRect.size.height = box.frame.origin.y + viewSize.height;
    windowContentRect.origin.y -= windowContentRect.size.height - oldHeight;

    if([self.viewController canResize]) {
        [self.window setShowsResizeIndicator:YES];    
        [self.window setContentMaxSize:originalContentMaxSize];
    } else {
        [self.window setContentMinSize:windowContentRect.size];
        [self.window setContentMaxSize:windowContentRect.size];
        [self.window setShowsResizeIndicator:NO];
    }

    NSRect newFrameRect = [self.window frameRectForContentRect:windowContentRect];
    NSTimeInterval animationTime = [self.window animationResizeTime:newFrameRect];

    [self.viewController beginResizing];
    [self.viewController performSelector:@selector(endResizing) withObject:nil afterDelay:animationTime];
    [self.window setFrame:newFrameRect display:NO animate:YES];
}

- (void)viewControllerStateChanged:(OperationViewController*)_vc
{
    [self refresh];
}

- (void)runModalSheetForWindow:(NSWindow*)parent
{
    self.viewController.windowController = self;
    
    [self refresh];
    
    [box setContentView:self.viewController.view];
    [self.viewController willShow];
    [NSApp beginSheet:self.window
       modalForWindow:parent
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:(void*)CFBridgingRetain(self)];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
}

- (IBAction)done:(id)sender
{
    [NSApp endSheet:self.window];
    [self.window close];
}

@end
