//
//  AZOutlineView.m
//  iLocalize3
//
//  Created by Jean on 19.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AZOutlineView.h"

@implementation AZOutlineView

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *keyString = [theEvent charactersIgnoringModifiers];
    unichar   keyChar = [keyString characterAtIndex:0];
    
    switch (keyChar)
    {
        case 0177: // Delete Key
        case NSDeleteFunctionKey:
        case NSDeleteCharFunctionKey:
            if ( [self selectedRow] >= 0
                 && [[self delegate] respondsToSelector:@selector(outlineViewDeleteSelectedRows:)])
            {
                [[self delegate] performSelector:@selector(outlineViewDeleteSelectedRows:) withObject:self];
            }
            break;
        default:
            [super keyDown:theEvent];
    }
}

@end
