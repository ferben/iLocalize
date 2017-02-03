//
//  IGroupEngineManager.h
//  iLocalize
//
//  Created by Jean Bovet on 10/22/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngine.h"
#import "IGroupEngineState.h"

@class IGroupEngineManager;

@protocol IGroupEngineManagerDelegate

// Invoked when results are available. This method is invoked on the main thread.
- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager;

// Invoked when the results must be cleared (because a new sets of results will come
// or because no result is available)
- (void)clearResultsForEngineManaged:(IGroupEngineManager*)manager;

// Invoked to tell if the engine is processing something or not
- (void)notifyProcessing:(BOOL)processing;

@end

@interface IGroupEngineManager : NSObject {
    IGroupEngine *engine;
    IGroupEngineState *state;
    id<IGroupEngineManagerDelegate> delegate;
    
    NSTimer *poolResultsTimer;
    
    NSCondition *runCondition;
    BOOL processState;
    BOOL run;
    BOOL running;
    BOOL enabled;
    
    BOOL processing;    
    BOOL lastProcessingNotified;
}

@property (strong) IGroupEngine *engine;
@property (strong) IGroupEngineState *state;
@property (weak) id<IGroupEngineManagerDelegate> delegate;

@property (assign) BOOL processState;
@property (assign) BOOL run;

// True if the engine is processing something
@property (assign) BOOL processing;

// Creates a manager for a particular engine
+ (IGroupEngineManager*)managerForEngine:(IGroupEngine*)engine;

// Sets the delegate that will be notified when new result from the engine is available
- (void)setDelegate:(id<IGroupEngineManagerDelegate>)delegate;

// Starts the engine (it should run during the whole existence of the project itself)
- (void)start;

// Stops the engine (usually when the project closes)
- (void)stop;

// Enables or disables the engine without impacting its background thread.
// Use this method to temporarily stop this engine from processing.
- (void)setEnabled:(BOOL)flag;

// Sets the source and target languages. This method will trigger the execution of the engine.
- (void)setSourceLanguage:(NSString*)source targetLanguage:(NSString*)target;

// Sets the current string. This method will trigger the execution of the engine.
- (void)setSelectedString:(NSString*)string;

// Update the current state of the manager
- (void)updateCurrentState;

@end
