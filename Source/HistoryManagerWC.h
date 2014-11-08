//
//  HistoryManagerWC.h
//  iLocalize3
//
//  Created by Jean on 29.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class HistoryManager;

@interface HistoryManagerWC : NSWindowController {
    IBOutlet NSArrayController  *mSnapshotsController;
    
    IBOutlet NSPanel        *mNewSnapshotPanel;
    IBOutlet NSTextField    *mNewSnapshotNameField;
    
    HistoryManager          *mHistoryManager;   // not retained
}

- (void)setHistoryManager:(HistoryManager*)manager;

- (void)createSnapshot:(NSWindow*)parent;
- (void)displaySnapshots:(NSWindow*)parent;

- (IBAction)cancelNewSnapshot:(id)sender;
- (IBAction)createNewSnapshot:(id)sender;

- (IBAction)deleteSnapshot:(id)sender;
- (IBAction)closeSnapshotManager:(id)sender;

@end
