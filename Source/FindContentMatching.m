//
//  ContentMatching.m
//  iLocalize
//
//  Created by Jean Bovet on 1/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "FindContentMatching.h"


@implementation FindContentMatching

+ (FindContentMatching*)content
{
	return [[self alloc] init];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		rangesForItem = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)addRanges:(NSArray*)ranges item:(int)item
{
	@synchronized(self) {
		NSNumber *itemNumber = @(item);
		NSMutableArray *itemRanges = rangesForItem[itemNumber];
		if(itemRanges == nil) {
			itemRanges = [NSMutableArray array];
			rangesForItem[itemNumber] = itemRanges;
		}
		[itemRanges addObjectsFromArray:ranges];
		
		// Make sure to sort the ranges by reverse order so the replace function
		// can grab them one by one and perform string replacement.
		[itemRanges sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
			NSValue *v1 = obj1;
			NSValue *v2 = obj2;
			NSRange r1 = v1.rangeValue;
			NSRange r2 = v2.rangeValue;
			if (r1.location < r2.location) {
				return NSOrderedDescending;
			}
			if (r1.location > r2.location) {
				return NSOrderedAscending;
			}
			return NSOrderedSame;
		}];
	}
}

- (NSArray*)rangesForItem:(int)item
{
    NSArray *ranges;
    @synchronized(self) {
        ranges = rangesForItem[@(item)];        
    }
    return ranges;
}

- (void)removeRangesForItem:(int)item
{
    @synchronized(self) {
        [rangesForItem removeObjectForKey:@(item)];
    }
}

@end
