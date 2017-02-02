//
//  ProjectWC.h
//  iLocalize3
//
//  Created by Jean on 29.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectWindowProtocol.h"

@class ProjectDocument;
@class ProjectPrefs;

@class ProjectDetailsController;
@class ProjectExplorerController;
@class ProjectViewSearchController;
@class ProjectFilesController;
@class ProjectLabels;
@class ProjectStructureViewController;
@class ProjectStatusBarController;

@class ProjectMenuFile;
@class ProjectMenuEdit;
@class ProjectMenuView;
@class ProjectMenuProject;
@class ProjectMenuTranslate;
@class ProjectMenuGlossary;
@class ProjectMenuToolbar;
@class ProjectMenuDebug;

@class ProjectController;
@class EngineProvider;
@class OperationDispatcher;
@class LanguageController;
@class FileController;
@class StringController;

@class Explorer;
@class ExplorerItem;
@class ExplorerFilter;

@class OperationWC;
@class DragAndDropOperation;

@class FMEditor;
@class CustomFieldEditor;
@class HistoryManager;

@class AZSplitView;
@class AZSplitViewThumbView;

@interface ProjectWC : NSWindowController <ProjectWindowProtocol, NSSplitViewDelegate, NSMenuDelegate>
{
	IBOutlet NSObjectController		*mProjectController;
	IBOutlet NSArrayController		*mLanguagesController;
	
	// Project controllers
	ProjectExplorerController		*mProjectExplorerController;
	ProjectDetailsController		*mProjectDetailsController;
	ProjectFilesController			*mProjectFilesController;
	ProjectViewSearchController		*mProjectViewSearchController;
	ProjectStructureViewController  *mProjectStructureController;
	ProjectStatusBarController		*mProjectStatusBarController;

	// Project handlers	
	IBOutlet ProjectLabels			*mProjectLabels;
	
	// Menu handlers
	ProjectMenuFile					*mProjectMenuFile;
	ProjectMenuEdit					*mProjectMenuEdit;
	ProjectMenuView					*mProjectMenuView;
	ProjectMenuProject				*mProjectMenuProject;
	ProjectMenuTranslate			*mProjectMenuTranslate;
	ProjectMenuGlossary				*mProjectMenuGlossary;
	ProjectMenuToolbar				*mProjectMenuToolbar;
	ProjectMenuDebug				*mProjectMenuDebug;

	// Main views
	NSSplitView						*mMainSplitView;	
		// Left-side views:
		AZSplitView						*mSidebarSplitView;	
			NSView						*mSidebarDetailsView;
			// Bottom of left-side views
		AZSplitViewThumbView			*mMainSplitViewThumbView;
		
		// Right-side views
		NSView							*mRightSideContainerView;
		NSSplitView						*mRightSideContainerSplitView;
			NSSplitView						*mStructureFilesSplitView;
			
	// Editor views
	NSView							*mFileEditorContainerView;
	IBOutlet NSView					*mFileEditorNoView;
	IBOutlet NSView					*mFileEditorNotEditableView;
	IBOutlet NSView					*mFileEditorNotApplicableView;
	IBOutlet NSView					*mFileEditorIgnoreView;
		
	// Toolbar
    IBOutlet NSToolbar              *mToolbar;
	IBOutlet NSPopUpButton			*mLanguagePopUp;
	IBOutlet NSSearchField			*mSearchField;
	IBOutlet NSToolbarItem			*mLanguageToolbarItem;
	IBOutlet NSToolbarItem			*mSearchToolbarItem;
	
	// Menu items
	IBOutlet NSMenuItem				*mLabelsMenuItem;

	// Operations
	DragAndDropOperation			*mDragAndDropOperation;
	
	// States
	FMEditor						*mCurrentFMEditor;
    CustomFieldEditor               *mCustomFieldEditor;
	NSPredicate						*mExplorerPredicate;
	NSPredicate						*mPathPredicate;
	
    // The key view loop
    NSMutableArray                  *keyViewsLoop;
    
	// State to re-connect the interface
	NSString *reconnectLanguage;
	NSString *reconnectFile;
	
	// History
    HistoryManager                  *mHistoryManager;

	// Elapsed time
	NSDate							*mElapsedDate;
	NSTimer							*mElapsedTimer;	
	
	// UI states
	BOOL							mSearchViewVisible;
}

@property (copy) NSString *reconnectLanguage;
@property (copy) NSString *reconnectFile;

- (void)addToAsNextResponder:(NSResponder*)responder;

- (void)toggleStructureView;
- (void)ensureStructureView;
- (BOOL)isStructureViewVisible;

- (void)toggleStatusBar;
- (void)ensureStatusBar;
- (BOOL)isStatusBarVisible;

- (void)showSearchView;
- (void)showSearchView:(ExplorerFilter*)filter;
- (void)hideSearchView;

- (void)selectSearchField;

- (void)doSearch;
- (void)doSaveSearch;

- (void)doReplace;
- (void)doReplaceAll;

- (int)elapsedMinutesSinceProjectWasOpened;

- (void)updateProjectToolbar;
- (void)updateProjectStatus;
- (void)save;

- (void)reloadAll;
- (void)refreshListOfFiles;
- (void)refreshSelectedFile;
- (void)refreshStructure;

- (void)askUserToCheckProject;
- (void)checkProject;

- (void)fmEditorWillChange;
- (void)fmEditorDidChange;

- (void)documentWillSave;

- (void)connectInterface;
- (void)disconnectInterface;

- (void)deselectAll;

- (void)setExplorerPredicate:(NSPredicate *)predicate;
- (void)setPathPredicate:(NSPredicate *)predicate;

- (NSPredicate *)currentFilterPredicate;
- (NSArray *)filteredFileControllers;

- (ProjectMenuEdit *)projectMenuEdit;

- (ProjectFilesController *)projectFiles;
- (ProjectLabels *)projectLabels;
- (ProjectExplorerController *)projectExplorer;

- (void)selectLanguageAtIndex:(NSInteger)index;
- (void)selectNextString;

- (void)registerToPreferences;
- (void)unregisterFromPreferences;

#pragma mark -

- (NSPopUpButton *)languagesPopUp;

- (NSArrayController *)languagesController;
- (NSArrayController *)filesController;

- (ProjectDocument *)projectDocument;
- (ProjectPrefs *)projectPreferences;
- (ProjectController *)projectController;
- (ProjectDetailsController *)projectDetailsController;
- (EngineProvider *)engineProvider;
- (OperationDispatcher *)operationDispatcher;
- (OperationWC *)operation;
- (Explorer *)explorer;

- (LanguageController *)selectedLanguageController;
- (NSArray *)selectedFileControllers;
- (NSArray *)selectedStringControllers;
- (void)selectStringController:(StringController *)sc;

- (BOOL)isBaseLanguage;

- (HistoryManager *)historyManager;
- (FMEditor *)currentFileEditor;

- (void)tableViewModifierFlagsChanged:(NSEvent *)event;

@end
