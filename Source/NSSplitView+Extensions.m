//
//  NSSplitView+Extensions.m
//  iLocalize
//
//  Created by Jean on 3/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSSplitView+Extensions.h"

@implementation NSSplitView (Extensions)

- (id)storePositions
{
    NSMutableArray *pos = [NSMutableArray array];
    for(NSView *subview in self.subviews) {
        [pos addObject:NSStringFromRect(subview.frame)];
    }
    return pos;
}

- (void)restorePositions:(id)positions
{
    if(![positions isKindOfClass:[NSArray class]]) return;
            
    int index = 0;
    for(NSString *pos in positions) {
        // check also for the kind of class because old project didn't use a string for pos
        if(index<self.subviews.count && [pos isKindOfClass:[NSString class]]) {
            [(self.subviews)[index++] setFrame:NSRectFromString(pos)];            
        }
    }
}

@end
