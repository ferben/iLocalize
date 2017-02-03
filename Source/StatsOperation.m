//
//  StatsOperation.m
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "StatsOperation.h"
#import "StatsWC.h"

#import "OperationWC.h"

@implementation StatsOperation

- (StatsWC*)statsWC
{
    return (StatsWC*)[self instanceOfAbstractWCName:@"StatsWC"];
}

- (void)stats
{
    [[self statsWC] setDidCloseSelector:nil target:self];
    [[self statsWC] showAsSheet];                
}

@end
