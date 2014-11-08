//
//  CustomTypesetter.m
//  iLocalize
//
//  Created by Jean Bovet on 2/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "CustomTypesetter.h"


@implementation CustomTypesetter

- (BOOL)shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex
{
	return NO;
}

- (BOOL)shouldBreakLineByHyphenatingBeforeCharacterAtIndex:(NSUInteger)charIndex
{
	return NO;
}

@end
