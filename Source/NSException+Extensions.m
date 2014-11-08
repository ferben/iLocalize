//
//  NSException+Extensions.m
//  iLocalize
//
//  Created by Jean on 10/7/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "NSException+Extensions.h"

@implementation NSException (Extensions)

- (void)printStackTrace
{
	NSLog(@"Stack trace: %@", [self callStackSymbols]);
}

@end
