//
//  NewProjectLanguagesOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZListSelectionView.h"

@class NewProjectSettings;

@interface NewProjectLanguagesOVC : OperationViewController<AZListSelectionViewDelegate> {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSPopUpButton	*mBaseLanguagePopUp;
	IBOutlet NSButton       *mCopySourceOnlyIfExists;

	NSMutableArray *languageItems;
	AZListSelectionView *selectionView;
	NewProjectSettings *settings;
	ValidateContinueCallback validateContinueCallback;
}
@property (strong) NewProjectSettings *settings;
@property (copy) ValidateContinueCallback validateContinueCallback;
- (IBAction)baseLanguagePopUp:(id)sender;

@end
