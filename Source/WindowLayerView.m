//
//  WindowLayerView.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "WindowLayerView.h"

static NSMutableDictionary	*mTitleAttributes = NULL;
static NSMutableDictionary	*mInfoAttributes = NULL;

@implementation WindowLayerView

- (void)awakeFromNib
{
	mTitle = NULL;
	mInfo = NULL;
}


- (void)setTitle:(NSString*)title
{
	mTitle = title;
	[self setNeedsDisplay:YES];
}

- (void)setInfo:(NSString*)info
{
	mInfo = info;
	[self setNeedsDisplay:YES];
}

- (void)changeWindowWidth:(float)width height:(float)height
{
	NSRect wf = [[self window] frame];
	if(wf.size.width != width || wf.size.height != height) {
		float dx = width-wf.size.width;
		float dy = height-wf.size.height;
		wf.origin.x -= dx*0.5;
		wf.origin.y -= dy*0.5;
		wf.size.width += dx;
		wf.size.height += dy;
		[[self window] setFrame:wf display:YES];		
	}
}

- (void)drawRect:(NSRect)rect 
{
	[[NSColor clearColor] set];
    NSRectFill([self frame]);
	
	float c = 0;
	[[NSColor colorWithDeviceRed:c green:c blue:c alpha:0.8] set];
	[NSBezierPath fillRoundRect:[self bounds] radius:20];
	
	if(mTitleAttributes == NULL) {
		mTitleAttributes = [[NSMutableDictionary alloc] init];
		mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:36];		
		mTitleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];		
	}	
	if(mInfoAttributes == NULL) {
		mInfoAttributes = [[NSMutableDictionary alloc] init];
		mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:12];		
		mInfoAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];		
	}	
	
	NSSize titleSize = [mTitle sizeWithAttributes:mTitleAttributes];
	NSSize infoSize = [mInfo sizeWithAttributes:mInfoAttributes];
	if([mInfo length] == 0)
		infoSize = NSMakeSize(0, 0);
	
	[self changeWindowWidth:MAX(titleSize.width, infoSize.width)+50 height:titleSize.height+infoSize.height+20];
		
	NSRect titleRect = [self bounds];
	titleRect.origin.x = titleRect.size.width*0.5-titleSize.width*0.5;
	titleRect.origin.y += (titleRect.size.height-(titleSize.height+infoSize.height))*0.5+infoSize.height;
	titleRect.size.height = titleSize.height;
		
	NSRect infoRect = [self bounds];
	infoRect.origin.x = infoRect.size.width*0.5-infoSize.width*0.5;
	infoRect.origin.y += (infoRect.size.height-(titleSize.height+infoSize.height))*0.5;
	infoRect.size.height = infoSize.height;
	
	[mTitle drawInRect:titleRect withAttributes:mTitleAttributes];			
	[mInfo drawInRect:infoRect withAttributes:mInfoAttributes];			
}

@end
