//
//  DisplayLanguageTransformer.m
//  iLocalize
//
//  Created by Jean Bovet on 4/27/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "DisplayLanguageTransformer.h"

@implementation DisplayLanguageTransformer

+ (Class)transformedValueClass { return [NSString class]; }

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
	if([value isKindOfClass:[NSString class]]) {
		return [value displayLanguageName];
	} else {
		return value;
	}
}

@end
