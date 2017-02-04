//
//  BackgroundUpdaterOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 10/13/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "Operation.h"

@interface BackgroundUpdaterOperation : Operation
{
    NSArray  *fcs;
}

@property (nonatomic, strong) NSArray *fcs;

@end
