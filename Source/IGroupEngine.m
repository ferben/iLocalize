//
//  IGroupEngine.m
//  iLocalize
//
//  Created by Jean Bovet on 10/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngine.h"

@interface IGroupEngine (PrivateMethods)

- (void)_runForState:(IGroupEngineState*)state;

@end

@implementation IGroupEngine

+ (IGroupEngine*)engine
{
	return [[self alloc] init];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		results = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (void)addResult:(id)result forState:(IGroupEngineState*)state
{
	@synchronized(results) {
		NSMutableArray *array = results[state];
		if(array == nil) {
			array = [NSMutableArray array];
			results[state] = array;
		}
		[array addObject:result];
	}
}

- (NSArray*)drainResultsForState:(IGroupEngineState*)state
{
	NSArray *copiedResults = nil;
	@synchronized(results) {
		NSMutableArray *array = results[state];
		if(array) {
			copiedResults = [NSArray arrayWithArray:array];
			[array removeAllObjects];			
		}
	}
	return copiedResults;
}

- (void)runForState:(IGroupEngineState*)state
{
	// Remove all outdated states
	@synchronized(results) {
		for(IGroupEngineState *state in [NSArray arrayWithArray:[results allKeys]]) {
			if(state.outdated) {
				[results removeObjectForKey:state];
			}
		}		
	}
	
	// Run for the new state
	[self _runForState:state];
	
	// Reset the state
	state.languageChanged = NO;
	state.selectedStringChanged = NO;
}

- (void)_runForState:(IGroupEngineState*)state
{
	[NSException raise:@"Must be implemented by subclass" format:@"%@", NSStringFromSelector(_cmd)];
}

@end
