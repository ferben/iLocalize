//
//  FileTypeCustomCell.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileTypeCustomCell.h"
#import "FileController.h"

@implementation FileTypeCustomCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	NSImage *image = [[self fileController] typeImage];

    if(!image)
		return;

	// For some reason we need to disable the interpolation otherwise the
	// file icons are a bit blurry.
	NSImageInterpolation oldInterpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
	
	NSSize imageSize = NSMakeSize(16, 16); //[image size];
	[image setSize:imageSize];
	
	NSPoint p = cellFrame.origin;
	p.x += cellFrame.size.width  * 0.5 - imageSize.width  * 0.5;
	p.y += cellFrame.size.height * 0.5 - imageSize.height * 0.5;
    // [image setFlipped:YES];
	[image drawInRect:NSMakeRect(p.x, p.y, imageSize.width, imageSize.height)
			operation:NSCompositeSourceOver 
			 fraction:1];

	[[NSGraphicsContext currentContext] setImageInterpolation:oldInterpolation];
}

- (NSArray *)accessibilityAttributeNames
{
	id o = [super accessibilityAttributeNames];
	return [o arrayByAddingObject:NSAccessibilityValueAttribute];	
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
	id o = [super accessibilityAttributeValue:attribute];	
	if([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
		o = NSAccessibilityTextFieldRole;
	} else if([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		o = NSAccessibilityRoleDescription(NSAccessibilityTextFieldRole, nil);
	} else if([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		o = [[[self fileController] absoluteFilePath] pathExtension];
	}
	return o;	
}

@end
