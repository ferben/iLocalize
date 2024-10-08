//
//  PreferencesInspectors.h
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@interface PreferencesInspectors : PreferencesObject
{
}

+ (id)shared;

- (BOOL)alternateTranslationLimitEnable;
- (NSInteger)alternateTranslationLimit;
- (NSInteger)alternateTranslationThreshold;

- (BOOL)glossaryMatchLimitEnable;
- (NSInteger)glossaryMatchLimit;
- (NSInteger)glossaryMatchThreshold;

@end
