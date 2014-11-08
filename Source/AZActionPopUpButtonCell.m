//
//  AZActionPopUpButtonCell.m
//  iLocalize
//
//  Created by Jean Bovet on 4/17/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZActionPopUpButtonCell.h"


@implementation AZActionPopUpButtonCell

//+ (void)drawInFrame:(NSRect)frame fraction:(CGFloat)fraction
//{
//	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
//	NSImageInterpolation oldInterpolation = [ctx imageInterpolation];
//	[ctx setImageInterpolation:NSImageInterpolationNone];
//	NSImage *action = [NSImage imageNamed:@"_action"];
//    [action drawInRect:frame fraction:fraction];
//	[ctx setImageInterpolation:oldInterpolation];
//}
//
//+ (void)drawInFrame:(NSRect)frame
//{
//	[AZActionPopUpButtonCell drawInFrame:frame fraction:1];
//}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	[super drawBezelWithFrame:frame inView:controlView];
//	if([self isEnabled]) {
//		[AZActionPopUpButtonCell drawInFrame:frame fraction:1];		
//	} else {
//		[AZActionPopUpButtonCell drawInFrame:frame fraction:0.5];		
//	}

}

@end
