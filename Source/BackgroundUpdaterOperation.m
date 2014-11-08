//
//  BackgroundUpdaterOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 10/13/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "BackgroundUpdaterOperation.h"
#import "FileController.h"
#import "PreferencesGeneral.h"
#import "SynchronizeEngine.h"
#import "SaveAllOperation.h"
#import "ProjectController.h"

@implementation BackgroundUpdaterOperation

@synthesize fcs;

- (BOOL)cancellable {
    return NO;
}

- (void)execute {
    [self setOperationName:NSLocalizedString(@"Updating Files…", nil)];
    [self setProgressMax:self.fcs.count];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        BOOL manualSynchFromDisk = NO;
        [[self.projectProvider projectController] beginOperation];

        for (FileController *fc in self.fcs) {
            [fc beginDirty];
            [fc updateStatus];
            if([fc statusSynchFromDisk]) {
                if([[PreferencesGeneral shared] automaticallyReloadFiles])
                    [[[self.projectProvider engineProvider] synchronizeEngine] synchronizeFromDiskIfNeeded:fc];
                else
                    manualSynchFromDisk = YES;
            }
            [fc endDirty];
            
            [self progressIncrement];
        }
        
        [[self.projectProvider projectController] endOperation];
        
        if(manualSynchFromDisk)
            [[SaveAllOperation operationWithProjectProvider:self.projectProvider] reloadFiles];
        else
            [self.projectProvider rearrangeFilesController];
    });
}

@end
