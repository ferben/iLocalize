//
//  SafeStatus.m
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SafeStatus.h"


@implementation SafeStatus

- (id)init
{
    if(self = [super init]) {
        mStatus = 0;
    }
    return self;
}


- (void)setStatus:(int)status
{
    @synchronized(self) {
        mStatus = status;        
    }
}

- (int)status
{
    int temp = 0;
    @synchronized(self) {
        temp = mStatus;        
    }
    return temp;
}

- (BOOL)setStatus:(int)newStatus ifStatusEquals:(int)status
{
    BOOL success = NO;
    @synchronized(self) {
        if([self status] == status) {
            [self setStatus:newStatus];
            success = YES;
        }        
    }
    return success;
}

- (void)waitForStatus:(int)status
{
    while([self status] != status) {
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
}

@end
