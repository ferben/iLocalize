//
//  ASManager.m
//  iLocalize
//
//  Created by Jean on 12/2/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ASManager.h"


@implementation ASManager

static ASManager *shared = nil;

+ (ASManager*)shared
{
	@synchronized(self) {
		if(shared == nil) {
			shared = [[ASManager alloc] init];
		}
	}
	return shared;
}

- (id)init
{
	if(self = [super init]) {
		mCommandInProgress = nil;
	}
	return self;
}

- (void)beginAsyncCommand:(NSScriptCommand*)cmd delegate:(id<ASManagerDelegate>)delegate
{
	mCommandInProgress = cmd;
	mDelegate = delegate;
	[cmd suspendExecution];
	//mSuspensionID = [[NSAppleEventManager sharedAppleEventManager] suspendCurrentAppleEvent];
}

- (void)endAsyncCommandWithResult:(id)result
{
	[mCommandInProgress resumeExecutionWithResult:result];
	mCommandInProgress = nil;	
}

- (void)endAsyncCommand
{
	[self endAsyncCommandWithResult:nil];
	//[[NSAppleEventManager sharedAppleEventManager] resumeWithSuspensionID:mSuspensionID];
}

- (void)beginSyncCommand:(NSScriptCommand*)cmd delegate:(id<ASManagerDelegate>)delegate
{
	mCommandInProgress = cmd;
	mDelegate = delegate;	
}

- (void)endSyncCommand
{
	mCommandInProgress = nil;	
}

- (BOOL)isCommandInProgress
{
	return mCommandInProgress != nil;
}

- (id)attributeForKey:(NSString*)key
{
	return [self attributeForKey:key defaultAttribute:nil];
}

- (BOOL)boolValueForKey:(NSString*)key
{
	return [self boolValueForKey:key defaultValue:NO];
}

- (id)attributeForKey:(NSString*)key defaultAttribute:(id)attribute
{
	if([self isCommandInProgress]) {
		return [mDelegate scriptAttributeForKey:key command:mCommandInProgress];
	} else {
		return attribute;
	}
}

- (BOOL)boolValueForKey:(NSString*)key defaultValue:(BOOL)value
{
	if([self isCommandInProgress]) {
		return [mDelegate scriptBoolValueForKey:key command:mCommandInProgress];
	} else {
		return value;
	}
}

- (int)intValueForKey:(NSString*)key defaultValue:(int)value
{
	if([self isCommandInProgress]) {
		return [mDelegate scriptIntValueForKey:key command:mCommandInProgress];
	} else {
		return value;
	}	
}

- (void)operationCompleted:(NSString*)op
{
	if([self isCommandInProgress]) {
		[mDelegate scriptOperationCompleted:op];
	}
}

@end
