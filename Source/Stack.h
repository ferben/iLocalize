//
//  Stack.h
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface Stack : NSObject <NSCoding>
{
    NSMutableArray  *mStack;
}

- (void)pushObject:(id)object;
- (id)popObject;
- (id)currentObject;
- (void)clear;
- (NSUInteger)count;
- (BOOL)isEqualToArray:(NSArray *)array;

@end
