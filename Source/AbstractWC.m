//
//  AbstractWC.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"


@implementation AbstractWC

@synthesize didCloseCallback;

- (id)initWithWindowNibName:(NSString*)name
{
    if(self = [super initWithWindowNibName:name]) {
        [self window];
        mParentWindow = NULL;
        mDidOKSelector = NULL;
        mDidOKTarget = NULL;
        mDidCloseSelector = NULL;
        mDidCloseTarget = NULL;
        mHideCode = 0;
        mClosed = YES;
    }
    return self;
}

- (void)setParentWindow:(NSWindow*)window
{
    mParentWindow = window;
}

- (NSWindow*)parentWindow
{
    return mParentWindow;
}

- (IBAction)cancel:(id)sender
{
    [self hideWithCode:0];
}

- (IBAction)ok:(id)sender
{
    [self hideWithCode:1];
}

- (int)hideCode
{
    return mHideCode;
}

- (void)setDidOKSelector:(SEL)selector target:(id)target
{
    mDidOKSelector = selector;
    mDidOKTarget = target;
}

- (void)setDidCloseSelector:(SEL)selector target:(id)target
{
    mDidCloseSelector = selector;
    mDidCloseTarget = target;
}

- (void)willShow
{
    
}

- (void)didShow
{
    
}

- (void)willHide
{
    
}

- (void)showAsSheet
{
    [self willShow];
    mClosed = NO;
    [NSApp beginSheet:[self window] modalForWindow:mParentWindow modalDelegate:self didEndSelector:NULL contextInfo:NULL];
    [self performSelector:@selector(didShow) withObject:NULL afterDelay:0];
}

- (void)showAndCenter:(BOOL)center
{
    [self willShow];
    mClosed = NO;
    if(center) {
        [[self window] center];        
    }
    [[self window] makeKeyAndOrderFront:self];    
}

- (void)show
{
    [self showAndCenter:YES];
}

- (void)showModal
{
    [self willShow];
    mClosed = NO;
    [[self window] center];
    [NSApp runModalForWindow:[self window]];
}

- (void)hide
{
    [self hideWithCode:0];
}

- (void)hideWithCode:(int)code
{
    mHideCode = code;
    
    if(!mClosed) {
        [self willHide];
        mClosed = YES;
        
        if([[self window] isSheet])
            [NSApp endSheet:[self window]];
        if([[self window] isModalPanel])
            [NSApp stopModalWithCode:mHideCode];
        
        [[self window] orderOut:self];
        
        if(mDidCloseSelector)
            [mDidCloseTarget performSelector:mDidCloseSelector withObject:NULL afterDelay:0];
        
        if(mDidOKSelector && [self hideCode] == 1)
            [mDidOKTarget performSelector:mDidOKSelector withObject:NULL afterDelay:0];        
        
        if(self.didCloseCallback) {
            self.didCloseCallback();
        }
    }
}

- (BOOL)isVisible
{
    return [[self window] isVisible];
}

@end
