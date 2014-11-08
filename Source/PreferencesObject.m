//
//  PreferencesObject.m
//  iLocalize3
//
//  Created by Jean on 28.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@implementation PreferencesObject

- (void)setWindow:(NSWindow*)window
{
	mWindow = window;	
}

- (NSView*)prefsView
{
	return mPrefsView;
}

@end
