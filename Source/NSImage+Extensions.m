//
//  NSImage+Extensions.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSImage+Extensions.h"

@implementation NSImage (iLocalize)

static NSRect AZRectCentered(NSRect container, NSRect rect) {
    return NSMakeRect(CGRectGetMidX(container)-CGRectGetWidth(rect)/2, CGRectGetMidY(container)-CGRectGetHeight(rect)/2, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

- (void)drawInRect:(NSRect)rect fraction:(CGFloat)fraction {
    [self drawInRect:AZRectCentered(rect, [self frame])
            fromRect:[self frame]
           operation:NSCompositeSourceOver
            fraction:fraction
      respectFlipped:YES
               hints:nil];
}

- (void)drawInRect:(NSRect)r operation:(NSCompositingOperation)operation fraction:(float)fraction
{
    [self drawInRect:r fromRect:[self frame] operation:operation fraction:fraction];        
}

- (void)drawAtPoint:(NSPoint)p operation:(NSCompositingOperation)operation fraction:(float)fraction
{
    [self drawAtPoint:p fromRect:[self frame] operation:operation fraction:fraction];
}

- (NSRect)frame
{
    NSSize size = [self size];
    return NSMakeRect(0, 0, size.width, size.height);
}

- (NSImage*)imageWithFraction:(float)fraction
{
    NSImage *image = [[NSImage alloc] initWithSize:[self size]];
    [image lockFocus];
    [self drawInRect:[self frame] operation:NSCompositeSourceOver fraction:fraction];
    [image unlockFocus];
    return image;
}

- (NSImage*)imageWithSize:(NSSize)size
{
    NSRect r = NSMakeRect(0, 0, size.width, size.height);
        
    NSImage *target = [[NSImage alloc] initWithSize:size];
    [target lockFocus];
//    [source setFlipped:YES];
    [self drawInRect:r operation:NSCompositeSourceOver fraction:1];
//    [selectedLayer drawInRect:r operation:NSCompositeSourceAtop fraction:1];
    [target unlockFocus];    
    
    return target;
}

@end
