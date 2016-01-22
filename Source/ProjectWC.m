//
//  ProjectWC.m
//  iLocalize3
//
//  Created by Jean on 29.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectWC.h"

#import "ProjectDocument.h"
#import "ProjectModel.h"
#import "ProjectPrefs.h"
#import "ProjectFileWarningWC.h"
#import "ProjectLabelsWC.h"
#import "ExportProjectOVC.h"

#import "ProjectFilesController.h"
#import "ProjectLabels.h"

#import "ProjectExplorerController.h"
#import "ProjectDetailsController.h"
#import "ProjectViewSearchController.h"
#import "ProjectStructureViewController.h"
#import "ProjectStatusBarController.h"

#import "ProjectMenuFile.h"
#import "ProjectMenuEdit.h"
#import "ProjectMenuView.h"
#import "ProjectMenuProject.h"
#import "ProjectMenuTranslate.h"
#import "ProjectMenuGlossary.h"
#import "ProjectMenuToolbar.h"
#import "ProjectMenuDebug.h"

#import "ProjectWindow.h"

#import "PreferencesWC.h"
#import "PreferencesGeneral.h"

#import "Explorer.h"

#import "FileTool.h"
#import "StringEncodingTool.h"
#import "StringEncoding.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"

#import "OperationWC.h"

#import "DragAndDropOperation.h"
#import "CheckProjectOperation.h"

#import "PasteboardProvider.h"

#import "TableViewCustom.h"
#import "CustomFieldEditor.h"
#import "EngineProvider.h"
#import "FindEngine.h"

#import "GlossaryNewWC.h"
#import "SearchContext.h"

#import "IGroupViewAll.h"

#import "AZSplitView.h"
#import "AZSplitViewThumbView.h"

#import "FMEditorStrings.h"
#import "FMEngine.h"

#import "HistoryManager.h"
#import "RecentDocuments.h"

#import "Constants.h"

@interface ProjectWC (PrivateMethods)
- (BOOL)frameIsVisibleOnScreens:(NSRect)frame;
- (void)selectSavedLanguage;
- (void)setNeedsDisplayToAllTableViews;
- (void)removeFromOpenPreviousVersionMenu;
- (void)updateLanguageMenuKeyEquivalents;
- (void)updateLocalFilesVisibility;
@end

@implementation ProjectWC

@synthesize reconnectFile;
@synthesize reconnectLanguage;

- (id)init
{
	if((self = [super initWithWindowNibName:@"ProjectWindow"])) {
		mProjectMenuFile = [ProjectMenuFile newInstance:self];
		mProjectMenuEdit = [ProjectMenuEdit newInstance:self];
		mProjectMenuView = [ProjectMenuView newInstance:self];
		mProjectMenuProject = [ProjectMenuProject newInstance:self];
		mProjectMenuTranslate = [ProjectMenuTranslate newInstance:self];
		mProjectMenuGlossary = [ProjectMenuGlossary newInstance:self];
		mProjectMenuToolbar = [ProjectMenuToolbar newInstance:self];
		mProjectMenuDebug = [ProjectMenuDebug newInstance:self];
		mProjectViewSearchController = [ProjectViewSearchController newInstance:self];
		mProjectStructureController = [ProjectStructureViewController newInstance:self];
		mProjectStatusBarController = [ProjectStatusBarController newInstance:self];

		mDragAndDropOperation = NULL;
				        		
		mCurrentFMEditor = NULL;	
        mCustomFieldEditor = [[CustomFieldEditor alloc] init];
		mExplorerPredicate = nil;
		mPathPredicate = nil;
		
		mElapsedDate = [[NSDate alloc] init];
		mElapsedTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(fireElapsedTime:) userInfo:nil repeats:YES];
		
        mHistoryManager = [[HistoryManager alloc] init];
        				
		mProjectExplorerController = [ProjectExplorerController newInstance:self]; 
		mProjectDetailsController = [ProjectDetailsController newInstance:self];
		mProjectFilesController = [ProjectFilesController newInstance:self];

		mSearchViewVisible = NO;
		
        keyViewsLoop = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(languageStatsDidChange:)
                                                     name:ILNotificationLanguageStatsDidChange
                                                   object:nil];	
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(displayedStringsDidChange:)
													 name:ILDisplayedStringsDidChange
												   object:nil];	      		
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[PasteboardProvider shared] removeOwner:self];
	
	[mProjectMenuFile destroy];
	[mProjectMenuEdit destroy];
	[mProjectMenuView destroy];
	[mProjectMenuProject destroy];
	[mProjectMenuTranslate destroy];
	[mProjectMenuGlossary destroy];
	[mProjectMenuToolbar destroy];
	[mProjectMenuDebug destroy];
}

#pragma mark Key View Loop Management

- (void)insertKeyView:(NSView*)view atIndex:(NSUInteger)index
{
    NSView *previousView = nil;
    if(index < keyViewsLoop.count) {
        previousView = keyViewsLoop[index];        
    }
    [previousView setNextKeyView:view];
    
    NSView *nextView;
    if(index+1 < keyViewsLoop.count) {
        nextView = keyViewsLoop[index+1];
    } else {
        nextView = [keyViewsLoop firstObject];
    }
    [view setNextKeyView:nextView];
    
    if(index < keyViewsLoop.count) {
        [keyViewsLoop insertObject:view atIndex:index+1];    
    } else {
        [keyViewsLoop addObject:view];
    }
}

- (void)insertKeyViews:(NSArray*)views after:(NSView*)afterView
{
    if(views.count == 0) return;
    
    NSUInteger index = keyViewsLoop.count == 0 ? 0 : keyViewsLoop.count-1;    
    for(int i=0; i<keyViewsLoop.count; i++) {
        if(keyViewsLoop[i] == afterView) {            
            index = i;
            break;
        }
    }        

    for(NSView *v in views) {
        [self insertKeyView:v atIndex:index++];
    }
}

- (void)addKeyView:(NSView*)view
{
    [self insertKeyViews:@[view] after:nil];
}

