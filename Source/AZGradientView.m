//
//  AZGradientView.m
//  iLocalize
//
//  Created by Jean on 1/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "AZGradientView.h"


@implementation AZGradientView

@synthesize bottomLine;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.bottomLine = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSImage *strip = [NSImage imageNamed:@"gradient-strip"];
	NSDrawThreePartImage(self.bounds, strip, strip, strip, NO, NSCompositeCopy, 1.0, NO);			
	
	if(self.bottomLine) {
		[[NSColor grayColor] set];
		NSRect r = self.bounds;
		r.size.height = 1;
		NSFrameRect(r);
	}
}

@end
