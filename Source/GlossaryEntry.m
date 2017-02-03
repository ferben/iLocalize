//
//  ILGlossaryEntry.m
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryEntry.h"


@implementation GlossaryEntry

@synthesize source;
@synthesize translation;


- (BOOL)isEqual:(id)anObject
{    
    if(![anObject isKindOfClass:[GlossaryEntry class]]) {
        return NO;
    }
    
    return [self.source isEqual:[anObject source]] && [self.translation isEqual:[anObject translation]];
}

- (NSUInteger)hash
{
    NSUInteger value = 17;
    value += 37*self.source.hash;
    value += 37*self.translation.hash;
    return value;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ = %@", self.source, self.translation];
}

@end
