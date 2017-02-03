//
//  ImportFilesLocalizedOp.m
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportFilesLocalizedOp.h"
#import "ImportFilesSettings.h"
#import "ImportLanguagesOp.h"
#import "FileMatchItem.h"

@implementation ImportFilesLocalizedOp

@synthesize settings;

- (BOOL)needsDisconnectInterface
{
    return YES;
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Updating Files of Language…", nil)];
    
    // Build the list of file controllers and files
    NSMutableArray *fileControllers = [NSMutableArray array];
    NSMutableArray *files = [NSMutableArray array];
    
    for(FileMatchItem *item in self.settings.matchItems) {
        [fileControllers addObject:[item matchingFileController]];
        [files addObject:[item file]];
    }
    
    ImportLanguagesOp *op = [ImportLanguagesOp operation];
    [self setSubOperation:op];
    [op updateFileControllers:fileControllers layout:self.settings.updateNibLayouts usingCorrespondingFiles:files resolveConflict:YES];
}

@end
