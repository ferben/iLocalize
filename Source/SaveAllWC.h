//
//  SaveAllWC.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

#define SAVEALL_CANCEL     0
#define SAVEALL_SAVEALL    1
#define SAVEALL_DONT_SAVE  2

@class TableViewCustom;

@interface SaveAllWC : AbstractWC<NSTableViewDelegate>
{
    IBOutlet NSArrayController  *mController;
    IBOutlet TableViewCustom    *mFilesTableView;
    IBOutlet NSTextField        *mTitle;
    IBOutlet NSButton           *mDontAction;
    IBOutlet NSButton           *mCancelAction;
    IBOutlet NSButton           *mDefaultAction;
    
    int                          mMode;
}

- (void)setFileControllers:(NSArray *)controllers;
- (NSArray *)fileControllersToSave;

- (void)setDisplaySave;
- (void)setDisplayReload;

- (BOOL)moveSave;
- (BOOL)modeReload;

- (void)setActionFollow:(BOOL)follow;

- (IBAction)cancel:(id)sender;
- (IBAction)dontSave:(id)sender;
- (IBAction)saveAll:(id)sender;

@end
