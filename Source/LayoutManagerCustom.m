//
//  LayoutManagerCustom.m
//  iLocalize3
//
//  Created by Jean on 28.03.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

// Smultron version 1.1, 2005-03-28
// Written by Peter Borg, pgw3@mac.com
// Copyright (C) 2004-2005 Peter Borg
// For the lastest version of the code go to http://smultron.sourceforge.net
// Released under GNU General Public License, http://www.gnu.org/copyleft/gpl.html

#import "LayoutManagerCustom.h"

@implementation LayoutManagerCustom

- (id)init
{
	if (self = [super init]) {
		unichar spaceUnichar = 0x00B7;
		spaceCharacter = [[NSString alloc] initWithCharacters:&spaceUnichar length:1];
		unichar tabUnichar = 0x2192; //0x00AC;
		tabCharacter = [[NSString alloc] initWithCharacters:&tabUnichar length:1];
		unichar newLineUnichar = 0x21B5; //0x00B6;
		newLineCharacter = [[NSString alloc] initWithCharacters:&newLineUnichar length:1];	
		showInvisibleCharacters = NO;
	}
	return self;
}

- (void)dealloc
{
	
	spaceCharacter = nil;
	tabCharacter = nil;
	newLineCharacter = nil;
	
}

-(void)setShowInvisibleCharacters:(BOOL)flag
{
	showInvisibleCharacters = flag;
}

- (void)drawCharacter:(NSString*)character attributes:(NSDictionary*)attrs atIndex:(NSUInteger)index containerOrigin:(NSPoint)containerOrigin
{
	NSPoint pointToDrawAt = [self locationForGlyphAtIndex:index];
	NSRect glyphFragment = [self lineFragmentRectForGlyphAtIndex:index effectiveRange:NULL];
	pointToDrawAt.x += glyphFragment.origin.x;
	pointToDrawAt.y = glyphFragment.origin.y;
	
	pointToDrawAt.x += containerOrigin.x;
	pointToDrawAt.y += containerOrigin.y;
	
	NSMutableDictionary *nd = [NSMutableDictionary dictionaryWithDictionary:attrs];
	nd[NSForegroundColorAttributeName] = [NSColor redColor];
	[character drawAtPoint:pointToDrawAt withAttributes:nd];					
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{
    if (showInvisibleCharacters) {
		NSAttributedString *aString = [self attributedString];
		NSString *completeString = [[self textStorage] string];
		NSUInteger lengthToRedraw = NSMaxRange(glyphRange);	
//		NSCharacterSet *controlSet = [NSCharacterSet controlCharacterSet];
		for (unsigned int index = glyphRange.location; index < lengthToRedraw; index++) {
			unichar characterToCheck = [completeString characterAtIndex:index];
			if (characterToCheck == ' ') {
				[self drawCharacter:spaceCharacter attributes:[aString attributesAtIndex:index effectiveRange:nil] atIndex:index containerOrigin:containerOrigin];				
			} else if (characterToCheck == '\t') {
				[self drawCharacter:tabCharacter attributes:[aString attributesAtIndex:index effectiveRange:nil] atIndex:index containerOrigin:containerOrigin];				
			} else if (characterToCheck == '\n' || characterToCheck == '\r' || characterToCheck == 0x2028 || characterToCheck == 0x2029) {
				[self drawCharacter:newLineCharacter attributes:[aString attributesAtIndex:index effectiveRange:nil] atIndex:index containerOrigin:containerOrigin];				
//			} else if([controlSet characterIsMember:characterToCheck]) {
//				[self drawCharacter:[NSString stringWithFormat:@"%C", 0x0332] attributes:[aString attributesAtIndex:index effectiveRange:nil] atIndex:index containerOrigin:containerOrigin];								
			}
		}
    } 
	
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];
}

@end
