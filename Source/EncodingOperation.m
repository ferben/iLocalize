//
//  EncodingOperation.m
//  iLocalize3
//
//  Created by Jean on 11/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "EncodingOperation.h"
#import "SynchronizeEngine.h"
#import "FileController.h"
#import "FMEngine.h"
#import "ProjectFilesController.h"

@implementation EncodingOperation

- (void)convertToEncoding:(StringEncoding*)encoding bySavingFiles:(NSArray*)fcs
{
    FileController *fc;
    for(fc in fcs) {    
        BOOL reload = [[[self projectProvider] fileModuleEngineForFile:[fc absoluteFilePath]] willConvertFileController:fc toEncoding:encoding];
        
        // Set the new encoding into the file controller
        [fc setEncoding:encoding];
        [fc setHasEncoding:YES];
        
        // Save the file (it will use the file controller encoding)
        [[[self engineProvider] synchronizeEngine] synchronizeToDisk:fc];
        
        if(reload) {
            [[[self engineProvider] synchronizeEngine] synchronizeFromDisk:fc];                
        }
    }        
}

- (void)convertToEncoding:(StringEncoding*)encoding byReloadingFiles:(NSArray*)fcs
{
    FileController *fc;
    for(fc in fcs) {    
        // First save the file if needed
        [[[self engineProvider] synchronizeEngine] synchronizeToDiskIfNeeded:fc];                

        // Set the new encoding into the file controller
        [fc setEncoding:encoding];
        [fc setHasEncoding:YES];

        // Reload it using the new desired encoding
        [[[self engineProvider] synchronizeEngine] synchronizeFromDisk:fc];    

        // Save the file (using the new encoding)
        [[[self engineProvider] synchronizeEngine] synchronizeToDisk:fc];        
    }        
}

- (void)convertFileControllers:(NSArray*)fcs toEncoding:(StringEncoding*)encoding reload:(BOOL)reload
{
    if(reload) {
        [self convertToEncoding:encoding byReloadingFiles:fcs];
    } else {
        [self convertToEncoding:encoding bySavingFiles:fcs];
    }
        
    [[self projectFiles] updateSelectedFilesEncoding];
}

@end
