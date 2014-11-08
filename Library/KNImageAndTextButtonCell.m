//
//  KNButtonCell.m
//

/*
 
 Copyright (c) 2008 KennettNet Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must, in all cases, contain attribution of 
 KennettNet Software Limited as the original author of the source code 
 shall be included in all such resulting software products or distributions.
 3. The name of the author may not be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS"' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "KNImageAndTextButtonCell.h"


@implementation KNImageAndTextButtonCell

- (void)dealloc {
    image = nil;
}

- copyWithZone:(NSZone *)zone {
    KNImageAndTextButtonCell *cell = (KNImageAndTextButtonCell *)[super copyWithZone:zone];
    cell->image = image;
    return cell;
}

- (void)setImage:(NSImage *)anImage {
    if (anImage != image) {
        image = anImage;
		[image setSize:NSMakeSize(16, 16)];
    }
}

- (NSImage *)image {
    return image;
}


#define KNImageAndTextButtonCellPadding 5 // Distance between the end of the image and the start of the text.

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    
	// Draw the original button first, then the image.
	
	[super drawWithFrame:cellFrame inView:controlView];
	
	if (image != nil) {
		
        NSRect imageFrame;
		
        NSSize imageSize = [image size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, KNImageAndTextButtonCellPadding + imageSize.width, NSMinXEdge);
		
        imageFrame.origin.x += imageFrame.size.width;
        imageFrame.size = imageSize;
				
		BOOL oldFlipped = [image isFlipped];
        [image setFlipped:![controlView isFlipped]];
        [image drawInRect:imageFrame fraction:1];
		[image setFlipped:oldFlipped];		
	} 	
}


-(BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {

	// Make sure that the mouse only gets tracked if it is clicked on the check box, otherwise 
	// the row will be checked/unchecked whenever the user clicks on any part of the cell (which is bad).
	
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint localPoint = [controlView convertPoint:event_location fromView:nil];
	
	if (localPoint.x <= cellFrame.origin.x + 16) {
		return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
	} else {
		return NO;
	}
}

-(NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
	
	// Adjust the rect so we don't interfere with the image's location
	
	if (image != nil) {
		
		NSRect newFrame = NSOffsetRect(frame, [[self image] size].width + KNImageAndTextButtonCellPadding, 0);
		newFrame.size.width -= ([[self image] size].width + KNImageAndTextButtonCellPadding);
		
		return [super drawTitle:title withFrame:newFrame inView:controlView];
		
	} else {
		return [super drawTitle:title withFrame:frame inView:controlView];
	}
	
}

@end
