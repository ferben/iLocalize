//
//  FMEditorStrings.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditorStrings.h"
#import "FMStringsExtensions.h"

#import "FileController.h"
#import "StringController.h"
#import "StringModel.h"
#import "StringsContentModel.h"
#import "StringEncoding.h"
#import "DirtyContext.h"
#import "EngineProvider.h"
#import "StringsEngine.h"
#import "NibEngine.h"
#import "CheckEngine.h"

#import "StringStatusCustomCell.h"
#import "StringLabelCustomCell.h"

#import "TableViewCustom.h"
#import "TableViewCustomCell.h"

#import "TextViewCustom.h"

#import "ControlCharactersParser.h"
#import "PreferencesWC.h"
#import "PreferencesLocalization.h"
#import "PreferencesGeneral.h"
#import "PreferencesFilters.h"
#import "PreferencesLanguages.h"

#import "ProjectWC.h"
#import "ProjectLabelsWC.h"
#import "ProjectLabels.h"
#import "ProjectPrefs.h"

#import "FileTool.h"
#import "StringTool.h"

#import "Stack.h"

#import "PasteboardProvider.h"

#import "Constants.h"
#import "FindContentMatching.h"
#import "LanguageTool.h"
#import "ContextualMenuCornerView.h"
#import "AZClearView.h"
#import "Preferences.h"
#import "PropagationEngine.h"

#define COLUMN_KEY			@"Key"
#define COLUMN_BASE			@"Base"
#define COLUMN_STATUS		@"Status"
#define COLUMN_TRANSLATION	@"Translation"
#define COLUMN_LABEL		@"Labels"

@interface FMEditorStrings ()

@property (nonatomic, weak) StringController *originalStringController;

@end

@implementation FMEditorStrings

- (id)init
{
	if((self = [super init])) {
		mIgnoreCase = NO;
		
		mSelectedStringsRowIndexes = NULL;
				
        mQuoteSubstitution = NO;
        
        mOpenDoubleBaseLanguage = nil;
        mCloseDoubleBaseLanguage = nil;
        mOpenSingleBaseLanguage = nil;
        mCloseSingleBaseLanguage = nil;
        
        mOpenDoubleLocalizedLanguage = nil;
        mCloseDoubleLocalizedLanguage = nil;
        mOpenSingleLocalizedLanguage = nil;
        mCloseSingleLocalizedLanguage = nil;
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stringsFilterDidChange:)
													 name:ILStringsFilterDidChange
												   object:nil];		

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(quoteSubstitutionDidChange:)
													 name:ILQuoteSubstitutionDidChange
												   object:nil];		

        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(editorFontDidChange:)
													 name:ILEditorFontDidChange
												   object:nil];		

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tableContentSizeDidChange:)
													 name:ILTableContentSizeDidChange
												   object:nil];		
				
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(projectControllerDidBecomeDirty:)
													 name:ILNotificationProjectControllerDidBecomeDirty 
												   object:NULL];	
		
		[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"autoPropagateTranslationMode" options:0 context:nil];
		[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"baseLanguageReadOnly" options:0 context:nil];
	}
	return self;
}

- (void)dealloc
{	
    [self removeBindingTextView];
    
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"autoPropagateTranslationMode"];
	[[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"baseLanguageReadOnly"];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[PreferencesWC shared] removeObserver:self];
	
	[[PasteboardProvider shared] removeOwner:self];
}

- (NSString*)nibname
{
	return @"FMEditorStrings";
}

- (NSView*)view
{
	if([[mStringsController content] count] == 0)
		return mEmptyView;
	else
		return [super view];
}

- (NSArray*)keyViews
{
    return @[mBaseStringsTableView, mLocalizedStringsTableView];
}

- (BOOL)allowsMultipleSelection
{
	return YES;
}

- (BOOL)canExportToStrings
{
	return YES;
}

- (BOOL)canTranslateUsingStrings
{
	return YES;
}

- (void)projectControllerDidBecomeDirty:(NSNotification*)notif
{
	DirtyContext *context = [notif userInfo][@"context"];
	if(context.fc && [mFileControllers containsObject:context.fc]) {
		// Only refresh if the dirty concerns the current filter controller
		int index = -1;
		if(context.sc) {
			index = [[mStringsController arrangedObjects] indexOfObject:context.sc];
		}
		
		[mBaseStringsTableView rowsHeightChangedForRow:index];
		[mLocalizedStringsTableView rowsHeightChangedForRow:index];		
	}
}

- (void)stringsFilterDidChange:(NSNotification*)notif
{
	[self refreshStringControllers];
}

- (void)quoteSubstitutionDidChange:(NSNotification*)notif
{
    [self cacheQuoteSubstitution];
}

- (void)editorFontDidChange:(NSNotification*)notif
{

}

- (void)tableContentSizeDidChange:(NSNotification*)notif
{
	[self setNeedsDisplayToAllTableView];	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"showKeyColumn"]) {
		[self toggleKeyColumn];
	} else if([keyPath isEqualToString:@"showTextZone"]) {
		[self toggleTextZone];
	} else if([keyPath isEqualToString:@"autoPropagateTranslationMode"]) {
		[self updatePropagationMode];
	} else if([keyPath isEqualToString:@"baseLanguageReadOnly"]) {
		[self ensureBindingTextView];
	} else if([keyPath isEqualToString:@"showInvisibleCharacters"]) {
		[self updateTextZone];
	}    
}

- (void)removeBindingTextView
{
    [baseTextView unbind:@"value"];
    [localizedBaseTextView unbind:@"value"];
    [localizedTextView unbind:@"value"];
    [baseInfoField unbind:@"value"];
    [localizedBaseInfoField unbind:@"value"];
    [localizedInfoField unbind:@"value"];
    
    [baseTextView unbind:@"editable"];
    [localizedBaseTextView unbind:@"editable"];
    [localizedTextView unbind:@"editable"];
}

