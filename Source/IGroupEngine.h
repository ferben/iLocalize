//
//  IGroupEngine.h
//  iLocalize
//
//  Created by Jean Bovet on 10/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngineState.h"

@interface IGroupEngine : NSObject
{
    NSMutableDictionary  *results;
}

+ (IGroupEngine *)engine;

// Adds a result to the engine (thread-safe)
- (void)addResult:(id)result forState:(IGroupEngineState *)state;

// Remove and return all the results from the engine so far (thread-safe)
- (NSArray *)drainResultsForState:(IGroupEngineState *)state;

// Execute the engine work for a particular state. This method runs in its own thread.
// Note that this method should returns as soon as the outdated property of the state
// is true (this means the state is no longer valid).
- (void)runForState:(IGroupEngineState *)state;

@end
