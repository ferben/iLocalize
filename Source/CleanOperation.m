//
//  CleanOperation.m
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "CleanOperation.h"
#import "CleanWC.h"

#import "OperationWC.h"

@implementation CleanOperation

- (CleanWC*)cleanWC
{
	return (CleanWC*)[self instanceOfAbstractWCName:@"CleanWC"];
}

- (void)clean
{
	[[self cleanWC] setDidCloseSelector:@selector(performClean) target:self];
	[[self cleanWC] showAsSheet];				
}

- (void)performClean
{
	if([[self cleanWC] hideCode] == 0) {
		[self close];
		return;
	}
	
	[[self operation] setTitle:NSLocalizedString(@"Cleaning…", nil)];
	[[self operation] setCancellable:YES];
	[[self operation] setIndeterminate:YES];
	[[self operation] showAsSheet];
	
    [[self operationDispatcher] cleanWithAttributes:[[self cleanWC] attributes] completion:^(id results) {
        [[self operation] hide];
        [self close];
    }];
}

@end
