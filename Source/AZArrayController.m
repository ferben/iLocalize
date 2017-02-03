//
//  AZArrayController.m
//  iLocalize3
//
//  Created by Jean on 10.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AZArrayController.h"

@implementation AZArrayController

- (void)awakeFromNib
{
    mFilterDescriptors = [[NSMutableArray alloc] init];
    mDelegate = nil;
    mNewObject = NULL;
}


- (void)setFilterDescriptor:(id)filter
{
    [mFilterDescriptors removeAllObjects];
    [mFilterDescriptors addObject:filter];
}

- (void)setFilterDescriptors:(NSArray*)filters
{
    [mFilterDescriptors removeAllObjects];
    [mFilterDescriptors addObjectsFromArray:filters];
}

- (BOOL)acceptObject:(id)object
{
    return YES;
}

- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
}

- (void)insertObject:(id)object atArrangedObjectIndex:(NSUInteger)index
{
    mNewObject = object;
    [super insertObject:object atArrangedObjectIndex:index];
}

- (NSArray *)arrangeObjects:(NSArray *)objects
{
    if([mFilterDescriptors count] == 0 && mDelegate == nil)
        return [super arrangeObjects:objects];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[objects count]];
    id object;
    for(object in objects) {
        if([mDelegate performSelector:@selector(arrayControllerFilterObject:) withObject:object])
            [array addObject:object];
        else if(object == mNewObject) {
            mNewObject = NULL;
            [array addObject:object];
        }
    }
    
    return [super arrangeObjects:array];
}

@end
