//
//  PilotThread.m
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PilotThread.h"
#import "WorkerThread.h"

#import "SafeData.h"

@implementation PilotThread

- (id)init
{
    if(self = [super init]) {
        mWorkerThread = [[WorkerThread alloc] init];
        [mWorkerThread setPilot:self];
        
        mData = [[SafeData alloc] init];
        mDelegate = NULL;
    }
    return self;
}


- (void)setDelegate:(id)delegate
{
    mDelegate = delegate;
}

- (void)launch
{
    [NSApplication detachDrawingThread:@selector(pilotThread)
                              toTarget:self
                            withObject:nil];
}

- (void)setData:(id)data
{
    [mData setData:data];
}

- (void)runWithData:(id)data
{
    [self setData:data];
    [self launch];
}

- (void)stop
{
    [mData setData:NULL];
    [mWorkerThread stopWorking];
}

- (void)pilotThread
{
    id data = [mData dataIfDirtyAndClear];
    if(data) {
        [mWorkerThread stopWorking];
        [mWorkerThread startWorkingWithData:data];
    }
}

- (void)workerThreadRunWithData:(id)data
{
    // Called from the worker thread to perform the computation
    // delegate should stop ASAP when [mWorkerThread shouldStopWorking] is true
    @try {
        [mDelegate performSelector:@selector(threadComputeData:) withObject:data];        
    }
    @catch(id exception) {
        [exception printStackTrace];
        NSLog(@"Exception in PilotThread::workerThreadRunWithData (%@)", exception);        
    }
}

- (void)workerThreadStarted
{
    // Called from the worker thread
    [mDelegate performSelectorOnMainThread:@selector(threadComputeStarted)
                                withObject:nil
                             waitUntilDone:NO];
}

- (void)workerThreadStopped
{
    // Called from the worker thread
    [mDelegate performSelectorOnMainThread:@selector(threadComputeStopped)
                                withObject:nil
                             waitUntilDone:NO];
}

- (BOOL)workerThreadShouldStopWorking
{
    return [mWorkerThread shouldStopWorking];
}

@end
