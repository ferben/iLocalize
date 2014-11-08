//
//  BackgroundUpdater.h
//  iLocalize3
//
//  Created by Jean on 02.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class ProjectController;
@class SafeStatus;

@interface BackgroundUpdater : NSObject {
	NSLock		*mLock;
	SafeStatus	*mSafeStatus;
}

+ (BackgroundUpdater*)shared;

- (void)performUpdate;
- (BOOL)tryLockFor:(NSTimeInterval)seconds;
- (void)lock;
- (void)unlock;
- (void)stopAndWaitForCompletion;

@end
