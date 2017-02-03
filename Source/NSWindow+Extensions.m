//
//  NSWindow+Extensions.m
//  iLocalize3
//
//  Created by Jean on 09.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSWindow+Extensions.h"


@implementation NSWindow (Extensions)

- (void)setContentView:(NSView*)view resize:(BOOL)resize animate:(BOOL)animate
{
    float deltaWidth = 0;
    float deltaHeight = 0;
    
    if(resize)
    {
        NSRect oldFrame = [[self contentView] frame];
        NSRect newFrame = [view frame];
        
        deltaWidth = newFrame.size.width-oldFrame.size.width;
        deltaHeight = newFrame.size.height-oldFrame.size.height;
    }
    
    [self setContentView:view];
    
    // Resize the window
    
    if(resize && (deltaWidth != 0 || deltaHeight != 0))
    {
        NSRect contentRect = [NSWindow contentRectForFrameRect:[self frame]
                                                     styleMask:[self styleMask]];
        
        contentRect.size.width += deltaWidth;
        contentRect.size.height += deltaHeight;
        
        NSRect newFrame = [NSWindow frameRectForContentRect:contentRect
                                                  styleMask:[self styleMask]];
        
        newFrame.origin.y -= deltaHeight;
        
        [self setFrame:newFrame display:YES animate:animate];
    }
}

@end