- (void)ensureBindingTextView
{
	[baseTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[localizedBaseTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[localizedTextView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	
	NSString *keypath;
	if([baseCommentButton state] == NSOnState) {
		keypath = @"selection.baseComment";
	} else {
		keypath = @"selection.base";
	}
	
	[baseTextView bind:@"value"
			  toObject:mStringsController
		   withKeyPath:keypath
			   options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];
	
	if([localizedCommentButton state] == NSOnState) {
		keypath = @"selection.baseComment";
	} else {
		keypath = @"selection.base";
	}
	
	[localizedBaseTextView bind:@"value"
			  toObject:mStringsController
		   withKeyPath:keypath
			   options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];
	
	if([localizedCommentButton state] == NSOnState) {
		keypath = @"selection.translationComment";
	} else {
		keypath = @"selection.translation";
	}
	
	[localizedTextView bind:@"value"
				   toObject:mStringsController
				withKeyPath:keypath
					options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];
		
	if([baseCommentButton state] == NSOnState) {
		keypath = @"selection.baseCommentInfo";
	} else {
		keypath = @"selection.baseInfo";
	}
	
	[baseInfoField bind:@"value"
			   toObject:mStringsController
			withKeyPath:keypath
				options:NULL];
	
	if([localizedCommentButton state] == NSOnState) {
		keypath = @"selection.baseCommentInfo";
	} else {
		keypath = @"selection.baseInfo";
	}
	
	[localizedBaseInfoField bind:@"value"
			   toObject:mStringsController
			withKeyPath:keypath
				options:NULL];
	
	if([localizedCommentButton state] == NSOnState) {
		keypath = @"selection.translationCommentInfo";
	} else {
		keypath = @"selection.translationInfo";
	}
	
	[localizedInfoField bind:@"value"
			   toObject:mStringsController
			withKeyPath:keypath
				options:NULL];

	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	options[NSContinuouslyUpdatesValueBindingOption] = @YES;
	
	[baseTextView bind:@"editable"
			  toObject:mStringsController
		   withKeyPath:@"selection.baseEditable"
			   options:options];

	[localizedBaseTextView bind:@"editable"
			  toObject:mStringsController
		   withKeyPath:@"selection.baseEditable"
			   options:options];

	[localizedTextView bind:@"editable"
			  toObject:mStringsController
		   withKeyPath:@"selection.editable"
			   options:options];
	
	[baseTextView setNeedsDisplay:YES];
	[localizedBaseTextView setNeedsDisplay:YES];
	[localizedTextView setNeedsDisplay:YES];	
    
    [[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_BASE] setEditable:![[Preferences shared] baseLanguageReadOnly]];
    [[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_BASE] setEditable:![[Preferences shared] baseLanguageReadOnly]];
}

- (void)markUsedFileControllers
{
	[[self allFilesOfSelectedLanguage] makeObjectsPerformSelector:@selector(unmarkUsed)];
	
	NSEnumerator *enumerator = [[mStringsController selectedObjects] objectEnumerator];
	StringController *sc;
	while((sc = [enumerator nextObject])) {
		FileController *fc = [sc parent];
		[fc markUsed];
	}
}

- (void)refreshStringControllers
{
	NSMutableArray *array = [NSMutableArray array];
	for(FileController *fc in mFileControllers) {
		[fc clearCache];
		[array addObjectsFromArray:[fc filteredStringControllers]];		
	}
	[mStringsController setContent:array];
//	[mStringsController setFilterPredicate:[[[self projectProvider] projectWC] currentFilterPredicate]];

	[mBaseStringsTableView rowsHeightChanged];
	[mLocalizedStringsTableView rowsHeightChanged];
	
	[self markUsedFileControllers];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ILDisplayedStringsDidChange
														object:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:ILStringSelectionDidChange
														object:[mStringsController selectedObjects]];
}

- (void)setFileControllers:(NSArray*)fcs
{
	[super setFileControllers:fcs];
    [self cacheQuoteSubstitution];
	[self refreshStringControllers];
	
	[self ensureBindingTextView];
	[baseTextView setLanguage:[self baseLanguage]];
	[localizedBaseTextView setLanguage:[self baseLanguage]];
	[localizedTextView setLanguage:[self localizedLanguage]];
}

- (void)exportFile:(NSString*)sourcePath toStringsFile:(NSString*)targetPath
{
	if([sourcePath isPathStrings]) {
		// copy the file (no conversion needed)
		[[FileTool shared] copySourceFile:sourcePath toFile:targetPath console:[self console]];
	} else {
		// convert nib to strings
		NibEngine *nibEngine = [NibEngine engineWithConsole:[self console]];
		id models = [nibEngine parseStringModelsOfNibFile:sourcePath];
		
		StringsEngine *engine = [StringsEngine engineWithConsole:[self console]];
		NSString *encodedStrings = [engine encodeStringModels:models baseStringModels:nil
													skipEmpty:NO format:STRINGS_FORMAT_APPLE_STRINGS
													 encoding:ENCODING_UNICODE];
		[encodedStrings writeToFile:targetPath atomically:YES encoding:NSUnicodeStringEncoding error:nil];
	}
}

- (void)translateUsingStringsFile:(NSString*)file
{
	BOOL translateIfDifferentFromBase = [[NSUserDefaults standardUserDefaults] boolForKey:@"externalTranslateOnlyIfDifferentFromBase"];
	
	StringsEngine *engine = [StringsEngine engineWithConsole:[self console]];
	StringsContentModel *stringModels = [engine parseStringModelsOfStringsFile:file];
	if([stringModels numberOfStrings]) {
		NSEnumerator *enumerator = [[mStringsController content] objectEnumerator];
		StringController *sc;
		while((sc = [enumerator nextObject])) {
			NSString *translation = [[stringModels stringModelForKey:[sc key]] value];
			if(!translation)
				continue;
			
			if([[sc translation] isEqualToString:translation])
				continue;
			
			if(!translateIfDifferentFromBase || (translateIfDifferentFromBase && ![[sc base] isEqualToString:translation])) {
				[sc setAutomaticTranslation:translation];
			}
		}		
	}
}

- (void)pushState
{
	NSTableView *tv = [self isBaseLanguage]?mBaseStringsTableView:mLocalizedStringsTableView;
	[[self stackState] pushObject:[tv selectedRowIndexes]];
	[[self stackState] pushObject:[NSValue valueWithRect:[tv visibleRect]]];
}

- (void)popState
{
	NSTableView *tv = [self isBaseLanguage]?mBaseStringsTableView:mLocalizedStringsTableView;

	id visibleRectValue = [[self stackState] popObject];	
	id indexes = [[self stackState] popObject];
	
	if(indexes) {
		[tv selectRowIndexes:indexes byExtendingSelection:NO];
		[tv scrollRowToVisible:[tv selectedRow]];
	}
	
	if(visibleRectValue) {
		NSRect r = [visibleRectValue rectValue];		
		[tv scrollPoint:r.origin];
	}	
}

- (void)cacheQuoteSubstitution
{
    mQuoteSubstitution = [PreferencesLanguages quoteSubstitutionEnabled];

    // Base language
    mOpenDoubleBaseLanguage = [PreferencesLanguages openDoubleQuoteSubstitutionForLanguage:[self baseLanguage]];

    mCloseDoubleBaseLanguage = [PreferencesLanguages closeDoubleQuoteSubstitutionForLanguage:[self baseLanguage]];

    mOpenSingleBaseLanguage = [PreferencesLanguages openSingleQuoteSubstitutionForLanguage:[self baseLanguage]];

    mCloseSingleBaseLanguage = [PreferencesLanguages closeSingleQuoteSubstitutionForLanguage:[self baseLanguage]];

    // Localized language
    mOpenDoubleLocalizedLanguage = [PreferencesLanguages openDoubleQuoteSubstitutionForLanguage:[self localizedLanguage]];
    
    mCloseDoubleLocalizedLanguage = [PreferencesLanguages closeDoubleQuoteSubstitutionForLanguage:[self localizedLanguage]];
    
    mOpenSingleLocalizedLanguage = [PreferencesLanguages openSingleQuoteSubstitutionForLanguage:[self localizedLanguage]];
    
    mCloseSingleLocalizedLanguage = [PreferencesLanguages closeSingleQuoteSubstitutionForLanguage:[self localizedLanguage]];    
}

#pragma mark -

- (NSButton*)newToolButtonWithTitle:(NSString*)title action:(SEL)action
{
	NSFont *font = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	attributes[NSFontAttributeName] = font;		

	NSSize size = [title sizeWithAttributes:attributes];
	NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (int)size.width+10, 23)];
	[button setTitle:title];
	[button setTarget:self];
	[button setAction:action];
	[button setButtonType:NSPushOnPushOffButton];
	[button setBezelStyle:NSSmallSquareBezelStyle];
	[button setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin];
	[[button cell] setControlSize:NSMiniControlSize];
	[[button cell] setFont:font];
	
	return button;
}

