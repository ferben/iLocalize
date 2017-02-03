//
//  IGroupEngineAlternate.m
//  iLocalize
//
//  Created by Jean Bovet on 11/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngineAlternate.h"
#import "PreferencesInspectors.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

@implementation IGroupEngineAlternate

- (id)init
{
    if(self = [super init]) {
    }
    return self;
}


- (int)alternateMatchThreshold
{
    switch([[PreferencesInspectors shared] alternateTranslationThreshold]) {
        case 0: return 1;
        case 1: return 5;
        case 2: return 10;
        case 3: return 40;
        default: return 5;
    }
}

- (void)matchString:(IGroupEngineState*)state withFileController:(FileController*)fc threshold:(int)threshold
{
    // copy to avoid concurrent modification of the visibleStringControllers array
    NSArray *copies = [NSArray arrayWithArray:[fc visibleStringControllers]];
    for(StringController *sc in copies) {
        if(state.outdated) break;

        // Skip empty translation
        if([[sc translation] length] == 0)
            continue;
        
        NSString *a = [sc base];
        NSString *b = state.selectedString;
        float score = 0;
        if(![a isEqualCaseInsensitiveToString:b]) {
            if(threshold == 1)
                continue;
            else
                score = [a compareWithWord:b];
        }
        
        if(score >= threshold)
            continue;
        
        score /= threshold;
        score = 1-score;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"fc"] = fc;
        dic[@"sc"] = sc;
        dic[@"score"] = @(score*100);
        [self addResult:dic forState:state];
    }    
}

- (void)matchString:(IGroupEngineState*)state withFileControllers:(NSArray*)fcs threshold:(int)threshold
{
    for(FileController *fc in fcs) {
        if(state.outdated) break;
        @autoreleasepool {
            [self matchString:state withFileController:fc threshold:threshold];        
        }
    }
}

#pragma mark Subclass implementation

- (void)_runForState:(IGroupEngineState*)state
{
    if([state.selectedString length] == 0) return;
    
    // Run only if the selected string changed (and the language changed)
    if(state.languageChanged || state.selectedStringChanged) {
        int threshold = [self alternateMatchThreshold];
        NSArray *fcs = [[state.projectProvider selectedLanguageController] fileControllers];
        [self matchString:state withFileControllers:fcs threshold:threshold];        
    }
}

@end
