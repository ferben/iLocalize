//
//  ImmutableToMutableArrayOfObjectsTransformer.m
//  iLocalize3
//
//  Created by Jean on 01.03.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImmutableToMutableArrayOfObjectsTransformer.h"

@implementation ImmutableToMutableArrayOfObjectsTransformer

+ (Class)transformedValueClass
{
    return [NSMutableArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    if (value == nil) return nil;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[value count]];
    NSEnumerator *enumerator = [value objectEnumerator];
    id object;
    while (object = [enumerator nextObject])
        [array addObject:[object mutableCopy]];
    
    return array;
}

- (id)reverseTransformedValue:(id)value
{
    return value;
}

@end
