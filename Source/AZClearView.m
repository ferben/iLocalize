//
//  AZClearView.m
//  iLocalize
//
//  Created by Jean Bovet on 3/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZClearView.h"


@implementation AZClearView

@synthesize yLine;

- (void)drawRect:(NSRect)rect
{
    [[NSColor windowBackgroundColor] set];
    NSRectFill(self.bounds);
    
    [NSBezierPath setDefaultFlatness: 1.0];
    [NSBezierPath setDefaultLineWidth:1.0];
    [[NSColor darkGrayColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0, self.bounds.size.height-yLine)
                              toPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height-yLine)];    
}

@end
