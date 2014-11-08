//
//  GlossaryWC.h
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableViewCustomDefaultDelegate.h"

@class AZArrayController;
@class Glossary;
@class AddLanguageWC;
@class TableViewCustom;
@class CustomFieldEditor;

@interface GlossaryWC : NSWindowController<NSOpenSavePanelDelegate, AZTableViewDelegate> {
	IBOutlet AZArrayController	*mEntriesController;
	IBOutlet NSObjectController	*mGlossaryController;
	
	IBOutlet NSTextField		*mInfoField;
	IBOutlet TableViewCustom	*mEntryTableView;
	
	IBOutlet NSView			*mTopRightWindowView;

    CustomFieldEditor		*mCustomFieldEditor;
	
	NSString				*mFilterValue;
    BOOL                    mCheckWhenSaved;
    
    Glossary                *glossary;
	AddLanguageWC			*mAddLanguageWC;
	
	BOOL					mShowInvisibleCharacters;
}

@property (strong) Glossary *glossary;

+ (GlossaryWC*)controller;

- (void)reload;
- (void)applyChanges;

- (void)selectEntryWithBase:(NSString*)base translation:(NSString*)translation;

- (IBAction)indexGlossary:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)search:(id)sender;

- (IBAction)renameSourceLanguage:(id)sender;
- (IBAction)renameTargetLanguage:(id)sender;

- (IBAction)removeDuplicateEntries:(id)sender;

@end