- (NSScrollView*)newScrolledTextView:(NSRect)frame
{
	NSScrollView *sv = [[NSScrollView alloc] initWithFrame:frame];
	[sv setBorderType:NSNoBorder];
	[sv setHasVerticalScroller:YES];
	[sv setHasHorizontalScroller:NO];
	[sv setAutohidesScrollers:YES];
	[sv setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	NSSize contentSize = [sv contentSize];
	
	TextViewCustom *tv = [[TextViewCustom alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
	[tv setMinSize:NSMakeSize(0.0, contentSize.height)];
	[tv setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
	[tv setVerticallyResizable:YES];
	[tv setHorizontallyResizable:NO];
	[tv setAutoresizingMask:NSViewWidthSizable];
	[tv setRichText:NO];
	[tv setAllowsUndo:YES];

	[[tv textContainer] setContainerSize:NSMakeSize(contentSize.width, FLT_MAX)];
	[[tv textContainer] setWidthTracksTextView:YES];
		
	[sv setDocumentView:tv];	
	
	return sv;
}

- (NSTextField*)newLabelField:(NSRect)frame
{
	NSFont *font = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]];
	
	NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
	[label setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin|NSViewMaxXMargin];
	[label setEditable:NO];
	[label setBordered:NO];
	[label setSelectable:NO];
	[label setDrawsBackground:NO];	
	
	[[label cell] setControlSize:NSMiniControlSize];
	[[label cell] setFont:font];

	return label;
}

static int toolHeight = 23;

/**
 Creates the base language editor view
 */
- (void)createBaseEditorView
{	
	NSRect editorViewFrame = NSMakeRect(0, 0, 100, 100);
	baseEditorView = [[AZClearView alloc] initWithFrame:editorViewFrame];
	baseEditorView.yLine = toolHeight-3;
	[baseEditorView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	
	// Lock button
	baseLockButton = [self newToolButtonWithTitle:@"" action:@selector(toggleLock:)];
	[baseLockButton setFrameOrigin:NSMakePoint(-1, editorViewFrame.size.height-toolHeight+2)];
	[baseLockButton setFrameSize:NSMakeSize(27, toolHeight)];
	[baseLockButton setImage:[NSImage imageNamed:NSImageNameLockLockedTemplate]];
	[[baseLockButton cell] accessibilitySetOverrideValue:NSLocalizedString(@"Toggle string lock", @"Lock Button Accessibility Title") forAttribute:NSAccessibilityTitleAttribute];
	
	[baseEditorView addSubview:baseLockButton];
	
	// Comment button
	baseCommentButton = [self newToolButtonWithTitle:NSLocalizedString(@"Comment", @"Toggle between comment and value button")
												 action:@selector(toggleComment:)];
	[baseCommentButton setFrameOrigin:NSMakePoint(baseLockButton.frame.size.width-2, editorViewFrame.size.height-toolHeight+2)];
	[baseEditorView addSubview:baseCommentButton];
	
	// Info labels
	NSRect fieldRect = baseCommentButton.frame;
	fieldRect.origin.x = baseCommentButton.frame.origin.x + baseCommentButton.frame.size.width + 5;
	fieldRect.size.width = editorViewFrame.size.width - fieldRect.origin.x;
	fieldRect.origin.y += 5;
	fieldRect.size.height = 12;
	baseInfoField = [self newLabelField:fieldRect];
	[baseEditorView addSubview:baseInfoField];
	
	// Text zone	
	NSRect scrollFrame = editorViewFrame;
	scrollFrame.size.height -= toolHeight - 3;
	NSScrollView *sv = [self newScrolledTextView:scrollFrame];
	baseTextView = [sv documentView];
	[baseEditorView addSubview:sv];	
}

/**
 Creates the localized language editor view
 */
- (void)createLocalizedEditorView
{
	NSRect editorViewFrame = NSMakeRect(0, 0, 500, 100);
	localizedEditorView = [[AZClearView alloc] initWithFrame:editorViewFrame];
	localizedEditorView.yLine = toolHeight-3;
	[localizedEditorView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	
	// Lock button
	localizedLockButton = [self newToolButtonWithTitle:@"" action:@selector(toggleLock:)];
	[localizedLockButton setFrameOrigin:NSMakePoint(-1, editorViewFrame.size.height-toolHeight+2)];
	[localizedLockButton setFrameSize:NSMakeSize(27, toolHeight)];
	[localizedLockButton setImage:[NSImage imageNamed:NSImageNameLockLockedTemplate]];
	[[localizedLockButton cell] accessibilitySetOverrideValue:NSLocalizedString(@"Toggle string lock", @"Lock Button Accessibility Title") forAttribute:NSAccessibilityTitleAttribute];

	[localizedEditorView addSubview:localizedLockButton];
	
	// Comment button
	localizedCommentButton = [self newToolButtonWithTitle:NSLocalizedString(@"Comment", @"Toggle between comment and value button")
												 action:@selector(toggleComment:)];
	[localizedCommentButton setFrameOrigin:NSMakePoint(localizedLockButton.frame.size.width-2, editorViewFrame.size.height-toolHeight+2)];
	[localizedEditorView addSubview:localizedCommentButton];
	
	// Propagation button
	propagationModeButton = nil;
	for(int i=0; i<3; i++) {
		NSButton *biggestButton = [self newToolButtonWithTitle:[self propagationTitle:i] action:@selector(togglePropagation:)];
		if(biggestButton.frame.size.width > propagationModeButton.frame.size.width) {
			propagationModeButton = biggestButton;
			[propagationModeButton setButtonType:NSMomentaryPushInButton];
			[propagationModeButton setFrameOrigin:NSMakePoint(localizedCommentButton.frame.origin.x+localizedCommentButton.frame.size.width-2, editorViewFrame.size.height-toolHeight+2)];
		} else {
		}

	}
	[localizedEditorView addSubview:propagationModeButton];

	// Info labels
	NSRect fieldRect = propagationModeButton.frame;
	fieldRect.origin.x = propagationModeButton.frame.origin.x + propagationModeButton.frame.size.width + 5;
	fieldRect.size.width = editorViewFrame.size.width - fieldRect.origin.x - 5;
	fieldRect.origin.y += 5;
	fieldRect.size.height = 12;
	
	localizedBaseInfoField = [self newLabelField:fieldRect];
	[localizedEditorView addSubview:localizedBaseInfoField];

	localizedInfoField = [self newLabelField:fieldRect];
	[localizedInfoField setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin|NSViewMinXMargin];
	[localizedInfoField setAlignment:NSRightTextAlignment];
	[localizedEditorView addSubview:localizedInfoField];
	
	// Text zones
	NSRect scrollFrame = editorViewFrame;
	scrollFrame.size.height -= toolHeight - 3;
		
	NSRect baseScrollFrame = scrollFrame;
	baseScrollFrame.origin.x = 0;
	baseScrollFrame.size.width = scrollFrame.size.width/2 + 1;
	NSScrollView *sv = [self newScrolledTextView:baseScrollFrame];
	localizedBaseTextView = [sv documentView];

	NSRect localizedScrollFrame = scrollFrame;
	localizedScrollFrame.origin.x = baseScrollFrame.size.width;
	localizedScrollFrame.size.width /= 2;
	NSScrollView *sv2 = [self newScrolledTextView:localizedScrollFrame];
	localizedTextView = [sv2 documentView];
	
	NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:scrollFrame];
	[splitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
	[splitView setVertical:YES];
	[splitView setDividerStyle:NSSplitViewDividerStyleThin];
	[splitView addSubview:sv];
	[splitView addSubview:sv2];

    
	[localizedEditorView addSubview:splitView];		
}

- (void)awake
{
	[self createBaseEditorView];
	[self createLocalizedEditorView];
	
	//
	[baseTextView setDelegate:self];
	[localizedBaseTextView setDelegate:self];
	[localizedTextView setDelegate:self];
    
	// Sort the key column using numerical comparison
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES comparator:(NSComparator)^(id obj1, id obj2) {
		return [obj1 compare:obj2 options:NSNumericSearch];
	}];
	[[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_KEY] setSortDescriptorPrototype:descriptor];							
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_KEY] setSortDescriptorPrototype:descriptor];							
	
	[mBaseStringsTableView setDelegate:self];	
	[[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_KEY] setDataCell:[TableViewCustomCell textCell]];
	[[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_BASE] setDataCell:[TableViewCustomCell textCell]];
	[[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_LABEL] setDataCell:[StringLabelCustomCell cell]];

	[mLocalizedStringsTableView setDelegate:self];
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_KEY] setDataCell:[TableViewCustomCell textCell]];
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_BASE] setDataCell:[TableViewCustomCell textCell]];
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_STATUS] setDataCell:[StringStatusCustomCell cell]];
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_TRANSLATION] setDataCell:[TableViewCustomCell textCell]];
	[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_LABEL] setDataCell:[StringLabelCustomCell cell]];
	
	[mLocalizedStringsTableView setTarget:self];
	[mLocalizedStringsTableView setDoubleAction:@selector(doubleClickOnLocalizedTableView:)];	
	
	[[mBaseStringsTableView headerView] setMenu:mTableCornerMenu];
	[[mLocalizedStringsTableView headerView] setMenu:mTableCornerMenu];	
	
	[[self projectPrefs] addObserver:self forKeyPath:@"showInvisibleCharacters" options:0 context:nil];
	[[self projectPrefs] addObserver:self forKeyPath:@"showKeyColumn" options:0 context:nil];
	[[self projectPrefs] addObserver:self forKeyPath:@"showTextZone" options:0 context:nil];
	
	[self buildViews];
	[self toggleKeyColumn];
	[self updatePropagationMode];
}

