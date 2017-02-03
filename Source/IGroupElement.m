//
//  IGroupElement.m
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupElement.h"


@implementation IGroupElement

@synthesize source;
@synthesize target;

+ (IGroupElement*)elementWithSource:(NSString*)source target:(NSString*)target
{
    IGroupElement *e = [[self alloc] init];
    e.source = source;
    e.target = target;
    return e;
}


- (NSUInteger)hash
{
    NSUInteger value = 17;
    value += 37*self.source.hash;
    value += 37*self.target.hash;
    return value;
}

- (BOOL)isEqual:(id)other
{
    if(![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [[other source] isEqual:self.source] &&
    [[other target] isEqual:self.target];
}

@end
