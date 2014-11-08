//
//  ProjectFiles.h
//  iLocalize
//
//  Created by Jean on 12/20/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@class ProjectWC;
@class TableViewCustom;
@class AZArrayController;
@class FileController;
@class StringEncoding;
@class ProjectFileWarningWC;

@interface ProjectFilesController : NSViewController<NSTableViewDelegate,NSTableViewDataSource> {
@public
	IBOutlet AZArrayController	*mFilesController;	
	IBOutlet TableViewCustom	*mFilesTableView;
	IBOutlet NSMenuItem			*mFileEncodingContextualMenuItem;
	IBOutlet NSMenu				*mFilesColumnTableViewContextualMenu;
	IBOutlet NSMenu				*mFilesTableViewContextualMenu;
	IBOutlet NSView				*mTranslateWithFileStringsView;
	
	ProjectWC					*__unsafe_unretained _projectWC;
	NSMenu						*mOpenPreviousVersionMenu;
	ProjectFileWarningWC		*mProjectFileWarning;
	NSArray						*mPreviouslySelectedFiles;
	NSMutableArray				*mSelectedFiles;
	BOOL						mSelectedFilesSupportEncoding;
	NSMenu						*mFileEncodingMenu;
	NSMutableSet				*mSelectedEncodingSet;	
	int							mSearchContext;
	
	// Value of the previous selected file controller relative
	// path that is cached to indicate if the open previous version
	// menu needs to be re-rendered.
	NSString *previousRelativePathForVersionMenu;
}

@property (strong) NSString *previousRelativePathForVersionMenu;
@property (assign) ProjectWC *projectWC;

+ (ProjectFilesController*)newInstance:(ProjectWC*)projectWC;

- (void)bindToLanguagesController:(NSArrayController*)controller;
- (void)unbindFromLanguagesController;

- (void)save;
- (void)selectSavedFile;

- (void)rememberSelectedFiles;
- (void)selectRememberedFiles;

- (void)prefsShowSmartPathDidChange;
- (void)updateSelectedFilesEncoding;
- (BOOL)selectedFilesSupportEncoding;

- (NSString*)handleToolTipRequestedAtPosition:(NSPoint)pos;

- (void)setFilesListWithGlobalFlag:(BOOL)global;

- (TableViewCustom*)filesTableView;
- (NSArrayController*)filesArrayController;
- (NSArray*)filesController;

- (NSArray*)selectedFileControllers;
- (void)selectFileController:(FileController*)fc;

- (void)selectFirstFile;
- (void)deselectAll;
- (void)setNeedsDisplayToAllTableViews;

- (void)showHideFilesTableColumn:(id)sender;
- (void)syncFilesTableColumns;

- (void)setFilesColumnInfo:(NSArray*)infos;
- (NSArray*)filesColumnInfo;

- (int)ignoreStateForSelectedFiles;
- (int)encodingStateForSelectedFilesWithEncoding:(StringEncoding*)se;

- (void)showWarning:(FileController*)fc;
- (void)removeFromOpenPreviousVersionMenu;

- (NSString*)previousPathForFileController:(FileController*)fc;
- (void)openPreviousVersionMenuNeedsUpdate:(NSMenu*)menu;

- (void)exportToStrings;
- (void)translateUsingStringsFile;

@end
