//
//  NSData+Extensions.m
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSData+Extensions.h"


@implementation NSData (Extensions)

- (NSURL*)newURLFromAliasData
{
	Handle ah = NewHandle([self length]);
	HLock(ah);
	[self getBytes:*ah length:[self length]];
	HUnlock(ah);
		
	FSRef target;
	Boolean wasChanged;
	OSErr err = FSResolveAlias(NULL, (AliasHandle)ah, &target, &wasChanged);			
	if(err == noErr) {
		CFURLRef aliasURL = CFURLCreateFromFSRef(NULL, &target);
		return (NSURL*)CFBridgingRelease(aliasURL);
	} else {
		NSLog(@"Failed to resolve the alias record with error %d", err);
	}	
	return nil;
}

@end
