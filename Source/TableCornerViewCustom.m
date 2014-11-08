//
//  TableCornerViewCustom.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableCornerViewCustom.h"


@implementation TableCornerViewCustom

+ (id)cornerWithTableView:(NSTableView*)tv
{
	NSRect frame = [[tv cornerView] frame];
	return [[self alloc] initWithFrame:frame];
}

- (NSMenu*)popupMenu
{
	return NULL;
}

- (NSString*)cornerImage
{
	return NULL;	// Subclass can use @"TableViewCornerIcon"
}

- (void)mouseDown:(NSEvent*)event
{
	if([self popupMenu])
		[NSMenu popUpContextMenu:[self popupMenu] withEvent:event forView:self];
}

- (void)drawRect:(NSRect)r
{
//	[super drawRect:r];

	if([self cornerImage]) {
		NSImage *image = [NSImage imageNamed:[self cornerImage]];
		NSSize imageSize = [image size];
		[image drawInRect:NSMakeRect(r.origin.x+r.size.width*0.5-imageSize.width*0.5, r.origin.y+r.size.height*0.5-imageSize.height*0.5, imageSize.width, imageSize.height)
				operation:NSCompositeSourceOver
				 fraction:1];		
	}
}
@end
