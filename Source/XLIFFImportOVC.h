//
//  XLIFFImportOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class XLIFFImportSettings;

@interface XLIFFImportOVC : OperationViewController
{
    IBOutlet NSPathControl  *filePathControl;
    XLIFFImportSettings     *settings;
}

@property (weak) IBOutlet NSButton *useResnameInsteadOfSource;
@property (strong) XLIFFImportSettings *settings;

- (IBAction)chooseFile:(id)sender;

@end
