//
//  WorkerThread.m
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "WorkerThread.h"
#import "PilotThread.h"

#import "SafeData.h"
#import "SafeStatus.h"

#define REQUEST_START	1
#define RUNNING			2
#define REQUEST_STOP	3
#define STOPPED			4

@implementation WorkerThread

- (id)init
{
	if(self = [super init]) {
		mPilotThread = NULL;
		mData = [[SafeData alloc] init];
		mRequestStop = NO;
		mRunning = NO;
	}
	return self;
}


- (void)setPilot:(PilotThread*)pilot
{
	mPilotThread = pilot;
}

- (void)launch
{
	[NSApplication detachDrawingThread:@selector(workerThread)
							  toTarget:self
							withObject:nil];
}

- (void)startWorkingWithData:(id)data
{
	[mData setData:data];
	[self launch];
}

- (void)stopWorking
{
	if(mRunning) {
		mRequestStop = YES;
		while(mRunning) {
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
		}		
	}
	mRequestStop = NO;
}

- (BOOL)shouldStopWorking
{
	return mRequestStop;
}

- (void)workerRun
{
	[mPilotThread workerThreadStarted];
	[mPilotThread workerThreadRunWithData:[mData data]];
	[mPilotThread workerThreadStopped];
}

- (void)workerThread
{
	mRunning = YES;
	[self workerRun];
	mRunning = NO;
}

@end
