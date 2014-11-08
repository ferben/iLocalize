//
//  IGroupViewAll.m
//  iLocalize
//
//  Created by Jean Bovet on 11/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupViewAll.h"
#import "IGroupView.h"
#import "IGroupGlossary.h"
#import "IGroupAlternate.h"
#import "IGroupEngineGlossary.h"
#import "IGroupEngineAlternate.h"

@implementation IGroupViewAll

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)addToView:(NSView*)parentView
{
	NSRect frame = [self frame];
	
	CGFloat alternateHeight = 25*2;
	CGFloat glossaryHeight = frame.size.height - alternateHeight;
	
	IGroupView *glossaryView = [[IGroupView alloc] initWithFrame:NSMakeRect(0, alternateHeight, frame.size.width, glossaryHeight)];
	[glossaryView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMaxYMargin|NSViewMaxXMargin];
	IGroup *glossaryGroup = [IGroupGlossary groupWithProjectProvider:self.projectProvider engine:[IGroupEngineGlossary engine]];
	[glossaryGroup assignToView:glossaryView];

	[self addSubview:glossaryView];
	
	IGroupView *alternateView = [[IGroupView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, alternateHeight)];
	[alternateView setAutoresizingMask:NSViewWidthSizable|NSViewMaxYMargin|NSViewMaxXMargin];
	IGroup *alternateGroup = [IGroupAlternate groupWithProjectProvider:self.projectProvider engine:[IGroupEngineAlternate engine]];
	[alternateGroup assignToView:alternateView];
	
	[self addSubview:alternateView];			
	
	[parentView addSubview:self];			
}

@end
