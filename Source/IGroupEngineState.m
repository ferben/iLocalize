//
//  IGroupEngineState.m
//  iLocalize
//
//  Created by Jean Bovet on 10/22/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngineState.h"


@implementation IGroupEngineState

@synthesize baseLanguage;
@synthesize targetLanguage;
@synthesize selectedString;

@synthesize projectProvider;
@synthesize languageChanged;
@synthesize selectedStringChanged;
@synthesize outdated;

+ (IGroupEngineState*)stateWithOriginalState:(IGroupEngineState*)original
{
	IGroupEngineState *state = [[IGroupEngineState alloc] init];
	state.projectProvider = original.projectProvider; // copy the provider because it is needed for everything
	state.baseLanguage = original.baseLanguage;
	state.targetLanguage = original.targetLanguage;
	state.selectedString = original.selectedString;
	state.languageChanged = original.languageChanged;
	state.selectedStringChanged = original.selectedStringChanged;
	return state;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.languageChanged = YES;
		self.selectedStringChanged = YES;
		self.outdated = NO;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	IGroupEngineState *copy = [IGroupEngineState stateWithOriginalState:self];
	return copy;
}

- (NSUInteger)hash
{
	NSUInteger value = 17;
	value += 37*baseLanguage.hash;
	value += 37*targetLanguage.hash;
	value += 37*selectedString.hash;
	return value;
}

- (BOOL)isEqual:(id)other
{
	if(![other isKindOfClass:[self class]]) {
		return NO;
	}
	
	return [[other baseLanguage] isEqual:baseLanguage] &&
	[[other targetLanguage] isEqual:targetLanguage] &&
	[[other selectedString] isEqual:selectedString];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@-%@-%@", self.baseLanguage, self.targetLanguage, self.selectedString];
}

@end
