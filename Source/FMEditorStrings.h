//
//  FMEditorStrings.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"
#import "TextViewCustom.h"
#import "TableViewCustomDefaultDelegate.h"

@class TableViewCustom;
@class StringController;
@class AZClearView;

@interface FMEditorStrings : FMEditor<NSTextViewDelegate, NSTableViewDelegate, TextViewCustomDelegate, AZTableViewDelegate> {
	IBOutlet NSView					*mBaseTableView;
	IBOutlet NSView					*mLocalizedTableView;
	
	IBOutlet NSView					*mEmptyView;
	IBOutlet NSArrayController		*mStringsController;
	
	IBOutlet TableViewCustom		*mBaseStringsTableView;
	IBOutlet TableViewCustom		*mLocalizedStringsTableView;
				
	IBOutlet NSMenu					*mTableViewContextualMenu;
	IBOutlet NSMenu					*mTextViewContextualMenu;
	
	IBOutlet NSMenuItem				*mLabelsMenuItem;
	IBOutlet NSMenu					*mTableCornerMenu;

	// Base editor view
	AZClearView						*baseEditorView;
	NSButton						*baseLockButton;
	NSButton						*baseCommentButton;
	NSTextField						*baseInfoField;
	TextViewCustom					*baseTextView;

	// Localized editor view
	AZClearView						*localizedEditorView;
	NSButton						*localizedLockButton;
	NSButton						*localizedCommentButton;
	NSButton						*propagationModeButton;
	NSTextField						*localizedBaseInfoField;
	NSTextField						*localizedInfoField;

	TextViewCustom					*localizedBaseTextView;
	TextViewCustom					*localizedTextView;

	//
		
	BOOL							mIgnoreCase;
	
	BOOL							mDisplayingComments;
	NSIndexSet						*mSelectedStringsRowIndexes;
    
    BOOL                            mEditedColumnIsBase;
    
    // Cache information
    BOOL    mQuoteSubstitution;
    NSString *mOpenDoubleBaseLanguage;
    NSString *mCloseDoubleBaseLanguage;
    NSString *mOpenSingleBaseLanguage;
    NSString *mCloseSingleBaseLanguage;
    
    NSString *mOpenDoubleLocalizedLanguage;
    NSString *mCloseDoubleLocalizedLanguage;
    NSString *mOpenSingleLocalizedLanguage;
    NSString *mCloseSingleLocalizedLanguage;    
}

- (void)updateTextZone;
- (void)toggleTextZone;
- (void)toggleKeyColumn;

- (void)buildViews;

- (NSArrayController*)stringsController;

- (NSArray*)selectedStringControllers;
- (StringController*)selectedStringController;

- (NSString*)quoteSubstitutionOfString:(NSString*)string range:(NSRange)affectedCharRange replacementString:(NSString*)replacementString;

- (IBAction)setSearchString:(id)sender;

- (IBAction)showControlCharacters:(id)sender;
- (IBAction)hideControlCharacters:(id)sender;

- (void)updateLockStates;

- (IBAction)toggleLock:(id)sender;
- (IBAction)toggleComment:(id)sender;

- (NSString*)propagationTitle:(int)mode;
- (void)updatePropagationMode;
- (IBAction)togglePropagation:(id)sender;

- (IBAction)markStringsAsTranslated:(id)sender;
- (IBAction)unmarkStringsAsTranslated:(id)sender;

- (IBAction)copyBaseStringsToTranslation:(id)sender;
- (IBAction)swapBaseStringsToTranslation:(id)sender;

- (IBAction)performDebugAction:(id)sender;

@end
