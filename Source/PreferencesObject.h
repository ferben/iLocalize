//
//  PreferencesObject.h
//  iLocalize3
//
//  Created by Jean on 28.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface PreferencesObject : NSObject {
	IBOutlet NSView				*mPrefsView;    
	NSWindow					*mWindow;
}

- (void)setWindow:(NSWindow*)window;
- (NSView*)prefsView;

@end
