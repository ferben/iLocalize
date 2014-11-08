//
//  BackgroundUpdater.m
//  iLocalize3
//
//  Created by Jean on 02.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "BackgroundUpdater.h"
#import "BackgroundUpdaterDriver.h"

#import "ProjectDocument.h"
#import "ProjectWC.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "EngineProvider.h"
#import "SynchronizeEngine.h"

#import "SaveAllOperation.h"

#import "PreferencesGeneral.h"

#import "GlossaryManager.h"

#import "Constants.h"
#import "SafeStatus.h"

#define STOPPED		0
#define RUNNING		1
#define STOP		2

@implementation BackgroundUpdater

static BackgroundUpdater *_shared = nil;

+ (BackgroundUpdater*)shared
{
    @synchronized(self) {
        if(_shared == nil)
            _shared = [[BackgroundUpdater alloc] init];        
    }
	return _shared;
}

- (id)init
{
	if(self = [super init]) {
		mLock = [[NSLock alloc] init];
		mSafeStatus = [[SafeStatus alloc] init];
		[mSafeStatus setStatus:STOPPED];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(projectProviderWillClose:)
													 name:ILNotificationProjectProviderWillClose
												   object:nil];		
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)projectProviderWillClose:(NSNotification*)notif
{
	[self stopAndWaitForCompletion];
}

- (void)performUpdateWithProjectProvider:(id<ProjectProvider>)projectProvider
{
    NSMutableArray *fcToUpdate = [NSMutableArray array];
    
	for(LanguageController *languageController in [[projectProvider projectController] languageControllers]) {
		if([mSafeStatus status] == STOP) break;
		
		for(FileController *fileController in [languageController fileControllers]) {
			if([mSafeStatus status] == STOP) break;
			
            if ([fileController needsToUpdateStatus]) {
                [fcToUpdate addObject:fileController];
            }
		}
	}

    if (fcToUpdate.count > 0) {
        NSLog(@"[BackgroundUpdater] Going to update %ld files", fcToUpdate.count);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[BackgroundUpdaterDriver driverWithProjectProvider:projectProvider] executeWithArguments:@{@"fcs": fcToUpdate}];
        });        
    }
}

- (void)updateAllProjects
{
	for(NSWindow *window in [NSApp windows]) {
		id controller = [window windowController];
		if([controller isKindOfClass:[ProjectWC class]]) {
			[self performUpdateWithProjectProvider:[controller projectDocument]];
		}
		
		if([mSafeStatus status] == STOP)
			break;
	}	
}

- (void)updateGlossaryPaths
{
	[[GlossaryManager sharedInstance] reload];
}

#pragma mark -

- (void)performUpdate
{	
	// Do not execute the background more than one at a time
	if(![mLock tryLock])
		return;
			
	@try {
		[mSafeStatus waitForStatus:STOPPED];
		[mSafeStatus setStatus:RUNNING];

		[self updateAllProjects];
		[self updateGlossaryPaths];
	}
	@catch(id exception) {
		[exception printStackTrace];
		NSLog(@"[BackgroundUpdater] Exception while performing background update: %@", exception);		
	}
	@finally {
		[mSafeStatus setStatus:STOPPED];
		[mLock unlock];		
	}
}

- (BOOL)tryLockFor:(NSTimeInterval)seconds
{
	return [mLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

- (void)lock
{
	[mLock lock];
}

- (void)unlock
{
	[mLock unlock];
}

- (void)stopAndWaitForCompletion
{
	if([mSafeStatus setStatus:STOP ifStatusEquals:RUNNING]) {
		while([mSafeStatus status] != STOPPED) {
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
		}
	}
}

@end
