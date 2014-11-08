//
//  TextViewCustom.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TextViewCustom.h"
#import "LayoutManagerCustom.h"

@implementation TextViewCustom

@synthesize language;
@synthesize drawBorder;

- (id)initWithFrame:(NSRect)frameRect textContainer:(NSTextContainer *)aTextContainer
{
	if(self = [super initWithFrame:frameRect textContainer:aTextContainer]) {
		mCustomDelegate = NULL;	
		self.drawBorder = NO;
        [self setAutomaticQuoteSubstitutionEnabled:NO];
        [self setAutomaticDashSubstitutionEnabled:NO];
        
		// Set the custom layout to enable show invisible characters
		LayoutManagerCustom *layoutManager = [[LayoutManagerCustom alloc] init];
		[[self textContainer] replaceLayoutManager:layoutManager];
	}
	return self;
}


- (void)setCustomDelegate:(id<TextViewCustomDelegate>)delegate
{
	mCustomDelegate = delegate;
}

- (void)setShowInvisibleCharacters:(BOOL)flag
{
	id layoutManager = [[self textContainer] layoutManager];
	if([layoutManager respondsToSelector:@selector(setShowInvisibleCharacters:)]) {
		[layoutManager setShowInvisibleCharacters:flag];
		[self setNeedsDisplay:YES];
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	// Needs to copy the menu and the items - best way to do that ?
	// QUESTION WWDC
	NSMenu *defaultMenu = [[super menuForEvent:theEvent] copy];
	if([mCustomDelegate respondsToSelector:@selector(customTextViewAsksForContextualMenu:)]) {
		NSMenu *customMenu = [mCustomDelegate customTextViewAsksForContextualMenu:self];
		if(customMenu) {
			NSEnumerator *enumerator = [[customMenu itemArray] reverseObjectEnumerator];
			NSMenuItem *item;
			while(item = [enumerator nextObject]) {
				[defaultMenu insertItem:[item copyWithZone:nil] atIndex:0];			
			}
		}		
	}
	return defaultMenu;
}

- (void)keyDown:(NSEvent*)event
{
	NSString *s = [event characters];
	if([s length]>0) {
		unichar c = [s characterAtIndex:0];
		if([mCustomDelegate respondsToSelector:@selector(textViewKeyPressed:)]) {
			if([mCustomDelegate textViewKeyPressed:event]) {
				return;
			}
		}
		if(c == NSEnterCharacter) {
			// Enter (numeric pad). Jump to the next untranslated strings
			if([mCustomDelegate respondsToSelector:@selector(textViewDidHitEnterKey:)]) {
				[mCustomDelegate textViewDidHitEnterKey:self];
				return;
			}
		}
	}
	[super keyDown:event];
}

- (BOOL)resignFirstResponder
{
	if([mCustomDelegate respondsToSelector:@selector(textViewResigned:)])
		[mCustomDelegate performSelector:@selector(textViewResigned:) withObject:self];

	return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	if(self.drawBorder) {
		[[NSColor blackColor] set];		
		NSFrameRect(self.bounds);
	}
}

@end
