//
//  NSArray+Extensions.m
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "NSArray+Extensions.h"
#import "NSString+Extensions.h"

#import "FileController.h"

@implementation NSArray (iLocalize)

- (id)firstObject
{
	if([self count]>0)
		return self[0];
	else
		return NULL;
}

- (NSArray*)arrayByRemovingPrefix:(NSString*)prefix
{
	NSMutableArray *array = [NSMutableArray array];
	for(NSString *string in self) {
		NSString *ns = [string stringByRemovingPrefix:prefix];
		if(ns)
			[array addObject:ns];
		else
			NSLog(@"*** Cannot remove prefix %@ from string %@", prefix, string);
	}
	return array;
}

- (NSArray*)arrayOfObjectsNotInArray:(NSArray*)objects
{
	NSMutableArray *array = [NSMutableArray array];
	for(id object in self) {
		if(![objects containsObject:object])
			[array addObject:object];
	}
	return array;
}

- (NSArray*)objectsAtRows:(NSArray*)rows
{
	NSMutableArray *objects = [NSMutableArray array];
	for(id row in rows) {
		[objects addObject:self[[row intValue]]];
	}
	return objects;
}

- (void)setMenuItemsState:(int)state
{
	for(id item in self) {
		[item setState:state];		
	}
}

- (NSImage*)imageUnion
{
	if([self count] < 2)
		return [self firstObject];

	NSSize totalSize = NSMakeSize(0, 0);
	
	const float space = 2;
	
	for(NSImage *image in self) {
		NSSize size = [image size];
		totalSize.height = MAX(totalSize.height, size.height);
		totalSize.width += size.width+space;
	}
	
	float offset = 0;
	NSImage *totalImage = [[NSImage alloc] initWithSize:totalSize];
	[totalImage lockFocus];
	
	for(NSImage *image in self) {
		NSSize imageSize = [image size];
		[image drawInRect:NSMakeRect(offset, totalSize.height*0.5-imageSize.height*0.5, imageSize.width, imageSize.height)
				operation:NSCompositeSourceOver
				 fraction:1];
		offset += imageSize.width+space;
	}		
	
	[totalImage unlockFocus];
	
	return totalImage;
}

- (NSArray*)pathsIncludingOnlyBundles
{
	NSMutableArray *array = [NSMutableArray array];
	for(NSString *path in self) {
		if([path isPathBundle]) {
			[array addObject:path];
		}
	}
	return array;
}

- (NSArray*)pathsExcludingBundles
{
	NSMutableArray *array = [NSMutableArray array];
	for(NSString *path in self) {
		if(![path isPathBundle]) {
			[array addObject:path];
		}
	}
	return array;
}

- (NSArray*)pathsExcludingExtensions:(NSArray*)extensions
{
	NSMutableArray *array = [NSMutableArray array];
	for(NSString *path in self) {
		if(![extensions containsObject:[path pathExtension]])
			[array addObject:path];
	}
	return array;
}

- (BOOL)supportOperation:(int)op
{
	for(id object in self) {
		if(![object respondsToSelector:@selector(supportOperation:)]) continue;
		if(![object supportOperation:op]) return NO;
	}
	return YES;
}

- (NSArray*)buildArrayOfFileControllerPaths
{
	NSMutableArray *array = [NSMutableArray array];
	for(FileController *fc in self) {
		[array addObject:[fc absoluteFilePath]];		
	}
	return array;
}

@end
