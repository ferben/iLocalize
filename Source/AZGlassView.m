//
//  AZGlassView.m
//  iLocalize
//
//  Created by Jean on 3/15/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "AZGlassView.h"


@implementation AZGlassView

- (void)drawRect:(NSRect)rect {
	NSImage *startCap = [NSImage imageNamed:@"left-strip.png"];
	NSImage *centerFill = [NSImage imageNamed:@"middle-strip.png"];
	// nicer to not have a border on the right
	NSImage *endCap = nil; [NSImage imageNamed:@"left-strip.png"];
	
	NSDrawThreePartImage(self.bounds, startCap, centerFill, endCap, NO, NSCompositeCopy, 1.0, NO);	
}

@end
