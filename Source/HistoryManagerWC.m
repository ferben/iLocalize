//
//  HistoryManagerWC.m
//  iLocalize3
//
//  Created by Jean on 29.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "HistoryManagerWC.h"
#import "HistoryManager.h"

@implementation HistoryManagerWC

- (id)init
{
    if(self = [super initWithWindowNibName:@"HistoryManager"]) {
        mHistoryManager = nil;
        [self window];
    }
    return self;
}


- (void)setHistoryManager:(HistoryManager*)manager
{
    mHistoryManager = manager;
}

- (void)createSnapshot:(NSWindow*)parent
{
    [mNewSnapshotNameField setStringValue:@""];
    [NSApp beginSheet:mNewSnapshotPanel modalForWindow:parent modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)refreshSnapshots
{
    [mSnapshotsController removeObjects:[mSnapshotsController content]];
    NSEnumerator *enumerator = [[mHistoryManager snapshots] objectEnumerator];
    NSArray* snapshot;
    while(snapshot = [enumerator nextObject]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"uid"] = snapshot[0];
        dic[@"name"] = snapshot[1];
        dic[@"date"] = snapshot[2];
        [mSnapshotsController addObject:dic];
    }    
}

- (void)displaySnapshots:(NSWindow*)parent
{
    [self refreshSnapshots];
    [NSApp beginSheet:[self window] modalForWindow:parent modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)cancelNewSnapshot:(id)sender
{
    [NSApp endSheet:mNewSnapshotPanel];
    [mNewSnapshotPanel orderOut:self];
}

- (IBAction)createNewSnapshot:(id)sender
{
    [mHistoryManager createSnapshot:[mNewSnapshotNameField stringValue] date:[NSDate date]];
    
    [NSApp endSheet:mNewSnapshotPanel];
    [mNewSnapshotPanel orderOut:self];
}

- (IBAction)deleteSnapshot:(id)sender
{
    
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"HistoryManagerDeleteTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextDelete",@"Alerts",nil)];      // 2nd button
    
    // show alert
    NSInteger alertReturnCode = [alert runModal];
    
    if (alertReturnCode == NSAlertSecondButtonReturn)
    {
        NSDictionary *dic = [[mSnapshotsController selectedObjects] firstObject];
        [mHistoryManager deleteSnapshot:[dic[@"uid"] unsignedIntValue]];
        [self refreshSnapshots];
    }
}

- (IBAction)closeSnapshotManager:(id)sender
{
    [NSApp endSheet:[self window]];
    [[self window] orderOut:self];
}

@end