- (void)printKeyViewsLoop
{
        NSLog(@"> %@", keyViewsLoop);
        for(NSView *v in keyViewsLoop) {
            NSLog(@"%@ <- %@ -> %@", [v previousValidKeyView], v, [v nextValidKeyView]);
        }
        
        NSLog(@"----------- Forward");
        NSView *o = (NSView*)[[self window] initialFirstResponder];
        NSView *v = o;
        do {
            NSLog(@"%@", v);
            v = [v nextValidKeyView];
        } while(o != v);
        
        {
            NSLog(@"----------- Backward");
            NSView *o = (NSView*)[[self window] initialFirstResponder];
            NSView *v = o;
            do {
                NSLog(@"%@", v);
                v = [v previousValidKeyView];
            } while(o != v);
        }
}

#pragma mark -

- (void)windowWillClose:(NSNotification *)notif
{
	if([notif object] == [self window]) {
        [mProjectController setContent:nil];
		[RecentDocuments documentClosed:[self document]];
		[self unregisterFromPreferences];
        [mProjectFilesController unbindFromLanguagesController];
		[mProjectFilesController removeFromOpenPreviousVersionMenu];
		[mHistoryManager saveData];
		[mDragAndDropOperation close];
		mDragAndDropOperation = nil;
		[mElapsedTimer invalidate];
		mElapsedTimer = nil;		
	}
}

- (void)awakeFromNib
{
	// Language controller setup
	[mLanguagesController addObserver:self forKeyPath:@"arrangedObjects.displayLanguage" options:NSKeyValueObservingOptionNew context:nil];

	[mProjectFilesController loadView];
	[mProjectExplorerController loadView];	

	/*	 
	 * Main window is composed of a vertical split view:
	 [      split view           ]
	 
	 * The vertical split view is composed of the following views (1 & 2):
	 (1) Left-side view:
	 ------------------------
	 [ custom view          ]	 
	 ------------------------
	 [ box                  ]
	 ------------------------
	 [customview][thumb view]
	 
	 (2) Right-side view:
	 [ custom view          ]	 

	 * Right-side custom view is then composed of:
	 [ (a) structure ] | [ (b) files ]
	 -------------------------
	 [      (c) file editor      ]
	 
	 */
	
	// Main split view
	NSRect windowFrame = [[[self window] contentView] frame];
	mMainSplitView = [[NSSplitView alloc] initWithFrame:windowFrame];
	[mMainSplitView accessibilitySetOverrideValue:@"Main Split View" forAttribute:NSAccessibilityValueDescriptionAttribute];
	[mMainSplitView accessibilitySetOverrideValue:@"Main Split View" forAttribute:NSAccessibilityValueAttribute];

	[mMainSplitView setDelegate:self];
	[mMainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
	[mMainSplitView setVertical:YES];
	[mMainSplitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin];
	[[[self window] contentView] addSubview:mMainSplitView];

	NSRect leftSideFrame = windowFrame;
	leftSideFrame.size.width = windowFrame.size.width / 4;
	
	NSRect rightSideFrame = windowFrame;
	rightSideFrame.origin.x += leftSideFrame.origin.x+leftSideFrame.size.width;
	rightSideFrame.size.width = windowFrame.size.width - rightSideFrame.origin.x;
	
	// =================== LEFT-SIDE ===========================	
	NSView *leftSideView = [[NSView alloc] initWithFrame:leftSideFrame];
	[mMainSplitView addSubview:leftSideView];
	
	NSRect bottomLeftRect = leftSideFrame; // the rect containing the details button and the thumb view
	bottomLeftRect.size.height = 25;
	
	NSRect upperLeftRect = leftSideFrame; // the rect containing the filters
	upperLeftRect.origin.y += leftSideFrame.size.height/3;
	upperLeftRect.size.height = leftSideFrame.size.height-upperLeftRect.origin.y;
	
	NSRect lowerLeftRect = leftSideFrame; // the rect containing the details view
	lowerLeftRect.origin.y += bottomLeftRect.size.height;
	lowerLeftRect.size.height = leftSideFrame.size.height - upperLeftRect.size.height - bottomLeftRect.size.height;
	
	NSRect leftSplitViewRect = leftSideFrame;
	leftSplitViewRect.origin.y += bottomLeftRect.size.height;
	leftSplitViewRect.size.height -= bottomLeftRect.size.height;
	
	mSidebarSplitView = [[AZSplitView alloc] initWithFrame:leftSplitViewRect];
	[mSidebarSplitView accessibilitySetOverrideValue:@"Side-bar Split View" forAttribute:NSAccessibilityValueDescriptionAttribute];
	[mSidebarSplitView accessibilitySetOverrideValue:@"Side-bar Split View" forAttribute:NSAccessibilityValueAttribute];

	[leftSideView addSubview:mSidebarSplitView];
	[mSidebarSplitView setVertical:NO];
	[mSidebarSplitView setDelegate:self];
	[mSidebarSplitView setDividerStyle:NSSplitViewDividerStyleThin];
	[mSidebarSplitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin];
	
	[[mProjectExplorerController view] setFrame:upperLeftRect];
	[mSidebarSplitView addSubview:[mProjectExplorerController view]];
	
	mSidebarDetailsView = [[NSView alloc] initWithFrame:lowerLeftRect];
	[mSidebarSplitView addSubview:mSidebarDetailsView];
	
	mProjectDetailsController.containerView = mSidebarDetailsView;
	mProjectDetailsController.splitView = mSidebarSplitView;	
	[mProjectDetailsController loadView];
	
	NSView *detailsButtonView = [mProjectDetailsController buttonView];
	[detailsButtonView setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
	NSRect detailsButtonRect = bottomLeftRect;
	detailsButtonRect.origin.x = -1;
	detailsButtonRect.size.width = detailsButtonView.frame.size.width;
	detailsButtonView.frame = detailsButtonRect;
	[leftSideView addSubview:detailsButtonView];
		
	NSRect thumbViewRect = bottomLeftRect;
	thumbViewRect.origin.x += detailsButtonRect.origin.x + detailsButtonRect.size.width;
	thumbViewRect.size.width = bottomLeftRect.size.width-thumbViewRect.origin.x;
	mMainSplitViewThumbView = [[AZSplitViewThumbView alloc] initWithFrame:thumbViewRect];
	[mMainSplitViewThumbView setAutoresizingMask:NSViewMaxYMargin|NSViewWidthSizable];
	[leftSideView addSubview:mMainSplitViewThumbView];
	
	// =================== RIGHT-SIDE ===========================
	mRightSideContainerView = [[NSView alloc] initWithFrame:rightSideFrame];
	[mRightSideContainerView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];

	[mMainSplitView addSubview:mRightSideContainerView];

	NSRect rightSideSplitViewRect = rightSideFrame;
	rightSideSplitViewRect.origin.x = 0;
	
	mRightSideContainerSplitView = [[NSSplitView alloc] initWithFrame:rightSideSplitViewRect];
	[mRightSideContainerSplitView accessibilitySetOverrideValue:@"Ride-side Split View" forAttribute:NSAccessibilityValueDescriptionAttribute];
	[mRightSideContainerSplitView accessibilitySetOverrideValue:@"Ride-side Split View" forAttribute:NSAccessibilityValueAttribute];
	[mRightSideContainerSplitView setVertical:NO];
	[mRightSideContainerSplitView setDelegate:self];
	[mRightSideContainerSplitView setDividerStyle:NSSplitViewDividerStyleThin];
	[mRightSideContainerSplitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	[mRightSideContainerView addSubview:mRightSideContainerSplitView];
	
	// Create the structure/files split view
	mStructureFilesSplitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(0, 0, rightSideFrame.size.width, rightSideFrame.size.height/5)];
	[mStructureFilesSplitView accessibilitySetOverrideValue:@"Structure & Files Split View" forAttribute:NSAccessibilityValueDescriptionAttribute];
	[mStructureFilesSplitView accessibilitySetOverrideValue:@"Structure & Files Split View" forAttribute:NSAccessibilityValueAttribute];

	[mStructureFilesSplitView setDelegate:self];
	[mStructureFilesSplitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
	[mStructureFilesSplitView setVertical:YES];
	[mStructureFilesSplitView setDividerStyle:NSSplitViewDividerStyleThin];

	// Add the structure (a)
	[mProjectStructureController.view setFrame:NSMakeRect(0, 0, rightSideFrame.size.width/4, rightSideFrame.size.height/5)];
	[mStructureFilesSplitView addSubview:[mProjectStructureController view]];	
	[mProjectStructureController update];

	// Add the files (b)
	[mProjectFilesController bindToLanguagesController:mLanguagesController];
	[mStructureFilesSplitView addSubview:mProjectFilesController.view];
	
	[mRightSideContainerSplitView addSubview:mStructureFilesSplitView];
	
	// Add the file editor (c)
	mFileEditorContainerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, rightSideFrame.size.width, rightSideFrame.size.height/2)];
	[mRightSideContainerSplitView addSubview:mFileEditorContainerView];
			
	// =================== SEARCH FIELD MENU SETUP ===============
	
	NSMenu *cellMenu = [[NSMenu alloc] initWithTitle:@"Search Menu"];
	[cellMenu setDelegate:self];
	
    NSMenuItem *item;
	
	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Search", @"Search Contextual Menu")
									   action:NULL
								keyEquivalent:@""];
	[item setTarget:self];
	[cellMenu addItem:item];
	
	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"contains", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_CONTAINS];
	[item setTarget:self];
	[cellMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"begins with", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_BEGINSWITH];
	[item setTarget:self];
	[cellMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ends with", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_ENDSWITH];
	[item setTarget:self];
	[cellMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"is", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_IS];
	[item setTarget:self];
	[cellMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"is not", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_IS_NOT];
	[item setTarget:self];
	[cellMenu addItem:item];
	
	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"matches", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_MATCHES];
	[item setTarget:self];
	[cellMenu addItem:item];

	item = [NSMenuItem separatorItem];
	[cellMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Ignore Case", @"Search Contextual Menu")
									   action:@selector(searchMenuScopeChanged:)
								keyEquivalent:@""];
	[item setTag:SEARCH_IGNORE_CASE];
	[item setTarget:self];
	[cellMenu addItem:item];
	
    item = [NSMenuItem separatorItem];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
	[cellMenu addItem:item];
	
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Recent Searches", @"Search Contextual Menu")
									   action:NULL
                                keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
	[cellMenu addItem:item];
	
    item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Recents", @"Search Contextual Menu")
									   action:NULL
                                keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsMenuItemTag];
	[cellMenu addItem:item];
	
    id searchCell = [mSearchField cell];
    [searchCell setSearchMenuTemplate:cellMenu];		
}