- (void)close {
    [[self projectPrefs] removeObserver:self forKeyPath:@"showInvisibleCharacters"];
	[[self projectPrefs] removeObserver:self forKeyPath:@"showKeyColumn"];
	[[self projectPrefs] removeObserver:self forKeyPath:@"showTextZone"];
    [super close];
}

- (void)willHide
{
	// Remove objects because otherwise they are released with the NSArrayController which occurs in the NSAutoreleasePool (the window seems to autorelease
	// its outlets)
	[mStringsController removeObjects:[mStringsController content]];
}

- (void)willShow
{
	[[[mBaseStringsTableView tableColumnWithIdentifier:COLUMN_BASE] headerCell] setStringValue:[self baseLanguageDisplay]];
	[[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_BASE] headerCell] setStringValue:[self baseLanguageDisplay]];
	[[[mLocalizedStringsTableView tableColumnWithIdentifier:COLUMN_TRANSLATION] headerCell] setStringValue:[self localizedLanguageDisplay]];	
    
    [self cacheQuoteSubstitution];	
	
	[baseTextView setCustomDelegate:self];
	[localizedBaseTextView setCustomDelegate:self];
	[localizedTextView setCustomDelegate:self];

	[mBaseStringsTableView rowsHeightChanged];
	[mLocalizedStringsTableView rowsHeightChanged];
	
	[self updateTextZone];
}

- (void)updateTextZone
{
	[baseTextView setShowInvisibleCharacters:[self projectPrefs].showInvisibleCharacters];
	[localizedBaseTextView setShowInvisibleCharacters:[self projectPrefs].showInvisibleCharacters];
	[localizedTextView setShowInvisibleCharacters:[self projectPrefs].showInvisibleCharacters];
}

- (void)toggleTextZone
{
	[mBaseTableView removeFromSuperview];
	[baseEditorView removeFromSuperview];
	[[mBaseTableView superview] removeFromSuperview]; // for the splitview
	
	[mLocalizedTableView removeFromSuperview];
	[localizedEditorView removeFromSuperview];
	[[mLocalizedTableView superview] removeFromSuperview]; // for the splitview
	
	[self buildViews];
}

- (void)toggleKeyColumn
{
	[[mBaseStringsTableView tableColumnWithIdentifier:@"Key"] setHidden:![self projectPrefs].showKeyColumn]; 
	[[mLocalizedStringsTableView tableColumnWithIdentifier:@"Key"] setHidden:![self projectPrefs].showKeyColumn]; 
}

