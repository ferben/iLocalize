//
//  SafeMutableArray.m
//  iLocalize3
//
//  Created by Jean on 03.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SafeMutableArray.h"


@implementation SafeMutableArray

+ (id)array
{
	return [[self alloc] init];
}

- (id)init
{
	if(self = [super init]) {
		mArray = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)addObject:(id)object
{
	@synchronized(self) {
		[mArray addObject:object];				
	}
}

- (id)readFirstObjectAndRemove
{
	id object = NULL;
	@synchronized(self) {
		if([mArray count]>0) {
			object = mArray[0];
			[mArray removeObjectAtIndex:0];
		}				
	}
	return object;
}

- (NSArray*)readObjectsAndRemove:(int)max
{
	NSMutableArray* objects = [NSMutableArray array];
	@synchronized(self) {
		int i;
		for(i = 0; i<max; i++) {
			if([mArray count]>0) {
				[objects addObject:[mArray firstObject]];
				[mArray removeFirstObject];
			} else {
				break;
			}
		}		
	}
	return objects;
}

- (NSUInteger)count
{
	NSUInteger c = 0;
	@synchronized(self) {
		c = [mArray count];				
	}
	return c;
}


- (void)clear
{
	@synchronized(self) {
		[mArray removeAllObjects];		
	}
}

@end
