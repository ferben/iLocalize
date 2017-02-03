//
//  FMStringsExtensions.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMStringsExtensions.h"

#import "StringController.h"
#import "StringModel.h"

#import "Constants.h"

@implementation NSArray (FMStringsExtension)

- (StringController*)stringControllerForKey:(NSString*)key
{
    __block StringController *controller = nil;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StringController *sc = obj;
        if([[sc key] isEqualToString:key]) {
            controller = sc;
            *stop = YES;
        }
    }];
    return controller;
}

@end
