//
//  ImportFilesSelectionOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class ImportFilesSettings;

@interface ImportFilesSelectionOVC : OperationViewController {
    IBOutlet NSArrayController *filesController;
    ImportFilesSettings *settings;
}

@property (strong) ImportFilesSettings *settings;

- (IBAction)addFiles:(id)sender;
- (IBAction)removeFiles:(id)sender;

@end