- (void)windowDidLoad
{	
	// This method is called when the document is closed after the project creation process
	// is canceled. We should return without doing anything - otherwise exceptions are raised.
	if([[self operation] shouldCancel]) {
		return;				
	}
	
    mProjectLabels.projectWC = self;
     
	// Mouse moved events are used to display tool tips in the table view
	[[self window] setAcceptsMouseMovedEvents:YES];
	
	// Set the window for the operations
	[[self operation] setParentWindow:[self window]];
	
	// Set the provider for the default text editor
    [mCustomFieldEditor setProvider:[self projectDocument]];
	
	// Setup drag and drop operation
	mDragAndDropOperation = [DragAndDropOperation operationWithProjectProvider:[self projectDocument]];
    
	// Setup history manager
    [mHistoryManager setProjectController:[self projectController]];
    
	// Setup project controller
	[mProjectController setContent:[self projectController]];

	// Set the frame of the window (make sure it is visible on the screen)
    NSRect frame = [[self projectPreferences] windowPosition];
    if(!NSEqualRects(frame, NSZeroRect) && [self frameIsVisibleOnScreens:frame]) {
        [[self window] setFrame:frame display:NO];		
	} else {
		// A window without position should be positioned automatically to have a nice size ;-)
		NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
		float height = screenFrame.size.height * 0.8;
		frame = NSMakeRect(screenFrame.origin.x+10, screenFrame.origin.y+(screenFrame.size.height-height)-10, screenFrame.size.width * 0.8, height);
		[[self window] setFrame:frame display:NO];		
	}
	
	NSDictionary *uiPrefs = [[self projectPreferences] interfacePrefs];
	if(uiPrefs) {
		[mMainSplitView restorePositions:uiPrefs[@"mainSplitView"]];
		[mRightSideContainerSplitView restorePositions:uiPrefs[@"rightSideSplitView"]];
		[mStructureFilesSplitView restorePositions:uiPrefs[@"structureFilesSplitView"]];
	}
	
	[self registerToPreferences];

    // ================ Setup the key view loop manually ====================
    
    [[self window] setAutorecalculatesKeyViewLoop:NO];
    [[self window] setInitialFirstResponder:mProjectExplorerController->mSideBarOutlineView];
    [self addKeyView:mProjectExplorerController->mSideBarOutlineView];
    [self addKeyView:mProjectStructureController->outlineView];
    [self addKeyView:mProjectFilesController->mFilesTableView];
    [self insertKeyViews:[mProjectDetailsController keyViews] after:mProjectFilesController->mFilesTableView];    

    // ==============
    
	[self reloadAll];	
	[self fmEditorDidChange];	
	[self selectSavedLanguage];
	[self updateLocalFilesVisibility];
	
	if(![self isStructureViewVisible]) {
		[self ensureStructureView];		
	}
	
	if([self isStatusBarVisible]) {
		[self ensureStatusBar];		
	}
	
	[mProjectFilesController selectSavedFile];
	
	[self updateProjectStatus];	
	[self updateProjectToolbar];

    [[self document] updateDirty];
	[RecentDocuments documentOpened:[self document]];    
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
    if ([anObject isKindOfClass:[TableViewCustom class]])
    {	
        // make sure it will behave like a text field editor (Enter will end editing)
        [mCustomFieldEditor setFieldEditor:YES];
		[mCustomFieldEditor setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
		[mCustomFieldEditor setShowInvisibleCharacters:[self projectPreferences].showInvisibleCharacters];		
        return mCustomFieldEditor;
    }
    return nil;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	NSString *appVersion = [[self projectDocument] projectAppVersionString];
	if([appVersion length] > 0) {
		return [displayName stringByAppendingString:[NSString stringWithFormat:@" - %@ (%@)", [[self projectDocument] applicationExecutableName], appVersion]];		
	} else {
		return [displayName stringByAppendingString:[NSString stringWithFormat:@" - %@", [[self projectDocument] applicationExecutableName]]];			
	}
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{	
	[self setNeedsDisplayToAllTableViews];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
	[self updateLanguageMenuKeyEquivalents];
	[self setNeedsDisplayToAllTableViews];
}

- (BOOL)frameIsVisibleOnScreens:(NSRect)frame
{
    for(NSScreen *s in [NSScreen screens]) {
        if(NSIntersectsRect([s frame], frame))
            return YES;        
    }
    return NO;
}

- (BOOL)shouldCascadeWindows
{
    NSRect frame = [[self projectPreferences] windowPosition];
    if(NSEqualRects(frame, NSZeroRect))
        return YES;
    
    return ![self frameIsVisibleOnScreens:frame];
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
	if(splitView == mMainSplitView) {
		NSRect r = [mMainSplitViewThumbView bounds];
		r.origin.x = r.origin.x+r.size.width-15;
		r.size.width = 15;
		return [mMainSplitViewThumbView convertRect:r toView:splitView]; 		
	} else {
		return NSZeroRect;		
	}
}

- (BOOL)splitView:(NSSplitView*)splitView shouldHideDividerAtIndex:(NSInteger)index
{
	if(splitView == mSidebarSplitView) {
		return YES;
	}
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return NO;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	if(splitView == mMainSplitView) {
		return MAX(proposedMin, 180);
	}
	if(splitView == mStructureFilesSplitView) {
		return MAX(proposedMin, 180);
	}
	if(splitView == mRightSideContainerSplitView) {
		return MAX(proposedMin, 100);
	}
	return proposedMin;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
{
	if(splitView == mMainSplitView) {
		return proposedMax-300;
	}
	if(splitView == mStructureFilesSplitView) {
		return proposedMax-300;
	}
	if(splitView == mRightSideContainerSplitView) {
		return proposedMax-100;
	}	
	return proposedMax;	
}

- (void)addToAsNextResponder:(NSResponder*)responder
{
	NSResponder *ownNextResponder = [self nextResponder];
	[super setNextResponder:responder];
	[responder setNextResponder:ownNextResponder];	
}

#pragma mark -
#pragma mark Structure View

- (void)toggleStructureView
{
	BOOL visible = ![self isStructureViewVisible];
	[[self projectPreferences] setShowStructureView:visible];
	[self ensureStructureView];	
}

- (void)ensureStructureView
{
	if([self isStructureViewVisible]) {
		[mProjectFilesController.view removeFromSuperview];
		[mStructureFilesSplitView addSubview:[mProjectStructureController view]];
		[mStructureFilesSplitView addSubview:mProjectFilesController.view];
	} else {
		[[mProjectStructureController view] removeFromSuperview];
	}
}

- (BOOL)isStructureViewVisible
{
	return [[self projectPreferences] showStructureView];
}

#pragma mark -
#pragma mark Status bar

- (void)toggleStatusBar
{
	BOOL visible = ![self isStatusBarVisible];
	[[self projectPreferences] setShowStatusBar:visible];
	[self ensureStatusBar];
}

- (void)ensureStatusBar
{
	NSView *v = [mProjectStatusBarController view];
	NSSize size = v.frame.size;
	if([self isStatusBarVisible]) {
		// Move the right-side split view up and shrink its height
		NSRect rightSideFrame = mRightSideContainerSplitView.frame;
		rightSideFrame.origin.y += size.height;
		rightSideFrame.size.height -= size.height;
		mRightSideContainerSplitView.frame = rightSideFrame;
		
		// Make sure the status bar is wide enough
		int xOffset = 1; // offset to avoid left-side gray bar of 1 pixel
		size.width = mRightSideContainerSplitView.frame.size.width+2*xOffset;
		[v setFrameOrigin:NSMakePoint(-xOffset, 0)];
		[v setFrameSize:size];
		
		// Add the view
		[mRightSideContainerView addSubview:v];		
	} else {
		[v removeFromSuperview];
		
		// Restore the right-side view
		NSRect rightSideFrame = mRightSideContainerSplitView.frame;
		rightSideFrame.origin.y -= size.height;
		rightSideFrame.size.height += size.height;
		mRightSideContainerSplitView.frame = rightSideFrame;		
	}	
}

- (BOOL)isStatusBarVisible
{
	return [[self projectPreferences] showStatusBar];
}

#pragma mark -
#pragma mark Search View

- (void)showSearchView
{
	NSView *view = [mProjectViewSearchController view];
	CGFloat viewHeight = [mProjectViewSearchController viewHeight];
	if(!mSearchViewVisible) {
		mSearchViewVisible = YES;
				
		// reduce the height of the split view
		NSRect r = mRightSideContainerSplitView.frame;
		r.size.height -= viewHeight;
		mRightSideContainerSplitView.frame = r;
		
		// set the frame of the search view
		r = mRightSideContainerView.bounds;
		r.origin.y = r.size.height - viewHeight;
		r.size.height = viewHeight;
		view.frame = r;
		
		// insert the search view
		[mRightSideContainerView addSubview:view];
	}
}

- (void)showSearchView:(ExplorerFilter*)filter
{
	[mSearchField setStringValue:filter.name];
	[mProjectViewSearchController setContext:filter.stringContentMatchingContext];
	[mProjectViewSearchController updateInterface];
	[self showSearchView];
}

- (void)hideSearchView
{
	NSView *view = [mProjectViewSearchController view];
	if(mSearchViewVisible) {
		mSearchViewVisible = NO;
		CGFloat searchViewHeight = [view frame].size.height;
		
		// increase the height of the split view
		NSRect r = mRightSideContainerSplitView.frame;
		r.size.height += searchViewHeight;
		mRightSideContainerSplitView.frame = r;
				
		// remove the search view
		[view removeFromSuperview];
	}
}

- (SearchContext*)searchContext
{
	return [mProjectViewSearchController context];
}

- (NSString*)searchString
{
	return [mSearchField stringValue];
}

- (NSString*)replaceString
{
	return [mProjectViewSearchController replaceString];
}

- (void)selectSearchField
{
    if(![[mToolbar visibleItems] containsObject:mSearchToolbarItem]) {
        [mToolbar insertItemWithItemIdentifier:[mSearchToolbarItem itemIdentifier] atIndex:[[mToolbar visibleItems] count]];
    }
	[[self window] makeFirstResponder:mSearchField];
}

/**
 Invoked when the user presses enter in the search field or
 changes the search context in the search view controller.
 */
- (void)doSearch
{
	NSString *searchString = [self searchString];
	if([searchString length] > 0) {
		ExplorerFilter *filter = [ExplorerFilter filterWithContext:[self searchContext] string:searchString];		
		[[[self engineProvider] findEngine] findString:searchString context:[self searchContext]];
						
		[[self explorer] createSmartFilter:filter];
		[[self projectExplorer] selectExplorerFilter:filter];
	} else {
		[[self projectExplorer] selectExplorerFilter:nil];
        [[[self engineProvider] findEngine] resetContentMatching];
	}	
	[self updateProjectToolbar];
}

/**
 Invoked by the user when he clicks on the Save button of the search view.
 */
- (void)doSaveSearch
{
	[[self projectExplorer] createNewFilterBasedOnFilter:[[[self projectExplorer] selectedFilters] firstObject]];	
}

/**
 Invoked by the user when he clicks on the Replace button of the search view.
 */
- (void)doReplace
{
	[[[self engineProvider] findEngine] replaceWithString:[self replaceString]
												  context:[self searchContext]];
}

/**
 Invoked by the user when he clicks on the Replace All button of the search view.
 */
- (void)doReplaceAll
{
	[[[self engineProvider] findEngine] replaceAllStrings:[self searchString]
											   withString:[self replaceString]
												  context:[self searchContext]];	
}

- (void)searchMenuScopeChanged:(id)sender
{
	SearchContext *c = [self searchContext];
	if([sender tag] == SEARCH_IGNORE_CASE) {
		c.ignoreCase = !c.ignoreCase;
	} else {
		c.options = [sender tag];		
	}
	[self doSearch];
}

#pragma mark -

- (int)elapsedMinutesSinceProjectWasOpened
{
	return (int)([[NSDate date] timeIntervalSinceDate:mElapsedDate]/60.0);
}

- (void)updateProjectDetails
{    
	[mProjectStatusBarController update];
	[mProjectDetailsController update];
}

- (void)updateProjectStatus
{
	[self synchronizeWindowTitleWithDocumentName];
	[self updateProjectDetails];
}

- (void)updateProjectToolbar
{
	LanguageController *lc = [self selectedLanguageController];
	NSString *text;
	if([lc percentCompleted] == 100) {
		text = NSLocalizedString(@"Done", @"Language Progress Done");
	} else {		
		int count = [lc totalNumberOfNonTranslatedStrings];
		if(count == 1) {
			text = NSLocalizedString(@"One string to translate", @"Language Progress");			
		} else {
			text = [NSString stringWithFormat:NSLocalizedString(@"%d strings to translate", @"Language Progress"), count];		
		}
	}
	[mLanguageToolbarItem setLabel:text];
	
	int totalFiles = [[lc fileControllers] count];
	int filteredFiles = [[self filteredFileControllers] count];
	// Total Files	Filtered		Text
	// 0			0				No file
	// 1			1				1 out of 1 file
	// 2			1				1 out of 2 files
	// 2			2				2 out of 2 files
	// 1			0				0 out of 1 file
	// 2			0				0 out of 2 files
	text = NSLocalizedString(@"No file", @"Visible Files Info");
	if(totalFiles > 0) {
		if(totalFiles == filteredFiles) {
			NSString *localizedString;
			if(totalFiles > 1) {
				localizedString = NSLocalizedString(@"%d files", @"Visible Files Info");
			} else {
				localizedString = NSLocalizedString(@"%d file", @"Visible Files Info");			
			}
			text = [NSString stringWithFormat:localizedString, totalFiles];					
		} else {
			NSString *localizedString;
			if(totalFiles > 1) {
				localizedString = NSLocalizedString(@"%d out of %d files", @"Visible Files Info");
			} else {
				localizedString = NSLocalizedString(@"%d out of %d file", @"Visible Files Info");			
			}
			text = [NSString stringWithFormat:localizedString, filteredFiles, totalFiles];					
		}
	}
	[mSearchToolbarItem setLabel:text];
}

- (void)fireElapsedTime:(NSTimer*)timer
{
	if([[PreferencesGeneral shared] automaticallySaveProject] && ([self elapsedMinutesSinceProjectWasOpened] % [[PreferencesGeneral shared] automaticallySaveProjectDelay]) == 0) {
		[self save];
	}
	
	[self updateProjectDetails];
}

- (void)selectSavedLanguage
{
	NSString *name = [[self projectPreferences] selectedLanguage];
	unsigned index = 0;
	for(LanguageController *lc in [mLanguagesController content]) {
		if([[lc language] isEqualCaseInsensitiveToString:name]) {
			index = [[mLanguagesController content] indexOfObject:lc];
			break;
		}        
    }
	[mLanguagesController setSelectionIndex:index];
	[[self projectController] setCurrentLanguageIndex:index];
}

- (void)documentWillSave
{
    [mHistoryManager saveData];
	
	[mProjectFilesController save];
	
	[[self projectPreferences] setSelectedLanguage:[[self selectedLanguageController] language]];
	
	NSMutableDictionary *uiPrefs = [NSMutableDictionary dictionary];
	uiPrefs[@"mainSplitView"] = [mMainSplitView storePositions];
	uiPrefs[@"rightSideSplitView"] = [mRightSideContainerSplitView storePositions];
	uiPrefs[@"structureFilesSplitView"] = [mStructureFilesSplitView storePositions];

	[[self projectPreferences] setInterfacePrefs:uiPrefs];
	[[self projectPreferences] setWindowPosition:[[self window] frame]];
}

- (void)save
{
	if([[self document] isDocumentEdited]) {
		[[self document] saveDocument:self];			
	}
}

- (void)reloadAll
{
	[mProjectExplorerController rearrange];
	[self updateLanguageMenuKeyEquivalents];
}

- (void)refreshListOfFiles
{
	[[self selectedLanguageController] filteredFileControllersDidChange];	
}

- (void)setNeedsDisplayToAllTableViews
{
	[mProjectFilesController setNeedsDisplayToAllTableViews];
}

- (void)refreshSelectedFile
{
	[self fmEditorWillChange];
	[self setNeedsDisplayToAllTableViews];
	[[self document] setDirty];
	[self fmEditorDidChange];		
}

- (void)refreshStructure
{
	[mProjectStructureController update];
	[self refreshListOfFiles];
}

- (void)updateLocalFilesVisibility
{
	// update the language controller filtering
	for(LanguageController *lc in [[self projectController] languageControllers]) {
		[lc setFilterShowLocalFiles:[[self projectPreferences] showLocalFiles]];
	}	
}

#pragma mark -
#pragma mark Filters

- (void)applyFilterPredicate
{
	NSPredicate *p = nil;
	if(mExplorerPredicate && mPathPredicate) {
        p = [NSCompoundPredicate andPredicateWithSubpredicates:@[mExplorerPredicate, mPathPredicate]];
	} else if(mExplorerPredicate) {
		p = mExplorerPredicate;
	} else if(mPathPredicate) {
		p = mPathPredicate;
	}
	
	NSArrayController *c = [self filesController];
    NSIndexSet *emptySelection = [NSIndexSet indexSet];
	[c setSelectionIndexes:emptySelection]; // make sure to trigger the selection...
	[c setFilterPredicate:p];
	if([[c content] count] > 0) {
		[c setSelectionIndex:0]; // ... when we select the first object
	}	
	[self updateProjectToolbar];
}

- (void)setExplorerPredicate:(NSPredicate*)predicate
{
	mExplorerPredicate = predicate;

	[self applyFilterPredicate];
}

- (void)setPathPredicate:(NSPredicate*)predicate
{
	mPathPredicate = predicate;	
	
	[self applyFilterPredicate];
}

- (NSPredicate*)currentFilterPredicate
{
	return [[self filesController] filterPredicate];
}

- (NSArray*)filteredFileControllers
{
	return [[self filesController] arrangedObjects];
}

#pragma mark -

- (void)selectLanguageAtIndex:(int)index
{
	[mProjectFilesController rememberSelectedFiles];
	[mCurrentFMEditor pushState];
	
	// Note: the language pop-up selection is bound to the ProjectController rather to mLanguagesController because
	// otherwise, the language index changes will occurs before entering this method - and we will be unable
	// to save the selected files/strings in order to reapply them after the language change.
	
	[[self projectController] setCurrentLanguageIndex:index];
	[mLanguagesController setSelectionIndex:index];
	
	[mProjectFilesController selectRememberedFiles];
	[mCurrentFMEditor popState];
	
	[self fmEditorDidChange];
	
	[self updateProjectStatus];
	[self updateProjectToolbar];
	
	[self updateLanguageMenuKeyEquivalents];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ILLanguageSelectionDidChange
														object:[mLanguagesController selectedObjects]];		
}

- (void)selectNextString
{
	[mCurrentFMEditor selectNextItem];
}

- (void)updateLanguageMenuKeyEquivalents
{
//	unsigned count = 0;
//	for(NSMenuItem *item in [mLanguagePopUp itemArray]) {
//		[item setKeyEquivalent:[NSString stringWithFormat:@"%d", ++count]];		
//	}	
}

#pragma mark -

- (void)askUserToCheckProject
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"It is recommended to check the project against inconsistencies", nil) 
									 defaultButton:NSLocalizedString(@"Check", nil)
								   alternateButton:NSLocalizedString(@"Don't check", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"Do you want to check the project? The project can be checked at any time by using the command under the menu Project.", nil)];
	[alert beginSheetModalForWindow:[self window] 
                      modalDelegate:self
                     didEndSelector:@selector(askUserCheckProjectAlertDidEnd:returnCode:contextInfo:) 
                        contextInfo:nil];
}

