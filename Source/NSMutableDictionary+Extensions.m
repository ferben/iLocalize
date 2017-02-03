//
//  NSMutableDictionary.m
//  iLocalize
//
//  Created by Jean on 2/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSMutableDictionary+Extensions.h"


@implementation NSMutableDictionary (Extension)

- (void)setObjectOrNil:(id)object forKey:(id)key
{
    if(object) {
        self[key] = object;        
    } else {
        [self removeObjectForKey:key];
    }
}

- (void)setBoolean:(BOOL)value forKey:(id)key
{
    self[key] = @(value);
}

@end
