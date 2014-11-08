//
//  PreferencesFilters.h
//  iLocalize3
//
//  Created by Jean on 28.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@class StringController;

@interface PreferencesFilters : PreferencesObject {
	IBOutlet NSArrayController	*mRegexController;
	IBOutlet NSTableView		*mRegexTableView;
	
	NSMutableArray				*mCachedRegexArray;
	NSCharacterSet				*mCachedLetterCharacterSet;
	BOOL						mUpdateRegexCache;

	BOOL						mMatchStringsWithEmptyBase;
	BOOL						mMatchStringsWithNoLetter;
	BOOL						mMatchStringsWithOnlyOneLetter;
}

+ (id)shared;

- (IBAction)addFilter:(id)sender;
- (IBAction)removeFilter:(id)sender;
- (IBAction)filterAction:(id)sender;
- (BOOL)stringControllerMatchAnyRegex:(StringController*)sc;

@end