- (void)askUserCheckProjectAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSAlertDefaultReturn) {
		[[CheckProjectOperation operationWithProjectProvider:[self projectDocument]] performSelector:@selector(checkAllProject) withObject:nil afterDelay:0];
	}		
}

- (void)checkProject
{
	[[CheckProjectOperation operationWithProjectProvider:[self projectDocument]] performSelector:@selector(checkAllProject) withObject:nil afterDelay:0];
}

#pragma mark -

- (void)fmEditorWillChange
{
	[mCurrentFMEditor makeInvisible];
}

- (void)fmEditorDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ILFileSelectionDidChange
														object:[mProjectFilesController selectedFileControllers]];		

	int count = [[mProjectFilesController selectedFileControllers] count];
	if(count == 0) {
		[mCurrentFMEditor makeInvisible];
		mCurrentFMEditor = NULL;
		[mFileEditorContainerView setContentView:mFileEditorNoView];	
		return;
	}

	BOOL notEditable = NO;
	BOOL notApplicable = NO;
	BOOL ignore = NO;
	
	// Check to see if all editor are the same
	
	FMEditor *editor = nil;	// editor
	FMEngine *engine = nil; // the associated engine
	
	for(FileController *fc in [mProjectFilesController selectedFileControllers]) {
		// Local files are currently not editable
		if([fc isLocal]) {
			notEditable = YES;
		}
		
		FMEditor *e = [[self projectDocument] fileModuleEditorForFile:[fc filename]];
		if(e == nil) {
			notApplicable = YES;
			break;
		}
		
		if(editor == nil) {
			ignore = [fc ignore];	
		} else {
			if(![fc ignore] && ignore) {
                ignore = NO;
				break;
			}
		}
		
		if(editor == nil)
			editor = e;
		
		if(editor != e) {
			notApplicable = YES;
			break;
		}
		
		engine = [[self projectDocument] fileModuleEngineForFile:[fc filename]];		
	}
		
	if(!notApplicable && notEditable) {
		[mCurrentFMEditor makeInvisible];
		mCurrentFMEditor = NULL;
		[mFileEditorContainerView setContentView:count==1?mFileEditorNotEditableView:mFileEditorNotApplicableView];		
	} else if(notApplicable || editor == NULL) {
		[mCurrentFMEditor makeInvisible];
		mCurrentFMEditor = NULL;
		[mFileEditorContainerView setContentView:mFileEditorNotApplicableView];
	} else if(ignore) {
		[mCurrentFMEditor makeInvisible];
		mCurrentFMEditor = NULL;
		[mFileEditorContainerView setContentView:mFileEditorIgnoreView];		
	} else {
		BOOL willShow = (count>1 && [editor allowsMultipleSelection]) || (count == 1);
		
		if(willShow) {
			mCurrentFMEditor = editor;
					
			[editor setEngine:engine];
			[editor setLanguageController:[self selectedLanguageController]];
			[editor setFileControllers:[mProjectFilesController selectedFileControllers]];

			[editor makeVisibleInBox:mFileEditorContainerView];
		} else {
			[mCurrentFMEditor makeInvisible];
			mCurrentFMEditor = NULL;

			[mFileEditorContainerView setContentView:mFileEditorNotApplicableView];		
		}
	}

