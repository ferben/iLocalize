//
//  OptimizeEngine.h
//  iLocalize3
//
//  Created by Jean on 22.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@interface OptimizeEngine : AbstractEngine
{
}

- (void)compactNibInApp:(NSString *)app;
- (void)upgradeNibInApp:(NSString *)app;
- (void)cleanApp:(NSString *)app;

@end
