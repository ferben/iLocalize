//
//  IGroupEngineGlossary.m
//  iLocalize
//
//  Created by Jean Bovet on 10/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngineGlossary.h"
#import "GlossaryManager.h"
#import "Glossary.h"
#import "GlossaryEntry.h"
#import "GlossaryScope.h"
#import "PreferencesInspectors.h"

@implementation IGroupEngineGlossary

@synthesize scope;

- (id)init
{
	if(self = [super init]) {
		scope = [[GlossaryScope alloc] init];		
	}
	return self;
}


- (NSInteger)glossaryMatchThreshold
{
	switch ([[PreferencesInspectors shared] glossaryMatchThreshold])
    {
		case 0: return 1;
		case 1: return 5;
		case 2: return 10;
		case 3: return 40;
		default: return 5;
	}
}

- (void)matchString:(IGroupEngineState*)state inGlossary:(Glossary*)glossary threshold:(int)threshold
{	
	NSString *s = state.selectedString;
	[[glossary entries] enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		GlossaryEntry *entry = obj;
		if(state.outdated) {
			*stop = YES;
			return;
		}
		
		NSString *a = entry.source;
		if([a length] == 0)	return;
		
		NSString *b = s;
		float score = 0;
		
		if(![a isEqualToString:b ignoreCase:NO]) {
			if(threshold == 1) {
				return;				
			} else {
				if([a isEqualCaseInsensitiveToString:b]) {
					// Difference in case
					score = 0.1;
				} else if(b != nil && [[a lowercaseString] hasPrefix:[b lowercaseString]]) {
					// String begins the word
					score = 1;
				} else {
					score = [a compareWithWord:b];												
				}
			}
		}
		
//		NSLog(@"%@ ? %@ > %.2f (threshold = %d)", a, b, score, threshold);

		if(score >= threshold) {
			return;
		}
		
		score /= threshold;
		score = 1-score;
				
        // Always lower the score of empty translation
        if (entry.translation.length == 0) {
            score = 0.01;
        }
        
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		dic[@"base"] = entry.source;
		dic[@"translation"] = entry.translation;
		dic[@"score"] = @(score*100);
		dic[@"glossary"] = glossary;		
		
		[self addResult:dic forState:state];
	}];
}

#pragma mark Subclass implementation

- (void)_runForState:(IGroupEngineState*)state
{
	if(scope.projectProvider == nil) {
		scope.projectProvider = state.projectProvider;	
	}

	// Reset the glossary list if the language(s) changed
	if(state.languageChanged) {
		[scope refresh];
	}

	if([state.selectedString length] == 0) return;
	
	// Run only if the selected string changed (and the language changed)
	if(state.languageChanged || state.selectedStringChanged) {
		int threshold = [self glossaryMatchThreshold];
        // Note: don't run in concurrent mode because the NSXMLDocument is not thread safe
        // and this can lead to issue reading a glossary
		[[scope selectedGlossaries] enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			Glossary *glossary = obj;
			if(state.outdated) {
				*stop = YES;
				return;
			}
			[self matchString:state inGlossary:glossary threshold:threshold];							
		}];
	}
}

@end