//	[self insertKeyViews:[mCurrentFMEditor keyViews] after:mProjectFilesController->mFilesTableView];
//    [self printKeyViewsLoop];
    
	[self updateProjectDetails];
}

- (void)languageStatsDidChange:(NSNotification*)notif
{
	[self updateLanguageMenuKeyEquivalents];
	[self updateProjectDetails];
	[self updateProjectToolbar];
}

- (void)displayedStringsDidChange:(NSNotification*)notif
{
	if([notif object] == nil || mCurrentFMEditor == [notif object]) {
		[mProjectFilesController setNeedsDisplayToAllTableViews];
	}
}

- (void)connectInterface
{
	[mProjectController setContent:[self projectController]];
	[self reloadAll];

	int languageIndex = 0;
	LanguageController *lc = nil;
	if(self.reconnectLanguage) {
		int index = 0;
		for(lc in [[self projectController] languageControllers]) {
			if([[lc language] isEqualToString:self.reconnectLanguage]) {
				languageIndex = index;
				break;
			}
			index++;
		}
	}
	[self selectLanguageAtIndex:languageIndex];
	
	if(lc == nil) {
		lc = [[self projectController] baseLanguageController];
	}
	
	FileController *selectFc = nil;
	if(self.reconnectFile) {
		for(FileController *fc in [lc fileControllers]) {
			if([[fc relativeFilePath] isEqualToString:self.reconnectFile]) {
				selectFc = fc;
				break;
			}
		}
	}
	if(selectFc) {
		// Select a bit later otherwise it doesn't select
		[mProjectFilesController performSelector:@selector(selectFileController:) withObject:selectFc afterDelay:0];
	} else {
		[mProjectFilesController selectFirstFile];
	}	
}

