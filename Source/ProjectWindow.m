//
//  ProjectWindow.m
//  iLocalize3
//
//  Created by Jean on 6/21/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "ProjectWindow.h"
#import "ProjectWindowProtocol.h"
#import "TooltipWindow.h"

@implementation ProjectWindow

- (void)awakeFromNib
{
    mTooltipWindow = nil;
    mTooltipDisplayed = NO;
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    mToolTipTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(toolTipTimerFired:) userInfo:nil repeats:YES];    
}


- (void)close
{
    [super close];

    [mToolTipTimer invalidate];
    mToolTipTimer = nil;

    [self hideTooltip];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [super mouseMoved:theEvent];
    mMouseDidMove = YES;
    mTooltipDisplayed = NO;
}

- (id<ProjectWindowProtocol>)windowDelegate
{
    return (id<ProjectWindowProtocol>)[self delegate];
}

#pragma mark -

- (void)showTooltip:(NSString*)tt
{
    if(mTooltipWindow == nil) {
        mTooltipWindow = [[TooltipWindow alloc] init];        
    }
    
    [mTooltipWindow setTooltip:tt];
    
    NSRect tipFrame;
    tipFrame.origin = [NSEvent mouseLocation];
    tipFrame.size = [TooltipWindow suggestedSizeForTooltip:tt];
    tipFrame.origin.y -= tipFrame.size.height + 20;                                
    
    [mTooltipWindow setFrame:tipFrame display:YES];
    [mTooltipWindow orderFrontWithDuration:5];                
}

- (void)hideTooltip
{
    if([mTooltipWindow isVisible]) {
        [mTooltipWindow close];        
    }    
}

- (void)toolTipTimerFired:(NSTimer*)timer
{
    if(mMouseDidMove) {
        mMouseDidMove = NO;
        return;
    }
    
    if(mTooltipDisplayed)
        return;
    
    mTooltipDisplayed = YES;
    
    if([[self delegate] respondsToSelector:@selector(toolTipAtPosition:)]) {
        NSString *tt = [[self windowDelegate] toolTipAtPosition:[self mouseLocationOutsideOfEventStream]];
        if(tt) {
            [self showTooltip:tt];
        } else {
            [self hideTooltip];
        }
    }
}

#pragma mark -

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if([[self delegate] respondsToSelector:@selector(windowDragOperationEnteredForPasteboard:)])
        return [[self windowDelegate] windowDragOperationEnteredForPasteboard:pboard];
    else
        return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if([[self delegate] respondsToSelector:@selector(windowDragOperationUpdatedForPasteboard:)])
        return [[self windowDelegate] windowDragOperationUpdatedForPasteboard:pboard];
    else
        return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender 
{
    if([[self delegate] respondsToSelector:@selector(windowTableViewDragOperationEnded)])
        [[self windowDelegate] windowTableViewDragOperationEnded];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if([[self delegate] respondsToSelector:@selector(windowDragOperationPerformWithPasteboard:)])
        return [[self windowDelegate] windowDragOperationPerformWithPasteboard:pboard];
    else
        return NO;
}

@end
