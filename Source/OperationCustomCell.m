//
//  OperationCustomCell.m
//  iLocalize
//
//  Created by Jean on 12/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "OperationCustomCell.h"

static NSMutableDictionary	*mTitleAttributes = NULL;
static NSMutableDictionary	*mInfoAttributes = NULL;

@implementation OperationCustomCell

+ (OperationCustomCell*)cell
{
	return [[self alloc] init];
}

- (void)setCustomValue:(id)value
{
	mCustomValue = value;
}

- (id)customValue
{
	return mCustomValue;
}

- (void)checkAttributes
{
	if(mTitleAttributes == NULL) {
		mTitleAttributes = [[NSMutableDictionary alloc] init];
		mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:13];		
		
		NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
		mTitleAttributes[NSParagraphStyleAttributeName] = style;		
	}
	
	if(mInfoAttributes == NULL) {
		mInfoAttributes = [[NSMutableDictionary alloc] init];
		
		mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];		
		
		NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
		mInfoAttributes[NSParagraphStyleAttributeName] = style;		
	}	
}

- (void)drawString:(NSString*)string at:(NSPoint)point size:(NSSize)size cellFrame:(NSRect)cellFrame
{
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	[NSGraphicsContext saveGraphicsState];
	NSRectClip(cellFrame);
		
	[self checkAttributes];
	
	if([self isHighlighted]) {
		mTitleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];		
		mInfoAttributes[NSForegroundColorAttributeName] = [NSColor lightGrayColor];		
	} else {
		mTitleAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];		
		mInfoAttributes[NSForegroundColorAttributeName] = [NSColor lightGrayColor];				
	}		
	
	NSString *title = [self customValue][@"title"];
	NSString *info = [self customValue][@"entry"];

	{
		NSSize size = [title sizeWithAttributes:mTitleAttributes];
		NSAttributedString *p = [[NSAttributedString alloc] initWithString:title attributes:mTitleAttributes];
		[p drawInRect:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width, size.height)];
	}
		
	{
		NSSize size = [@"value-in-one-line-only" sizeWithAttributes:mInfoAttributes];
		NSAttributedString *p = [[NSAttributedString alloc] initWithString:info attributes:mInfoAttributes];
		[p drawInRect:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height-size.height, cellFrame.size.width, size.height)];
	}
	
	[NSGraphicsContext restoreGraphicsState];
}

@end
