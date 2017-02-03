//
//  NSTableView+Extensions.m
//  iLocalize
//
//  Created by Jean on 5/25/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSTableView+Extensions.h"
#import "Protocols.h"

@implementation NSTableView (iLocalize)

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mouseLoc];
    NSInteger column = [self columnAtPoint:mouseLoc];

    id delegate = [self delegate];
    
    if ([delegate conformsToProtocol:@protocol(MenuForTableViewProtocol)])
    {
        return [delegate menuForTableView:self column:column row:row];
    }
    
    return nil;
}

@end
