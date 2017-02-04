//
//  NSImage+Extensions.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface NSImage (iLocalize)
{
}

- (void)drawInRect:(NSRect)rect fraction:(CGFloat)fraction;
- (void)drawInRect:(NSRect)r operation:(NSCompositingOperation)operation fraction:(float)fraction;
- (void)drawAtPoint:(NSPoint)p operation:(NSCompositingOperation)operation fraction:(float)fraction;
- (NSRect)frame;
- (NSImage *)imageWithFraction:(float)fraction;
- (NSImage *)imageWithSize:(NSSize)size;

@end
