//
//  SimpleFileController.m
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SimpleFileController.h"


@implementation SimpleFileController

@synthesize path;

- (id) init
{
	self = [super init];
	if (self != nil) {
		strings = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addString:(id<StringControllerProtocol>)string
{
	[strings addObject:string];
}

- (NSArray*)filteredStringControllers
{
	return strings;
}

- (NSArray*)stringControllers
{
	return strings;
}

- (NSString*)filename
{
	return [path lastPathComponent];
}

- (NSString*)relativeFilePath
{
	return path;
}

@end
