//
//  PreferencesWC.h
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class Toolbar;

@interface PreferencesWC : NSWindowController {
	NSMutableArray		*mObservers;
	Toolbar				*mToolbar;    
}

+ (PreferencesWC*)shared;

- (void)show;

- (void)load;
- (void)save;

- (void)setProjectPresets:(NSArray*)array;
- (NSArray*)projectPresets;

- (void)setLicenseBundleVersionAccepted:(NSString*)build;
- (NSString*)licenseBundleVersionAccepted;

- (void)addObserver:(id)observer selector:(SEL)selector forKey:(NSString*)key;
- (void)removeObserver:(id)observer;

@end
