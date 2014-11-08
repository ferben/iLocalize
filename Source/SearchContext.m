//
//  SearchContext.m
//  iLocalize
//
//  Created by Jean Bovet on 2/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SearchContext.h"

@implementation SearchContext

@synthesize scope;
@synthesize options;
@synthesize ignoreCase;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.scope = SCOPE_STRINGS_TRANSLATION|SCOPE_STRINGS_BASE;
		self.options = SEARCH_CONTAINS;
		self.ignoreCase = YES;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	SearchContext *c = [[SearchContext alloc] init];
	c.scope = self.scope;
	c.options = self.options;
	c.ignoreCase = self.ignoreCase;
	return c;
}

@end
