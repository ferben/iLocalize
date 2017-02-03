//
//  NSView+Extensions.m
//  iLocalize
//
//  Created by Jean Bovet on 4/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "NSView+Extensions.h"


@implementation NSView (Extensions)

- (void)setContentView:(NSView*)view
{
    // remove old view
    [[[self subviews] firstObject] removeFromSuperview];

    // Make sure the view can auto-resize
    [view setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];

    // set the view frame
    NSRect f = self.frame;
    f.origin.x = 0;
    f.origin.y = 0;
    [view setFrame:f];

    // add new view
    [self addSubview:view];    
}

@end
