//
//  AZVerticalLineView.m
//  iLocalize
//
//  Created by Jean Bovet on 3/18/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZVerticalLineView.h"


@implementation AZVerticalLineView

- (void)drawRect:(NSRect)rect
{
    [NSBezierPath setDefaultFlatness: 1.0];
    [NSBezierPath setDefaultLineWidth:1.0];
    [[NSColor blackColor] set];
    [NSBezierPath strokeLineFromPoint: rect.origin toPoint: NSMakePoint(rect.origin.x, rect.origin.y+rect.size.height)];    
}

@end
