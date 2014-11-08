//
//  Stack.m
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Stack.h"

@implementation Stack

+ (void)initialize
{
	if(self == [Stack class]) {
		[self setVersion:0];
	}
}

- (id)init
{
	if(self = [super init]) {
		mStack = [[NSMutableArray alloc] init];
	}
	return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
	if(self = [super init]) {
		mStack = [coder decodeObject];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:mStack];
}

- (void)pushObject:(id)object
{
	@synchronized(self) {
		[mStack addObject:object];		
	}
}

- (id)popObject
{
	id object;
	@synchronized(self) {
		object = [mStack lastObject];
		if(object) {
			[mStack removeLastObject];			
		}
	}
	return object;
}

- (id)currentObject
{
	id object;
	@synchronized(self) {
		object = [mStack lastObject];		
	}
	return object;
}

- (void)clear
{
	@synchronized(self) {
		[mStack removeAllObjects];		
	}
}

- (NSUInteger)count
{
	return [mStack count];
}

- (BOOL)isEqualToArray:(NSArray*)array
{
	return [mStack isEqual:array];
}

@end