- (void)disconnectInterface
{
	self.reconnectFile = [[[self selectedFileControllers] firstObject] relativeFilePath];
	self.reconnectLanguage = [[self selectedLanguageController] language];
	
	[mProjectController setContent:nil];
	[[self languagesPopUp] selectItem:nil];
}

- (void)deselectAll
{
	[mProjectFilesController deselectAll];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"showInvisibleCharacters"]) {
		[mCustomFieldEditor setShowInvisibleCharacters:[self projectPreferences].showInvisibleCharacters];
		[mProjectFilesController setNeedsDisplayToAllTableViews];
		[[[self currentFileEditor] view] setNeedsDisplay:YES];
	} else if([keyPath isEqualToString:@"arrangedObjects.displayLanguage"]) {
		// update the key equivalents each time the display language changes
		[self updateLanguageMenuKeyEquivalents];
	} else if([keyPath isEqualToString:@"showLocalFiles"]) {
		[self updateLocalFilesVisibility];
	}
}

- (void)registerToPreferences
{
	[[self projectPreferences] addObserver:self forKeyPath:@"showInvisibleCharacters" options:0 context:nil];
	[[self projectPreferences] addObserver:self forKeyPath:@"showLocalFiles" options:0 context:nil];
}

- (void)unregisterFromPreferences
{
	[[self projectPreferences] removeObserver:self forKeyPath:@"showInvisibleCharacters"];
	[[self projectPreferences] removeObserver:self forKeyPath:@"showLocalFiles"];
}

