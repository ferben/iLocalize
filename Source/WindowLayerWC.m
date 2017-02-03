//
//  WindowLayerWC.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "WindowLayerWC.h"
#import "WindowLayerView.h"

@implementation WindowLayerWC

- (id)init
{
    if(self = [super initWithWindowNibName:@"WindowLayer"]) {
        [self window];
        mParentWindow = nil;
        mDelegate = nil;
    }
    return self;
}

- (void)setParentWindow:(NSWindow*)window
{
    mParentWindow = window;
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
}

- (void)setTitle:(NSString*)title
{
    [mView setTitle:title];    
}

- (void)setInfo:(NSString*)info
{
    [mView setInfo:info];
}

- (void)show
{
    if([[self window] isVisible])
        return;
    
    //[mParentWindow addChildWindow:[self window] ordered:NSWindowAbove];
    
    NSRect pf = [mParentWindow frame];
    NSRect cf = [[self window] frame];
    
    [[self window] setLevel:NSStatusWindowLevel];
    [[self window] setFrameOrigin:NSMakePoint(pf.origin.x+pf.size.width*0.5-cf.size.width*0.5, pf.origin.y+pf.size.height*0.5-cf.size.height*0.5)];
    [[self window] makeKeyAndOrderFront:self];    
    [[self window] setDelegate:mDelegate];
}

- (void)hide
{
    if([[self window] isVisible] == NO)
        return;
    
    //[mParentWindow removeChildWindow:[self window]];
    [[self window] orderOut:self];        
}

@end