- (void)assembleInView:(NSView*)view table:(NSView*)tableView text:(NSView*)textView
{
	if([[self projectProvider] projectPrefs].showTextZone) {
		NSSplitView *sv = [[NSSplitView alloc] initWithFrame:view.frame];
		[sv setDividerStyle:NSSplitViewDividerStyleThin];
		[sv setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
		[sv addSubview:tableView];
		[sv addSubview:textView];
		[view addSubview:sv];			
		int height = view.frame.size.height / 3;
		[textView setFrame:NSMakeRect(0, 0, view.frame.size.width, height)];
		[tableView setFrame:NSMakeRect(0, height+[sv dividerThickness], view.frame.size.width, view.frame.size.height - height - [sv dividerThickness])];
	} else {
		[tableView setFrame:view.frame];
		[tableView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin];
		[view addSubview:tableView];
	}
}

- (void)buildViews
{
	[self assembleInView:mBaseView table:mBaseTableView text:baseEditorView];
	[self assembleInView:mLocalizedView table:mLocalizedTableView text:localizedEditorView];
}

- (NSArrayController*)stringsController
{
	return mStringsController;
}

- (NSArray*)selectedStringControllers
{
	return [mStringsController selectedObjects];
}

- (StringController*)selectedStringController
{
	return [[self selectedStringControllers] firstObject];
}

- (void)selectContentItem:(id)item
{
	[mStringsController setSelectedObjects:@[item]];
}

- (NSArray*)selectedContentItems
{
	return [mStringsController selectedObjects];
}

- (void)selectNextItem
{
	unsigned index = [mStringsController selectionIndex]+1;
	if(index <= [[mStringsController content] count]) {
		[mStringsController setSelectionIndex:index];
	}
}

#pragma mark -

- (IBAction)setSearchString:(id)sender
{
	[self refreshStringControllers];
}

- (void)showControlCharacters_:(BOOL)visible
{
	NSResponder *responder = [[self window] firstResponder];
	if([responder isKindOfClass:[NSTextView class]]) {
		NSTextView *tv = (NSTextView*)responder;
		NSString *string = NULL;
		if(visible) {
			string = [ControlCharactersParser showControlCharacters:[tv string]];
		} else {
			string = [ControlCharactersParser hideControlCharacters:[tv string]];
		}
		[tv setString:string];
		
		if(tv == baseTextView || tv == localizedBaseTextView) {
			if([baseCommentButton state] == NSOnState) {
				[[self selectedStringController] setBaseComment:string];				
			} else {
				[[self selectedStringController] setBase:string];
			}
		} else {
			if([localizedCommentButton state] == NSOnState) {
				[[self selectedStringController] setTranslationComment:string];				
			} else {
				[[self selectedStringController] setTranslation:string];
			}			
		}
	}
}

- (IBAction)showControlCharacters:(id)sender
{
	[self showControlCharacters_:YES];
}

- (IBAction)hideControlCharacters:(id)sender
{
	[self showControlCharacters_:NO];
}

- (void)updateLockStates {
    StringController *sc = [[self selectedStringControllers] firstObject];
    __block NSInteger state = sc.lock?NSOnState:NSOffState;
    
    [[self selectedStringControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StringController *sc = obj;
        if (sc.lock && state != NSOnState) {
            state = NSMixedState;
        } if (!sc.lock && state != NSOffState) {
            state = NSMixedState;
        }
	}];

    [baseLockButton setState:state];
    [localizedLockButton setState:state];
}

- (void)toggleLock:(id)sender
{
	[[self selectedStringControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[obj setLock:[sender state] == NSOnState];
	}];
}

- (void)toggleComment:(id)sender
{
	[self ensureBindingTextView];
}

- (NSString*)propagationTitle:(int)mode
{
	NSString *title = nil;
	switch (mode) {
		case AUTO_PROPAGATE_TRANSLATION_NONE:
			title = NSLocalizedString(@"No Propagation", nil);
			break;
		case AUTO_PROPAGATE_TRANSLATION_SELECTED:
			title = NSLocalizedString(@"Propagate To Selected Files", nil);
			break;
		case AUTO_PROPAGATE_TRANSLATION_ALL:
			title = NSLocalizedString(@"Propagate To All Files", nil);
			break;
	}
	return title;
}

- (void)updatePropagationMode
{
	[propagationModeButton setTitle:[self propagationTitle:[[PreferencesLocalization shared] propagationMode]]];
}

- (IBAction)togglePropagation:(id)sender
{
	[[PreferencesLocalization shared] togglePropagation];
}

#pragma mark -

#define SCOPE_SELECTED_FILES	0
#define SCOPE_ALL_FILES			1

- (void)enumerateStringControllersInScope:(int)scope block:(void(^)(StringController *sc))block {
	mIgnoreCase = [[PreferencesLocalization shared] ignoreCase];
		
	switch(scope) {
		case SCOPE_SELECTED_FILES: {
            for (StringController *sc in mStringsController.content) {
                block(sc);
            }
			break;
        }
            
		case SCOPE_ALL_FILES: {
            for (FileController *fc in [self allFilesOfSelectedLanguage]) {
                for (StringController *sc in [fc visibleStringControllers]) {
                    block(sc);
                }
            }
			break;
		}
	}
}

- (void)prepareApprove
{
	self.originalStringController = [[self selectedStringControllers] firstObject];
}

- (void)approveIdenticalStringsOfStringController:(StringController*)osc toStringController:(StringController*)sc
{
	if([[osc base] isEqualToString:[sc base]] && [[osc translation] isEqualToString:[sc translation]])
		[sc approve];
}

- (void)approveAutoTranslatedStringsOfStringController:(StringController*)osc toStringController:(StringController*)sc
{
	// Note: osc is ignored
	
	if([sc statusToCheck] && ![sc statusToTranslate] && ![sc statusInvariant]) {
		[sc approve];
	}
}

- (void)approveAutoInvariantStringsOfStringController:(StringController*)osc toStringController:(StringController*)sc
{
	// Note: osc is ignored
	
	if([sc statusToCheck] && ![sc statusToTranslate] && [sc statusInvariant]) {
		[sc approve];
	}
}

- (void)propagateTranslationToAllFiles:(BOOL)allFiles block:(PropagationEngineWillChangeStringController)block
{
	NSMutableArray *scs = [NSMutableArray array];
	if(allFiles) {
		for(FileController *fc in [self allFilesOfSelectedLanguage]) {
			[scs addObjectsFromArray:[fc visibleStringControllers]];
		}
	} else {
		[scs addObjectsFromArray:[mStringsController content]];
	}
	
	StringController *sourceStringController = [[self selectedStringControllers] firstObject];
    
	PropagationEngine *pe = [PropagationEngine engine];
	[pe propagateString:sourceStringController toStrings:scs ignoreCase:mIgnoreCase block:block];
}

- (void)propagateTranslationToIdenticalStringsInSelectedFiles:(id)sender block:(PropagationEngineWillChangeStringController)block
{
    [self propagateTranslationToAllFiles:NO block:block];
}

- (void)propagateTranslationToIdenticalStringsInAllFiles:(id)sender block:(PropagationEngineWillChangeStringController)block
{
    [self propagateTranslationToAllFiles:YES block:block];
}

- (void)performAutoPropagation:(PropagationEngineWillChangeStringController)block
{
	if([[PreferencesLocalization shared] autoPropagateTranslationNone]) {
		return;
    }

    [self propagateTranslationToAllFiles:![[PreferencesLocalization shared] autoPropagateTranslationSelectedFiles] block:block];
}

- (void)performStringChecking
{
	StringController *sc = [[self selectedStringControllers] firstObject];
	CheckEngine *engine = [[[self projectProvider] engineProvider] checkEngine];
	[engine markStringController:sc];
}

- (void)autoActionAfterEditing
{	
	[self performAutoPropagation:nil];
	[self performStringChecking];
}

#pragma mark -

- (IBAction)approveString:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(approve)];	
}

