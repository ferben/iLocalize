//
//  AZGlassPopUpButtonCell.m
//  iLocalize
//
//  Created by Jean on 3/15/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "AZGlassPopUpButtonCell.h"
#import "AZActionPopUpButtonCell.h"

@implementation AZGlassPopUpButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    BOOL selected = [self isHighlighted];
    NSImage *startCap = [NSImage imageNamed:selected?@"left-strip-selected":@"left-strip"];
    NSImage *centerFill = [NSImage imageNamed:selected?@"middle-strip-selected":@"middle-strip"];
    //NSImage *endCap = [NSImage imageNamed:selected?@"right-strip-selected":@"right-strip"];
    
    //endCap = centerFill;
    
    NSDrawThreePartImage(frame, startCap, centerFill, centerFill, NO, NSCompositeCopy, 1.0, YES);            
}

@end
