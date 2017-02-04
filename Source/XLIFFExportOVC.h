//
//  XLIFFExportOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class XLIFFExportSettings;
@class LanguageMenuProvider;

@interface XLIFFExportOVC : OperationViewController
{
    IBOutlet NSPopUpButton  *formatPopup;
    IBOutlet NSPopUpButton  *sourceLanguagePopup;
    IBOutlet NSPopUpButton  *targetLanguagePopup;
    IBOutlet NSPathControl  *filePathControl;
    
    // Settings
    XLIFFExportSettings     *settings;
    
    // The class that populates the language popups
    LanguageMenuProvider    *sourceLanguageProvider;
    LanguageMenuProvider    *targetLanguageProvider;
}

@property (strong) XLIFFExportSettings *settings;

- (IBAction)chooseFile:(id)sender;
- (IBAction)formatChanged:(id)sender;

@end
