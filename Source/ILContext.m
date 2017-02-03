//
//  ILContext.m
//  iLocalize
//
//  Created by Jean Bovet on 3/8/14.
//  Copyright (c) 2014 Arizona Software. All rights reserved.
//

#import "ILContext.h"

@implementation ILContext

static ILContext *_shared = nil;

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}

@end

