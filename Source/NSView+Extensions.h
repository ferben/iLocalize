//
//  NSView+Extensions.h
//  iLocalize
//
//  Created by Jean Bovet on 4/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//


@interface NSView (Extensions)

/**
 Sets a view as the only subview of the receiver. It acts like NSBox, that is by setting
 the view to the size of the receiver.
 */
- (void)setContentView:(NSView*)view;

@end
