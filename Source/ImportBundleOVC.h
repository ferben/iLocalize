//
//  ImportAppWC.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZListSelectionView.h"

@interface ImportBundleOVC : OperationViewController
{
    IBOutlet NSButton            *mImportBaseButton;
    IBOutlet NSButton            *mImportLocalizedButton;
    IBOutlet NSButton            *mImportCheckLayoutCheckbox;
    IBOutlet NSButton            *mImportImportLayoutsCheckbox;
    IBOutlet NSButton            *mCopyOnlyIfExistsCheckbox;
    IBOutlet NSOutlineView       *mLanguagesOutlineView;
    IBOutlet NSObjectController  *mUIController;
    
    IBOutlet NSPathControl       *mBaseBundlePathControl;
    IBOutlet NSPathControl       *mLocalizedBundlePathControl;
    
    IBOutlet NSImageView         *mNibWarningIcon;
    IBOutlet NSTextField         *mNibWarningText;

    AZListSelectionView          *mLanguagesSelectionView;
    BOOL                          applySettingsWithSelectLanguage;
}

- (BOOL)importBaseLanguage;
- (BOOL)keepLayout;
- (BOOL)importOtherLanguages;
- (NSArray *)languages;

- (NSString *)baseBundle;
- (NSString *)localizedBundle;

- (BOOL)layouts;
- (BOOL)copyOnlyIfExists;

- (void)setDefaultBundle:(NSString *)bundle;

- (IBAction)keepExistingNibLayouts:(id)sender;
- (IBAction)importNibLayouts:(id)sender;

- (IBAction)importBaseBundle:(id)sender;
- (IBAction)importLocalizedBundle:(id)sender;

- (IBAction)chooseBaseBundle:(id)sender;
- (IBAction)chooseLocalizedBundle:(id)sender;

- (IBAction)help:(id)sender;

@end
