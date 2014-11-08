//
//  ContentMatching.h
//  iLocalize
//
//  Created by Jean Bovet on 1/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 This class contains an array of matches for each string.
 It is used to draw in red the matching portion of a string
 and to perform the replace function.
 */
@interface FindContentMatching : NSObject {
	
	/**
	 Array of ranges for each item.
	 */
	NSMutableDictionary *rangesForItem;
}

/**
 Returns a new instance of this class.
 */
+ (FindContentMatching*)content;

/**
 Adds an array of ranges (NSValue) for the particular item.
 */
- (void)addRanges:(NSArray*)ranges item:(int)item;

/**
 Returns an array of ranges (NSValue) for the specified item.
 */
- (NSArray*)rangesForItem:(int)item;

/**
 Removes an array of ranges for the specified item.
 */
- (void)removeRangesForItem:(int)item;

@end
