//
//  AZCustomButtonCell.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "AZGlassButtonCell.h"

@implementation AZGlassButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	BOOL selected = self.state == NSOnState || [self isHighlighted];
	NSImage *startCap = [NSImage imageNamed:selected?@"left-strip-selected":@"left-strip"];
	NSImage *centerFill = [NSImage imageNamed:selected?@"middle-strip-selected":@"middle-strip"];
	//NSImage *endCap = [NSImage imageNamed:selected?@"right-strip-selected":@"right-strip"];

	//endCap = centerFill;
	
	NSDrawThreePartImage(frame, startCap, centerFill, centerFill, NO, NSCompositeCopy, 1.0, YES);			
}

@end