- (IBAction)approveIdenticalStringsInSelectedFiles:(id)sender
{
	[self prepareApprove];
    [self enumerateStringControllersInScope:SCOPE_SELECTED_FILES block:^(StringController *sc) {
        [self approveIdenticalStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveIdenticalStringsInAllFiles:(id)sender
{
	[self prepareApprove];
    [self enumerateStringControllersInScope:SCOPE_ALL_FILES block:^(StringController *sc) {
        [self approveIdenticalStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveAutoTranslatedStringsInSelectedFiles:(id)sender
{
    [self enumerateStringControllersInScope:SCOPE_SELECTED_FILES block:^(StringController *sc) {
        [self approveAutoTranslatedStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveAutoTranslatedStringsInAllFiles:(id)sender
{
    [self enumerateStringControllersInScope:SCOPE_ALL_FILES block:^(StringController *sc) {
        [self approveAutoTranslatedStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveAutoInvariantStringsInSelectedFiles:(id)sender
{
    [self enumerateStringControllersInScope:SCOPE_SELECTED_FILES block:^(StringController *sc) {
        [self approveAutoInvariantStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveAutoInvariantStringsInAllFiles:(id)sender
{
    [self enumerateStringControllersInScope:SCOPE_ALL_FILES block:^(StringController *sc) {
        [self approveAutoInvariantStringsOfStringController:self.originalStringController toStringController:sc];
    }];
}

- (IBAction)approveAutoHandledStringsInSelectedFiles:(id)sender
{
	[self approveAutoInvariantStringsInSelectedFiles:sender];
	[self approveAutoTranslatedStringsInSelectedFiles:sender];
}

- (IBAction)approveAutoHandledStringsInAllFiles:(id)sender
{
	[self approveAutoInvariantStringsInAllFiles:sender];
	[self approveAutoTranslatedStringsInAllFiles:sender];
}

- (IBAction)markStringsAsTranslated:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(markAsTranslated)];	
}

- (IBAction)unmarkStringsAsTranslated:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(unmarkAsTranslated)];
}

- (IBAction)copyBaseStringsToTranslation:(id)sender
{
    [[self selectedStringControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StringController *sc = obj;
        [[[self undoManager] prepareWithInvocationTarget:self] undoCopyBaseStringsToTranslationWithTranslation:sc.translation stringController:sc];
        [sc copyBaseToTranslation];
    }];
    
	if([[self selectedStringControllers] count] == 1) {
        NSMutableArray *undoArray = [NSMutableArray array];
		[self performAutoPropagation:^(id<StringControllerProtocol> string) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"translation"] = string.translation;
            dic[@"status"] = @(string.status);
            dic[@"scp"] = string;
            [undoArray addObject:dic];
        }];
        if (undoArray.count > 0) {
            [[[self undoManager] prepareWithInvocationTarget:self] undoAutoPropagationArray:undoArray];
        }
	}
}

- (void)undoAutoPropagationArray:(NSArray*)array {
    NSMutableArray *redoArray = [NSMutableArray array];

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        StringController *scp = dic[@"scp"];
        NSString *translation = dic[@"translation"];
        unsigned char status = [dic[@"status"] unsignedCharValue];
        
        // Prepare the redo dictionary
        NSMutableDictionary *redoDic = [NSMutableDictionary dictionary];
        redoDic[@"translation"] = scp.translation;
        redoDic[@"status"] = @(scp.status);
        redoDic[@"scp"] = scp;
        [redoArray addObject:redoDic];
        
        // Apply the undo
        [scp setAutomaticTranslation:translation];
        scp.status = status;
    }];
    
    [[[self undoManager] prepareWithInvocationTarget:self] undoAutoPropagationArray:redoArray];
}

- (void)undoCopyBaseStringsToTranslationWithTranslation:(NSString*)translation stringController:(StringController*)sc {
    [[[self undoManager] prepareWithInvocationTarget:self] undoCopyBaseStringsToTranslationWithTranslation:sc.translation stringController:sc];
    sc.translation = translation;
}

- (IBAction)swapBaseStringsToTranslation:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(swapBaseAndTranslation)];	
}

- (IBAction)clearBaseComments:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(clearBaseComment)];	
}

- (IBAction)clearTranslationComments:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(clearTranslationComment)];	
}

- (IBAction)clearComments:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(clearComments)];	
}

- (IBAction)clearTranslations:(id)sender
{
	[[self selectedStringControllers] makeObjectsPerformSelector:@selector(clearTranslation)];	
}

#pragma mark -

- (NSString*)windowToolTipRequestedAtPosition:(NSPoint)pos
{
	NSRect tv = [mLocalizedStringsTableView convertRect:[mLocalizedStringsTableView visibleRect] toView:nil];
	if(NSPointInRect(pos, tv)) {
		int row;
		int column;
		NSPoint posInCell = [Utils posInCellAtMouseLocation:pos row:&row column:&column tableView:mLocalizedStringsTableView];
		if(!NSEqualPoints(posInCell, NSMakePoint(-1, -1)) &&
		   [[(NSTableColumn*)[mLocalizedStringsTableView tableColumns][column] identifier] isEqualToString:@"Status"]) {
			StringController *sc = [[self stringsController] arrangedObjects][row];
			return [sc statusDescriptionAtPosition:posInCell];
		}
	}	
	return nil;
}

#pragma mark -

- (void)setNeedsDisplayToAllTableView
{
	[mBaseStringsTableView setNeedsDisplay:YES];
	[mLocalizedStringsTableView setNeedsDisplay:YES];	
}

#pragma mark -

- (void)doubleClickOnLocalizedTableView:(id)sender
{
    if([mLocalizedStringsTableView clickedColumn] < 0) return;
    if([mLocalizedStringsTableView clickedRow] < 0) return;
    
	NSTableColumn *column = [mLocalizedStringsTableView tableColumns][[mLocalizedStringsTableView clickedColumn]];
    NSString *identifier = [column identifier];
	StringController *controller = [mStringsController arrangedObjects][[mLocalizedStringsTableView clickedRow]];
	if([identifier isEqualToString:COLUMN_STATUS]) {
		if([controller statusToCheck])
			[controller approve];
		else if([controller statusToTranslate])
			[controller copyBaseToTranslation];
		else if([controller statusMarkAsTranslated]) 
			[controller unmarkAsTranslated];
		else
			[controller setTranslation:@""];
		[self performAutoPropagation:nil];
	} else if(![identifier isEqualToString:COLUMN_LABEL]) {
        BOOL editable = NO;
        if([identifier isEqualToString:COLUMN_BASE] && [controller baseEditable]) {
            editable = YES;
        }
        if([identifier isEqualToString:COLUMN_TRANSLATION] && [controller editable]) {
            editable = YES;
        }
        if(editable) {
            int col = [mLocalizedStringsTableView columnWithIdentifier:[column identifier]];
            int row = [mLocalizedStringsTableView selectedRow];
            [mLocalizedStringsTableView editColumn:col row:row withEvent:nil select:YES];		            
        }
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
	NSTableView *tv = [notif object];	
	// Note: there is two notifications sent at each selection change, one for each table (base and localized).
	// This is because the NSArrayController is binded to both table -> the selection is changing also in both table.
	// That's why we do a simple test in order to prevent two notifications to be sent out of this method.
	if(([self isBaseLanguage] && tv == mBaseStringsTableView) || 
	   (![self isBaseLanguage] && tv == mLocalizedStringsTableView))
	{
		[baseTextView setNeedsDisplay:YES];
		[localizedBaseTextView setNeedsDisplay:YES];
		[localizedTextView setNeedsDisplay:YES];
		
        [self updateLockStates];        
		[self markUsedFileControllers];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ILStringSelectionDidChange
															object:[mStringsController selectedObjects]];
	}
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
	if(tableView == mLocalizedStringsTableView) {
		[[PasteboardProvider shared] declareTypes:@[PBOARD_DATA_STRINGS, PBOARD_DATA_ROW_INDEXES]
											owner:self
									   pasteboard:pboard];
		[pboard setData:[NSArchiver archivedDataWithRootObject:rowIndexes] forType:PBOARD_DATA_ROW_INDEXES];
		return YES;
	}
	
	return NO;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
	if(![[sender types] containsObject:PBOARD_DATA_ROW_INDEXES]) {
		NSLog(@"No rows found in pasteboard!");
		return;
	}
	
	NSIndexSet *rowIndexes = [NSUnarchiver unarchiveObjectWithData:[sender dataForType:PBOARD_DATA_ROW_INDEXES]];
	
	if([type isEqualToString:PBOARD_DATA_STRINGS]) {
		NSArray *scs = [[mStringsController arrangedObjects] objectsAtIndexes:rowIndexes];
		NSMutableArray *array = [NSMutableArray array];
		StringController *sc;
		for(sc in scs) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			dic[PBOARD_SOURCE_KEY] = [sc base];
			dic[PBOARD_TARGET_KEY] = [sc translation];
			[array addObject:dic];
		}
		[sender setData:[NSArchiver archivedDataWithRootObject:array] forType:type];
	}
}

- (void)tableViewTextDidBeginEditing:(NSTableView*)tv columnIdentifier:(NSString*)identifier rowIndex:(NSInteger)rowIndex textView:(TextViewCustom*)textView
{
    mEditedColumnIsBase = [identifier isEqualToString:COLUMN_BASE];
	
	NSString *language = nil;
	NSString *keypath = nil;
	if([identifier isEqualToString:COLUMN_KEY]) {
		language = [self baseLanguage];
		keypath = @"selection.key";
	}
	if([identifier isEqualToString:COLUMN_BASE]) {
		language = [self baseLanguage];
		keypath = @"selection.base";
	}
	if([identifier isEqualToString:COLUMN_TRANSLATION]) {
		language = [self localizedLanguage];
		keypath = @"selection.translation";
	}	
	
	if(language) {
		[LanguageTool setSpellCheckerLanguage:language];		
	}
			
	[textView setRichText:NO];
	[textView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
	[textView bind:@"value"
		  toObject:mStringsController
	   withKeyPath:keypath
		   options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];	
	
	[textView selectAll:self];
}

- (void)tableViewTextDidEndEditing:(NSTableView*)tv textView:(TextViewCustom*)textView
{
	[textView unbind:@"value"];    
	[self autoActionAfterEditing];
}

- (void)tableViewTextDidEndEditing:(NSTableView*)tv
{
	[self autoActionAfterEditing];
}

- (NSString*)quoteSubstitutionOfString:(NSString*)string range:(NSRange)affectedCharRange replacementString:(NSString*)replacementString base:(BOOL)base
{
    if(!mQuoteSubstitution)
        return nil;
    
    NSString *od;
    NSString *cd;
    NSString *os;
    NSString *cs;
    if(base) {
        od = mOpenDoubleBaseLanguage;
        cd = mCloseDoubleBaseLanguage;
        os = mOpenSingleBaseLanguage;
        cs = mCloseSingleBaseLanguage;
    } else {
        od = mOpenDoubleLocalizedLanguage;
        cd = mCloseDoubleLocalizedLanguage;
        os = mOpenSingleLocalizedLanguage;
        cs = mCloseSingleLocalizedLanguage;
    }
    
    BOOL opening = YES;
    if(affectedCharRange.location > 0) {
        unichar c = [string characterAtIndex:affectedCharRange.location-1];
        if(c != ' ' && c != '\t' && c != '\n' && c != NOBREAK_SPACE)
            opening = NO;
    }
    
    NSString *s = nil;
    
    if([replacementString isEqualToString:@"\""]) {
        s = opening?od:cd;
    }
    
    if([replacementString isEqualToString:@"'"]) {
        s = opening?os:cs;
    }
    
    // Make sure it's a copy of the original substitution to avoid a release on the original one
    return [s copy];
}

- (NSString*)quoteSubstitutionOfString:(NSString*)string range:(NSRange)affectedCharRange replacementString:(NSString*)replacementString
{
    return [self quoteSubstitutionOfString:string range:affectedCharRange replacementString:replacementString base:mEditedColumnIsBase];
}

- (BOOL)textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    NSString *s = [self quoteSubstitutionOfString:[tv string] range:affectedCharRange replacementString:replacementString base:tv == baseTextView || tv == localizedBaseTextView];
    if(s) {
        [tv insertText:s];
        return NO;            
    } else
        return YES;
}

- (BOOL)customTableViewHasCustomHighlight
{
	return YES;
}

- (NSColor*)customTableViewAlternateBackgroundColor
{
//	return [[PreferencesGeneral shared] tableViewAlternateBackgroundColor];
	return nil;
}

- (void)labelContextMenuAction:(id)sender
{
	[ProjectLabels labelContextMenuAction:sender controllers:[self selectedStringControllers]];
	[[self projectProvider] setDirty];
}

- (NSMenu*)labelsMenu
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Labels"];
	[[[[self projectProvider] projectWC] projectLabels] buildLabelsMenu:menu target:self action:@selector(labelContextMenuAction:)];
	[ProjectLabels updateLabelsMenuForCurrentSelection:menu controllers:[self selectedStringControllers]];
	return menu;	
}

- (void)menuNeedsUpdate:(NSMenu*)menu
{
	[mLabelsMenuItem setSubmenu:[self labelsMenu]];		
}

- (NSMenu*)customTableViewContextualMenu:(TableViewCustom*)tv row:(int)row column:(int)column
{
	if(tv == mBaseStringsTableView || tv == mLocalizedStringsTableView) {
		if(row == -1)
			return nil;
		
		if(column != -1 && [[((NSTableColumn*)[tv tableColumns][column]) identifier] isEqualToString:COLUMN_LABEL]) {
			return [self labelsMenu];
		} else
			return mTableViewContextualMenu;
	} else
		return nil;
}

- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	StringController *sc = [mStringsController arrangedObjects][row];
	if([[tableColumn identifier] isEqualToString:COLUMN_BASE]) {
		[cell setValue:[sc base]];		
	} else if([[tableColumn identifier] isEqualToString:COLUMN_TRANSLATION]) {
		[cell setValue:[sc translation]];		
	} else if([[tableColumn identifier] isEqualToString:COLUMN_KEY]) {
		[cell setValue:[sc key]];		
	}
	[cell setShowInvisibleCharacters:[[[sc projectProvider] projectPrefs] showInvisibleCharacters]];
	[cell setRepresentedObject:sc];
	if([sc lock]) {
		if([cell isHighlighted]) {
			if([[aTableView window] firstResponder] == aTableView) {
				[cell setForegroundColor:[NSColor lightGrayColor]];	
			} else {
				[cell setForegroundColor:[NSColor grayColor]];
			}
		} else {
			[cell setForegroundColor:[NSColor grayColor]];	
		}
	} else if([cell isHighlighted]) {
		[cell setForegroundColor:[NSColor whiteColor]];
	} else {
		[cell setForegroundColor:[NSColor blackColor]];		
	}	
	
	// Now set any content matching available for this string controller.
	[cell setContentMatching:nil];
	
	if(aTableView != mBaseStringsTableView && aTableView != mLocalizedStringsTableView) {
		return;
	}
	
	BOOL base = [[tableColumn identifier] isEqualToString:COLUMN_BASE];
	if(!base && ![[tableColumn identifier] isEqualToString:COLUMN_TRANSLATION]) {
		return;
	}
	
	if(![cell isKindOfClass:[TableViewCustomCell class]]) {
		return;
	}
	
	[cell setContentMatching:base?sc.baseStringController.contentMatching:sc.contentMatching];
	[cell setContentMatchingItem:base?SCOPE_STRINGS_BASE:SCOPE_STRINGS_TRANSLATION];
}

- (void)tableViewModifierFlagsChanged:(NSEvent*)event
{
	[[[self projectProvider] projectWC] tableViewModifierFlagsChanged:event];
}

#pragma mark -

- (NSMenu*)customTextViewAsksForContextualMenu:(TextViewCustom*)tv
{
	return mTextViewContextualMenu;
}

- (void)textDidEndEditing:(NSNotification *)notif
{
	NSTextView *tv = [notif object];
	if(tv == localizedTextView) {
		[self autoActionAfterEditing];
	}
}

- (BOOL)shouldStopOnStringController:(StringController*)sc
{
	return [sc statusToTranslate] || [sc statusToCheck];
}

- (int)indexOfNextNonTranslatedString
{
	NSArray *content = [mStringsController arrangedObjects];
	
	BOOL backwards = ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) > 0;	
	int startIndex = [content indexOfObject:[self selectedStringController]];
	int maxIndex = [content count];
	int index = startIndex;
	while(YES) {
		if(backwards) {
			index--;
		} else {
			index++;			
		}
		
		if(index>=maxIndex)
			index = 0;
		if(index<0)
			index = maxIndex-1;
		
		if(index == startIndex) {
			// Back at the start position -> no more strings to translate
			if(![self shouldStopOnStringController:content[index]]) {
				if(backwards) {
					if(index > 0)
						return index-1;
					else
						return maxIndex-1;
				} else {
					if(index+1<maxIndex)
						return index+1;
					else
						return 0;					
				}
			}
			break;			
		}
		
		if([self shouldStopOnStringController:content[index]]) {
			break;
		}
	}	
	return index;
}

