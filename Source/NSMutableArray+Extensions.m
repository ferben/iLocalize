//
//  NSMutableArray+Extensions.m
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSMutableArray+Extensions.h"

@implementation NSMutableArray (iLocalize)

- (void)addObjectSafe:(id)object
{
    if(object) {
        [self addObject:object];
    }
}

- (void)removeFirstObject
{
    if([self count]>0) {
        [self removeObjectAtIndex:0];
    }
}

- (NSMutableArray*)arrayByRemovingFirstObject
{
    NSMutableArray *array = [self mutableCopy];
    [array removeFirstObject];
    return array;
}

- (BOOL)removePathOrEquivalent:(NSString*)path
{
    @autoreleasepool {
        BOOL removed = NO;
        int index;
        for(index = [self count]-1; index>=0; index--) {
            if([self[index] isEquivalentToPath:path]) {
                [self removeObjectAtIndex:index];
                removed = YES;
            }
        }
        return removed;
    }    
}

@end
