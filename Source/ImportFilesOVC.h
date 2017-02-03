//
//  ImportFilesWC.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class ImportFilesSettings;

@interface ImportFilesOVC : OperationViewController {
    IBOutlet NSButton            *mImportBaseRadio;
    IBOutlet NSButton            *mImportOtherRadio;
    IBOutlet NSButton            *mImportCheckLayoutCheckbox;
    IBOutlet NSButton            *mImportImportLayoutsCheckbox;

    IBOutlet NSTableView        *mLanguagesTableView;
    IBOutlet NSArrayController    *mController;
    
    IBOutlet NSTextField        *mImportBaseLanguageInfo;
    
    IBOutlet NSImageView        *mNibWarningIcon;
    IBOutlet NSTextField        *mNibWarningText;

    ImportFilesSettings *settings;
}

@property (strong) ImportFilesSettings *settings;

- (IBAction)keepExistingNibLayouts:(id)sender;
- (IBAction)importNibLayouts:(id)sender;

- (IBAction)importBaseRadio:(id)sender;
- (IBAction)importOtherRadio:(id)sender;

//- (IBAction)help:(id)sender;

@end
