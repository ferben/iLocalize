//
//  SplitViewThumbView.m
//  iLocalize
//
//  Created by Jean on 12/26/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "AZSplitViewThumbView.h"


@implementation AZSplitViewThumbView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Note: make sure the width is at least 3 pixels because sometimes, for example
    // when the button next to this thumb view is updated, this thumbview will be asked
    // to draw itself in a tiny rectangle with width=1. This will cause a visual artifact
    // because the 3 images composited in width=1 won't be the same as the left-strip.png only.
    // So 3 pixels is the minimum width that we should draw to have at least enough space for 
    // width(left-strip.png)+width(middle-strip.png);
    rect.size.width = MAX(3, rect.size.width);
    
    // Defines the images
    NSImage *startCap = [NSImage imageNamed:@"left-strip.png"];
    NSImage *centerFill = [NSImage imageNamed:@"middle-strip.png"];
    // nicer to not have a border on the right
    NSImage *endCap = nil; [NSImage imageNamed:@"left-strip.png"];
    
    NSDrawThreePartImage(rect, startCap, centerFill, endCap, NO, NSCompositeSourceOver, 1.0, NO);    
    
    NSImage *thumb = [NSImage imageNamed:@"thumb.png"];
    NSSize is = [thumb size];
    [thumb drawAtPoint:NSMakePoint(rect.origin.x+rect.size.width-is.width-5, rect.origin.y+(rect.size.height-is.height)/2) operation:NSCompositeSourceOver fraction:1.0];
}

@end
