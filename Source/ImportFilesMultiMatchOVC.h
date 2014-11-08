//
//  MultipleFileMatchWC.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "Protocols.h"

@class LanguageController;

/**
 Displays for each file its potential matches so the user can choose which one to take.
 */
@interface ImportFilesMultiMatchOVC : OperationViewController<PopupTableColumnDelegate> {
	IBOutlet NSTableView *tableView;
	
	// Array of all the FileMatchItem objects
	NSArray	*matchItems;
	
	// Array of the FileMatchItem that have more than once matches
	NSMutableArray *multiMatchItems;
}

@property (strong) NSArray *matchItems;

/**
 Returns an array of FileMatchItem for the given list of files. The returned array contains
 for each file its matching file controllers if any.
 
 @param multipleMatch YES if one or more files have multiple matches.
 */
+ (NSArray*)matchesFiles:(NSArray*)files languageController:(LanguageController*)languageController multipleMatch:(BOOL*)multipleMatch;

@end
