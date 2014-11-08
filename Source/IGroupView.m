//
//  IGroupView
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupView.h"
#import "IGroup.h"
#import "IGroupElement.h"

@implementation IGroupView

@synthesize group;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		selectedElementIndex = -1;
    }
    return self;
}

- (void)dealloc
{
	[self removeTrackingArea:trackingArea];
}

- (void)updateTrackingAreas
{
	[self removeTrackingArea:trackingArea];
	
	trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
												options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
												  owner:self userInfo:nil];
	[self addTrackingArea:trackingArea];		
}

- (void)drawRect:(NSRect)dirtyRect {
//	NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
//	NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor darkGrayColor], 0.0, [NSColor grayColor], 1.0, nil];
//	[gradient drawInBezierPath:path angle:270];
	[[NSColor darkGrayColor] set];
	[NSBezierPath fillRect:self.bounds];

	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	attrs[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande Bold" size:11];
	attrs[NSForegroundColorAttributeName] = [NSColor whiteColor];
	
	// draw the elements
	int index = 0;
	for(IGroupElement *e in group.elements) {		
		index++;
		CGFloat height = 25;
		CGFloat y = self.bounds.origin.y+self.bounds.size.height-index*height;
		if(y <= 0) break;
		
		if(selectedElementIndex == index-1) {
			NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0, y, self.bounds.size.width, height)];
			NSColor *start = [NSColor colorWithCalibratedRed:0 green:0 blue:1.0 alpha:1.0];
			NSColor *end = [NSColor colorWithCalibratedRed:0 green:0 blue:0.5 alpha:1.0];
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:start endingColor:end];
			[gradient drawInBezierPath:path angle:270];
		}
		
		[e.source drawAtPoint:NSMakePoint(100, y+5) withAttributes:attrs];
		[e.target drawAtPoint:NSMakePoint(self.bounds.size.width/2, y+5) withAttributes:attrs];		
	}		
	
	if(index == 0) {
		[@"No results" drawAtPoint:NSMakePoint(100, self.bounds.origin.y+self.bounds.size.height-20) withAttributes:attrs];		
	}
	attrs[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:11];
	[group.name drawAtPoint:NSMakePoint(10, self.bounds.origin.y+self.bounds.size.height-20) withAttributes:attrs];
}

- (void)mouseExited:(NSEvent *)theEvent
{
	selectedElementIndex = -1;
	[self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint mouseLocation = [self convertPoint:event_location fromView:nil];
	selectedElementIndex = (self.bounds.origin.y+self.bounds.size.height-mouseLocation.y) / 25;
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[group clickOnElement:(group.elements)[selectedElementIndex]];
}

@end
