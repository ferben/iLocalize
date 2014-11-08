//
//  WorkerThread.h
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class PilotThread;
@class SafeData;
@class SafeStatus;

@interface WorkerThread : NSObject {
	PilotThread		*mPilotThread;
	SafeData		*mData;
	BOOL			mRequestStop;
	BOOL			mRunning;
}

- (void)setPilot:(PilotThread*)pilot;

- (void)startWorkingWithData:(id)data;
- (void)stopWorking;

- (BOOL)shouldStopWorking;

@end
