//
//  HistoryManager.h
//  iLocalize3
//
//  Created by Jean on 29.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class ProjectController;
@class StringController;

@interface HistoryManager : NSObject
{
    NSMutableArray       *mHistorySnapshots;
    NSMutableDictionary  *mHistoryData;
    
    ProjectController    *mProjectController;
    NSString             *mFile;
    BOOL                  mDirty;
}

- (void)setProjectController:(ProjectController *)controller;

- (void)saveData;

- (void)createSnapshot:(NSString *)name  date:(NSDate *)date;
- (void)deleteSnapshot:(unsigned int)uid;

- (NSArray *)historyForStringController:(StringController *)sc;
- (NSArray *)snapshots;

@end
