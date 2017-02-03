//
//  WindowLayer.m
//  iLocalize3
//
//  Created by Jean on 07.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "WindowLayer.h"


@implementation WindowLayer

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSWindowStyleMask)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag
{
	NSWindow *result = [[NSWindow alloc] initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
	
	[result setBackgroundColor:[NSColor clearColor]];	
	[result setHasShadow:NO];	
	[result setOpaque:NO];
	[result setIgnoresMouseEvents:YES];
	
	return (WindowLayer*)result;
}

@end
