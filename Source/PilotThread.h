//
//  PilotThread.h
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class SafeData;
@class WorkerThread;

@interface PilotThread : NSObject
{
    WorkerThread  *mWorkerThread;
    SafeData      *mData;
    id             mDelegate;
}

- (void)setDelegate:(id)delegate;

- (void)setData:(id)data;
- (void)runWithData:(id)data;
- (void)stop;

- (void)workerThreadRunWithData:(id)data;
- (void)workerThreadStarted;
- (void)workerThreadStopped;
- (BOOL)workerThreadShouldStopWorking;

@end
