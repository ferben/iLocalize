//
//  Utils.m
//  iLocalize3
//
//  Created by Jean on 6/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "Utils.h"


@implementation Utils

static NSThread *mainThread = nil;

+ (BOOL)isMainThread
{
	if(mainThread == nil) {
		mainThread = [NSThread currentThread];
	}
	return [NSThread currentThread] == mainThread;
}

+ (NSPoint)posInCellAtMouseLocation:(NSPoint)pos row:(int*)row column:(int*)column tableView:(NSTableView*)tv
{
	NSPoint posInTableView = [tv convertPoint:pos fromView:nil];
	*row = [tv rowAtPoint:posInTableView];
	*column = [tv columnAtPoint:posInTableView];
	NSPoint posInCell;
	if(*row >= 0 && *column >= 0) {
		NSRect cellFrame = [tv frameOfCellAtColumn:*column row:*row];
		posInCell = NSMakePoint(posInTableView.x-cellFrame.origin.x, posInTableView.y-cellFrame.origin.y);
	} else {
		posInCell = NSMakePoint(-1, -1);
	}
	return posInCell;
}

+ (SInt32)getOSVersion
{
	SInt32 MacVersion;
	if (Gestalt(gestaltSystemVersion, &MacVersion) == noErr) {
		return MacVersion;
	} else {
		return 0;
	}
}

+ (BOOL)isOSVersionTigerAndBelow:(SInt32)version
{
	return version <= 0x1049;
}

+ (BOOL)isOSTigerAndBelow
{
	return [Utils isOSVersionTigerAndBelow:[Utils getOSVersion]];
}

@end
