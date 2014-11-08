//
//  NSDictionary+Extensions.m
//  iLocalize
//
//  Created by Jean on 2/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSDictionary+Extensions.h"


@implementation NSDictionary (Extensions)

- (BOOL)booleanForKey:(id)key
{
	return [self[key] boolValue];
}

@end