#pragma mark -

- (NSString*)toolTipAtPosition:(NSPoint)pos
{
	NSString *tt = [mProjectFilesController handleToolTipRequestedAtPosition:pos];
	if(!tt) {
		tt = [mCurrentFMEditor windowToolTipRequestedAtPosition:pos];
	}
	return tt;
}

- (BOOL)isOwnerSelf:(NSPasteboard*)pboard
{
	NSNumber *ownerPointer = [pboard propertyListForType:PBOARD_OWNER_POINTER];
	return [ownerPointer longValue] == (long)self;
}

- (NSDragOperation)windowDragOperationEnteredForPasteboard:(NSPasteboard*)pboard
{
	if([self isOwnerSelf:pboard])
		return NSDragOperationNone;
	else
		return [mDragAndDropOperation dragOperationEnteredForPasteboard:pboard];
}

- (NSDragOperation)windowDragOperationUpdatedForPasteboard:(NSPasteboard*)pboard
{
	if([self isOwnerSelf:pboard])
		return NSDragOperationNone;
	else
		return [mDragAndDropOperation dragOperationUpdatedForPasteboard:pboard];
}

- (BOOL)windowDragOperationPerformWithPasteboard:(NSPasteboard*)pboard
{
	return [mDragAndDropOperation dragOperationPerformWithPasteboard:pboard];
}

