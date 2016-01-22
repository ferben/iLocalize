//
//  HistoryManager.m
//  iLocalize3
//
//  Created by Jean on 29.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "HistoryManager.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "PreferencesAdvanced.h"
#import "ProjectWC.h"

#import "Constants.h"

@implementation HistoryManager

- (id)init
{
    if(self = [super init]) {
        mHistorySnapshots = nil;
        mHistoryData = nil;
        mProjectController = nil;
        mFile = nil;
        mDirty = NO;
    }
    return self;
}


- (void)setProjectController:(ProjectController*)controller
{
    mProjectController = controller;
    
    NSString *projectFile = [[[[mProjectController projectProvider] projectWC] document] fileURL].path;
    NSString *name = [NSString stringWithFormat:@"%@.history", [[projectFile lastPathComponent] stringByDeletingPathExtension]];
    mFile = [[projectFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];    
}

- (NSString*)file
{
    return mFile;
}

- (void)setDirty:(BOOL)flag
{
    mDirty = flag;
}

- (void)loadData
{
    NSString *file = [self file];
    if([file isPathExisting]) {
        NSDictionary *dic = [NSUnarchiver unarchiveObjectWithFile:[self file]];
        if(dic) {
            mHistorySnapshots = dic[@"snapshots"];
            mHistoryData = dic[@"data"];
        }
    }
    
    if(!mHistorySnapshots)
        mHistorySnapshots = [[NSMutableArray alloc] init];
    
    if(!mHistoryData)
        mHistoryData = [[NSMutableDictionary alloc] init];        
}

- (void)saveData
{
    if(mHistorySnapshots == nil || mHistoryData == nil || !mDirty)
        return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"version"] = @1;
    dic[@"snapshots"] = mHistorySnapshots;
    dic[@"data"] = mHistoryData;
    [NSArchiver archiveRootObject:dic toFile:[self file]];
    
    [self setDirty:NO];
}

- (void)checkData
{
    if(mHistoryData == nil || mHistorySnapshots == nil)
        [self loadData];
}

- (void)notifyContentChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ILHistoryDidChange
														object:nil];
}

#pragma mark -

// Structure of the history data:
// file (dictionary:<relative file path>) -> string (dictionary:<string key>) -> array

- (NSMutableDictionary*)fileDataForRelativeFilePath:(NSString*)key
{
    [self checkData];
    
    NSMutableDictionary *dic = mHistoryData[key];
    if(!dic) {
        dic = [NSMutableDictionary dictionary];
        mHistoryData[key] = dic;
    }
    return dic;
}

- (NSMutableArray*)stringDataForStringKey:(NSString*)key inFileData:(NSMutableDictionary*)fileData
{
    NSMutableArray *array = fileData[key];
    if(!array) {
        array = [NSMutableArray array];
        fileData[key] = array;
    }
    return array;
}

- (unsigned int)createSnapshotEntryForName:(NSString*)name date:(NSDate*)date
{
    [self checkData];
    [self setDirty:YES];
    
    while([mHistorySnapshots count] >= [[PreferencesAdvanced shared] maximumNumberOfSnapshots] && [mHistorySnapshots count] > 0) {
        [self deleteSnapshot:[[mHistorySnapshots firstObject][0] unsignedIntValue]];
    }
    
    unsigned int uid = [[mHistorySnapshots lastObject][0] intValue];
    uid++;
    if(uid > 10000)
        uid = 1;
    [mHistorySnapshots addObject:@[@(uid), name, date]];
    return uid;
}

- (void)createSnapshot:(NSString*)name  date:(NSDate*)date
{
    unsigned int uid = [self createSnapshotEntryForName:name date:date];
        
    NSEnumerator *langEnumerator = [[mProjectController languageControllers] objectEnumerator];
    LanguageController *lc;
    while(lc = [langEnumerator nextObject]) {
        NSEnumerator *fileEnumerator = [[lc fileControllers] objectEnumerator];
        FileController *fc;
        while(fc = [fileEnumerator nextObject]) {
            if(![[fc filename] isPathNib] && ![[fc filename] isPathStrings])
                continue;
            
            NSMutableDictionary *fileData = [self fileDataForRelativeFilePath:[fc relativeFilePath]];
            NSEnumerator *stringEnumerator = [[fc stringControllers] objectEnumerator];
            StringController *sc;
            while(sc = [stringEnumerator nextObject]) {
                NSMutableArray *stringData = [self stringDataForStringKey:[sc key] inFileData:fileData];                
                [stringData addObject:@[@(uid), [sc translation]]];
            }
        }
    }    
    
    [self notifyContentChanged];
}

- (void)deleteSnapshot:(unsigned int)uid
{
    [self setDirty:YES];

    NSEnumerator *enumerator = [mHistorySnapshots objectEnumerator];
    NSArray *snap;
    while(snap = [enumerator nextObject]) {
        if([snap[0] unsignedIntValue] == uid) {
            [mHistorySnapshots removeObject:snap];
            break;
        }
    }
    
    [self notifyContentChanged];
}

- (NSArray*)entryForSnapshotUID:(unsigned int)uid history:(NSArray*)history
{
    NSArray *entry;
    for(entry in history) {
        if([entry[0] unsignedIntValue] == uid)
            return entry;
    }
    return nil;
}

- (NSArray*)historyForStringController:(StringController*)sc
{
    [self checkData];

    NSMutableArray *history = [NSMutableArray array];

    FileController *fc = [sc parent];
    
    NSArray *snap;
    for(snap in mHistorySnapshots) {
        unsigned int uid = [snap[0] unsignedIntValue];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"snapshot"] = snap[1];
        dic[@"date"] = snap[2];

        // Extract base information
        NSArray *data = [self stringDataForStringKey:[sc key] 
                                          inFileData:[self fileDataForRelativeFilePath:[[fc baseFileController] relativeFilePath]]];
        NSArray *entry = [self entryForSnapshotUID:uid history:data];
        dic[@"base"] = entry?entry[1]:@"-";
        
        // Extract localized information
        data = [self stringDataForStringKey:[sc key] 
                                          inFileData:[self fileDataForRelativeFilePath:[fc relativeFilePath]]];
        entry = [self entryForSnapshotUID:uid history:data];
        dic[@"translation"] = entry?entry[1]:@"-";
                
        [history addObject:dic];
    }
        
    return history;
}

- (NSArray*)snapshots
{
    [self checkData];
    return mHistorySnapshots;
}

@end
