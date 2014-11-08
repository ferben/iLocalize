//
//  PreferencesAdvanced.h
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@interface PreferencesAdvanced : PreferencesObject {
	IBOutlet NSArrayController *mIbtoolPlugins;
	IBOutlet NSMatrix	*mUpdatesModeMatrix;
}

+ (id)shared;

- (BOOL)autoSnapshotEnabled;
- (int)maximumNumberOfSnapshots;

- (IBAction)selectProjectDefaultFolder:(id)sender;

- (NSString*)interfaceBuilder3Path;

- (IBAction)browseIB3Path:(id)sender;

- (IBAction)addIbtoolPlugin:(id)sender;

@end
