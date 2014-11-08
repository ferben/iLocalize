//
//  PreferencesGeneral.h
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@interface PreferencesGeneral : PreferencesObject {

}

+ (id)shared;

- (void)setInspectors:(NSArray*)array;
- (NSArray*)inspectors;

- (BOOL)automaticallySaveModifiedFiles;
- (BOOL)automaticallyReloadFiles;

- (BOOL)automaticallySaveProject;
- (int)automaticallySaveProjectDelay;

- (BOOL)autoUpdateSmartFilters;

- (BOOL)recentDocumentsOnlyProject;

@end
