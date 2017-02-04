//
//  ImportConflictPreviewWC.h
//  iLocalize3
//
//  Created by Jean on 26.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@interface ImportLocalizedResolveConflictsOVC : OperationViewController
{
    IBOutlet NSTableView        *mTableView;
    IBOutlet NSArrayController  *mPreviewController;
    IBOutlet NSPathControl      *sourcePathControl;
    IBOutlet NSPathControl      *targetPathControl;
    
    // Array of FileConflictItem objects;
    NSArray                     *fileConflictItems;
    NSString                    *mProjectPath;
}

@property (strong) NSArray *fileConflictItems;

- (IBAction)allSource:(id)sender;
- (IBAction)allProject:(id)sender;

- (IBAction)openSource:(id)sender;
- (IBAction)revealSource:(id)sender;

- (IBAction)openProject:(id)sender;
- (IBAction)revealProject:(id)sender;

@end
