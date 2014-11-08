//
//  NibEngineResult.m
//  iLocalize
//
//  Created by Jean on 3/12/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NibEngineResult.h"


@implementation NibEngineResult

@synthesize success;
@synthesize error=_error;
@synthesize output=_output;

- (id)init
{
	if(self = [super init]) {
		_error = nil;
		_output = nil;
	}
	return self;
}


@end
