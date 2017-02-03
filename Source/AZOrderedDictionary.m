//
//  AZOrderedDictionary.m
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZOrderedDictionary.h"


@implementation AZOrderedDictionary

- (id) init
{
    self = [super init];
    if (self != nil) {
        dic = [[NSMutableDictionary alloc] init];
        orderedKeys = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)setObject:(id)o forKey:(id)key
{
    if(!dic[key]) {
        [orderedKeys addObject:key];
    }
    dic[key] = o;
}

- (id)objectForKey:(id)key
{
    return dic[key];
}

- (NSArray*)allKeys
{
    return orderedKeys;
}

- (NSArray*)allValues
{
    NSMutableArray *orderedValues = [NSMutableArray array];
    for(id key in orderedKeys) {
        [orderedValues addObject:[self objectForKey:key]];
    }
    return orderedValues;
}

- (NSUInteger)count
{
    return [dic count];
}

- (void)sortKeysUsingComparator:(NSComparator)comparator
{
    [orderedKeys sortUsingComparator:comparator];
}

@end
