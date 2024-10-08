//
//  TableHeaderCellCustom.m
//  iLocalize3
//
//  Created by Jean on 07.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableHeaderCellCustom.h"


@implementation TableHeaderCellCustom

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
    
    NSRect r = cellFrame;
    r.size.height += 1;
    [[NSImage imageNamed:@"TableViewGreyHeaderDown"] drawInRect:r operation:NSCompositingOperationSourceOver fraction:1];    
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:[self font] forKey:NSFontAttributeName];

    NSSize size = [[self stringValue] sizeWithAttributes:attributes];
    [[self stringValue] drawAtPoint:NSMakePoint(cellFrame.origin.x+5, cellFrame.origin.y+cellFrame.size.height*0.5-size.height*0.5) 
                     withAttributes:attributes];        

}

@end