- (void)windowTableViewDragOperationEnded
{
	[mDragAndDropOperation dragOperationEnded];
}

#pragma mark -
#pragma mark Attributes

- (ProjectMenuEdit*)projectMenuEdit
{
	return mProjectMenuEdit;
}

- (ProjectFilesController*)projectFiles
{
	return mProjectFilesController;
}

- (ProjectExplorerController*)projectExplorer
{
	return mProjectExplorerController;
}

- (ProjectDetailsController*)projectDetailsController
{
	return mProjectDetailsController;
}

- (ProjectLabels*)projectLabels
{
	return mProjectLabels;
}

- (NSPopUpButton*)languagesPopUp
{
	return mLanguagePopUp;
}

- (ProjectDocument*)projectDocument
{
	return [self document];
}

- (ProjectPrefs*)projectPreferences
{
	return [[self projectDocument] projectPrefs];
}

- (EngineProvider*)engineProvider
{
	return [[self projectDocument] engineProvider];
}

- (OperationDispatcher*)operationDispatcher
{
	return [[self projectDocument] operationDispatcher];
}

- (OperationWC*)operation
{
	return [[self projectDocument] operation];
}

- (Explorer*)explorer
{
	return [[self projectDocument] explorer];
}

- (HistoryManager*)historyManager
{
    return mHistoryManager;
}

- (FMEditor*)currentFileEditor
{
	return mCurrentFMEditor;
}

- (ProjectController*)projectController
{
	return [[self projectDocument] projectController];
}

- (NSArrayController*)languagesController
{
	return mLanguagesController;
}

- (NSArrayController*)filesController
{
	return [mProjectFilesController filesArrayController];
}

- (LanguageController*)selectedLanguageController
{
	return [[mLanguagesController selectedObjects] firstObject];
}

- (NSArray*)selectedFileControllers
{
	return [mProjectFilesController selectedFileControllers];
}

- (NSArray*)selectedStringControllers
{
	if([mCurrentFMEditor isKindOfClass:[FMEditorStrings class]])
		return [mCurrentFMEditor selectedContentItems];
	else
		return NULL;
}

- (void)selectStringController:(StringController*)sc
{
	[mCurrentFMEditor selectContentItem:sc];
}

- (BOOL)isBaseLanguage
{
	return [[self selectedLanguageController] isBaseLanguage];
}

#pragma mark -

// Offset for the language item to avoid a collision with the search item (see validateMenuItem method above)
#define LANGUAGE_ITEM_TAG_OFFSET 1000

- (void)tableViewModifierFlagsChanged:(NSEvent*)event
{
	[mDragAndDropOperation modifierFlagsChanged:event];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	if([anItem tag] < LANGUAGE_ITEM_TAG_OFFSET) {
		SearchContext *c = [self searchContext];
		if([anItem tag] == SEARCH_IGNORE_CASE) {
			[anItem setState:c.ignoreCase?NSOnState:NSOffState];
		} else if([anItem tag] == c.options) {
			[anItem setState:NSOnState];
		} else {
			[anItem setState:NSOffState];
		}		
	}
	return YES;
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	[mLabelsMenuItem setSubmenu:[mProjectLabels fileLabelsMenu]];	
}

// Invoked by Application
- (void)openPreviousVersionMenuNeedsUpdate:(NSMenu*)menu
{
	[mProjectFilesController openPreviousVersionMenuNeedsUpdate:menu];
}

// Invoked by Application
- (void)viewLanguageMenuNeedsUpdate:(NSMenu*)menu
{
	[menu removeAllItems];
	
	unsigned count = LANGUAGE_ITEM_TAG_OFFSET;
	for(LanguageController *lc in [[self languagesController] content]) {
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[lc displayLanguage] action:@selector(selectLanguage:) keyEquivalent:[NSString stringWithFormat:@"%d", count-(LANGUAGE_ITEM_TAG_OFFSET-1)]];
		[item setTag:count];
		if([self selectedLanguageController] == lc) {
			[item setState:NSOnState];
		}
		[menu addItem:item];						
		count++;
	}
}

- (void)selectLanguage:(id)sender
{
	[self selectLanguageAtIndex:[sender tag]-LANGUAGE_ITEM_TAG_OFFSET];
}

@end