- (void)tableViewDidHitEnterKey:(NSTableView*)tv
{
	[self autoActionAfterEditing];

	// Select the next string to translate or the next line if no strings remain to translate.
	int index = [self indexOfNextNonTranslatedString];
	int row = index;
	if(row >= 0) {
		[tv selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		[tv editColumn:[tv columnWithIdentifier:@"Translation"] row:row withEvent:nil select:YES];	
		[(TableViewCustom*)tv makeSelectedRowVisible];
	}		
}

- (void)textViewDidHitEnterKey:(TextViewCustom*)view
{
	// Before changing the current string, perform the auto-action after editing (mostly
	// to approve the status)
	[self autoActionAfterEditing];

	// Select the next string to translate or the next line if no strings remain to translate.
	[mStringsController setSelectionIndex:[self indexOfNextNonTranslatedString]];
	[mLocalizedStringsTableView makeSelectedRowVisible];
	[mBaseStringsTableView makeSelectedRowVisible];
	[[self window] makeFirstResponder:view];
	[view selectAll:self];
}

#pragma mark -

- (IBAction)performDebugAction:(id)sender
{
	switch([sender tag]) {
		case 10:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugSetStatus:) 
															  withObject:@STRING_STATUS_BASE_MODIFIED];
			break;
		case 11:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugClearStatus:) 
															  withObject:@STRING_STATUS_BASE_MODIFIED];
			break;
		case 12:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugSetStatus:) 
															  withObject:@STRING_STATUS_TOTRANSLATE];
			break;
		case 13:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugClearStatus:) 
															  withObject:@STRING_STATUS_TOTRANSLATE];
			break;
		case 14:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugSetStatus:) 
															  withObject:@STRING_STATUS_TOCHECK];
			break;
		case 15:
			[[self selectedStringControllers] makeObjectsPerformSelector:@selector(debugClearStatus:) 
															  withObject:@STRING_STATUS_TOCHECK];
			break;
	}
}

@end
