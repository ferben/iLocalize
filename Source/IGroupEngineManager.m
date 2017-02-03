//
//  IGroupEngineManager.m
//  iLocalize
//
//  Created by Jean Bovet on 10/22/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngineManager.h"
#import "Constants.h"
#import "StringController.h"
#import "LanguageController.h"

@implementation IGroupEngineManager

@synthesize engine;
@synthesize state;
@dynamic delegate;

@synthesize processState;
@synthesize run;
@synthesize processing;

+ (IGroupEngineManager*)managerForEngine:(IGroupEngine*)engine
{
    IGroupEngineManager *manager = [[IGroupEngineManager alloc] init];
    manager.engine = engine;
    return manager;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        state = [[IGroupEngineState alloc] init];
        
        // condition used to notify the engine to run in its own thread
        runCondition = [[NSCondition alloc] init];
        
        // register to receive notification when something changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(languageSelectionDidChange:)
                                                     name:ILLanguageSelectionDidChange
                                                   object:nil];    
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fileSelectionDidChange:)
                                                     name:ILFileSelectionDidChange
                                                   object:nil];    
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stringSelectionDidChange:)
                                                     name:ILStringSelectionDidChange
                                                   object:nil];            
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [poolResultsTimer invalidate];
    poolResultsTimer = nil;
}

- (void)setDelegate:(id<IGroupEngineManagerDelegate>)inDelegate
{
    if(inDelegate) {
        poolResultsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(poolForResults:) userInfo:nil repeats:YES];        
    }
    delegate = inDelegate;
}

- (void)poolForResults:(NSTimer*)timer
{
    NSArray *results = [self.engine drainResultsForState:self.state];
    if(results.count > 0) {
        [delegate newResults:results forEngineManaged:self];
    }
    if((self.processing && !lastProcessingNotified) || (!self.processing && lastProcessingNotified)) {
        [delegate notifyProcessing:self.processing];
        lastProcessingNotified = self.processing;
    }
}

- (void)notifyEngineToRun
{
    [runCondition lock];
    self.processState = YES;
    [runCondition signal];
    [runCondition unlock];    
}

- (void)start
{
    enabled = YES;
    self.run = YES;
    [self notifyEngineToRun];
    running = YES;
    [NSThread detachNewThreadSelector:@selector(runEngine) toTarget:self withObject:nil];
}

- (void)stop
{
    // Stop the timer
    [poolResultsTimer invalidate];
    poolResultsTimer = nil;
        
    // Stop the thread that will release the reference to this manager
    self.run = NO;
    self.state.outdated = YES; // will make then engines to stop as soon as possible
    [self notifyEngineToRun];
    
    // Make sure to wait for the engine thread to complete otherwise
    // we might crash if the thread is accessing data after the projet is closed.
    NSDate *timeoutDate = [NSDate date];
    while (running) {
        [NSThread sleepForTimeInterval:0.1];
        if([[NSDate date] timeIntervalSinceDate:timeoutDate] > 2) {
            ERROR(@"Time-out waiting for %@ to shutdown.", self);
            break;
        }
    }
}

- (void)setEnabled:(BOOL)flag
{
    enabled = flag;
}

- (void)setSourceLanguage:(NSString*)source targetLanguage:(NSString*)target
{
    @synchronized(self) {
        if(![self.state.baseLanguage isEqualToString:source] ||
           ![self.state.targetLanguage isEqualToString:target]) {
            self.state.outdated = YES; // original state is outdated
            self.state = [IGroupEngineState stateWithOriginalState:self.state];
            self.state.baseLanguage = source;
            self.state.targetLanguage = target;
            self.state.languageChanged = YES;
        }
    }
    [self notifyEngineToRun];
}

- (void)setSelectedString:(NSString*)string
{
    @synchronized(self) {
        if(![self.state.selectedString isEqualToString:string]) {
            [delegate clearResultsForEngineManaged:self];
            self.state.outdated = YES; // original state is outdated
            self.state = [IGroupEngineState stateWithOriginalState:self.state];
            self.state.selectedString = string;
            self.state.selectedStringChanged = YES;
        }
    }        
    [self notifyEngineToRun];
}

- (BOOL)waitUntilProcessMustBeDone
{
    BOOL result = NO;
    [runCondition lock];
    while (!self.processState && self.run) {
        [runCondition wait];
    }    
    result = self.processState && self.run;
    self.processState = NO;
    [runCondition unlock];
    return result;
}

- (void)runEngine
{
    while (self.run) {
        if([self waitUntilProcessMustBeDone] && enabled) {
            self.processing = YES;
            [self.engine runForState:self.state];            
            self.processing = NO;
        }
    }
    running = NO;
}

#pragma mark Notifications

- (void)updateCurrentState
{
    LanguageController *lc = [self.state.projectProvider selectedLanguageController];
    if(lc) {
        [self setSourceLanguage:[lc baseLanguage] targetLanguage:[lc language]];
    }    
    NSArray *scs = [self.state.projectProvider selectedStringControllers];
    if([scs count] == 1) {
        [self setSelectedString:[[scs firstObject] base]];
    } else {
        [self setSelectedString:nil];
    }

}

- (void)languageSelectionDidChange:(NSNotification*)notif
{
//    [self clear];
//    [self updateCurrentState];
}

- (void)fileSelectionDidChange:(NSNotification*)notif
{
    // nothing to do now
}

- (void)stringSelectionDidChange:(NSNotification*)notif
{
    // Now the string is provided by the search field of the glossary or translation views.
//    [self clear];
//    [self updateCurrentState];
}

@end
