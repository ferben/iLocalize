//
//  SafeMutableArray.h
//  iLocalize3
//
//  Created by Jean on 03.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface SafeMutableArray : NSObject {
    NSMutableArray    *mArray;
}
+ (id)array;
- (void)addObject:(id)object;
- (id)readFirstObjectAndRemove;
- (NSArray*)readObjectsAndRemove:(int)max;
- (NSUInteger)count;
- (void)clear;
@end
