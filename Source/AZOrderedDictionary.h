//
//  AZOrderedDictionary.h
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 Mutable dictionary that guarantees ordering of the keys as they are inserted.
 */
@interface AZOrderedDictionary : NSObject {
    NSMutableDictionary *dic;
    NSMutableArray *orderedKeys;
}
- (void)setObject:(id)o forKey:(id)key;
- (id)objectForKey:(id)key;
- (NSArray*)allKeys;
- (NSArray*)allValues;
- (NSUInteger)count;
- (void)sortKeysUsingComparator:(NSComparator)comparator;
@end
