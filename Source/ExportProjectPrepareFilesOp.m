//
//  MergeBundleOp.m
//  iLocalize
//
//  Created by Jean Bovet on 6/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ExportProjectPrepareFilesOp.h"
#import "ExportProjectSettings.h"
#import "FileOperationManager.h"
#import "FileMergeOperationManager.h"
#import "Console.h"

@implementation ExportProjectPrepareFilesOp

@synthesize settings;

- (BOOL)prepareFilesToBeCopied
{
    BOOL success = YES;
    
    NSString *sourceApp = [[self projectProvider] sourceApplicationPath];
    
    // Prepare the selected paths
    NSMutableArray *selectedPaths = nil;
    if(self.settings.paths) {
        selectedPaths = [NSMutableArray array];
        for(NSString *path in self.settings.paths) {
            // The path contains the name of the bundle in its first component so let's remove it.
            [selectedPaths addObject:[path stringByRemovingFirstPathComponent]];
        }        
    }
    
    // Enumerate and sort the files to copy
    FileOperationManager *fom = [FileOperationManager manager];
    NSMutableArray *files = [NSMutableArray array];
    __block NSError *outError;
    __block NSURL *urlError;
    success = [fom enumerateDirectory:sourceApp files:files errorHandler:^(NSURL *url, NSError *error) {
        [[self console] addLog:[NSString stringWithFormat:@"Problem listing content directory at \"%@\" (%@)", url, error] class:[self class]];
        outError = error;
        urlError = url;
        return NO;
    }];
    if(!success) {
        [self notifyError:outError];
        success = NO;
        goto end;
    }
    
    // Include only the language selected by the user
    [fom includeLocalizedFilesFromLanguages:self.settings.languages files:files];
    
    // Exclude all the paths not selected by the user
    if(selectedPaths) {
        [fom excludeFiles:files notInPaths:selectedPaths];        
    }
    
    // Exclude any non-language path if the user decided to
    // todo actually this should be set to true always when working on a project from a folder
    
    if(self.settings.exportLanguageFoldersOnly) {
        [fom excludeNonLocalizedFiles:files];
    }
    
    if(self.settings.mergeFiles) {
        FileMergeOperationManager *m = [FileMergeOperationManager manager];
        NSMutableArray *mergeableFiles = [NSMutableArray arrayWithCapacity:files.count];
        BOOL success = [m discoverMergeableFiles:mergeableFiles inTarget:[self.settings targetBundle] usingProjectFiles:files projectSource:sourceApp errorHandler:^BOOL(NSURL *url, NSError *error) {
            [[self console] addLog:[NSString stringWithFormat:@"Problem listing content directory at \"%@\" (%@)", url, error] class:[self class]];
            outError = error;
            urlError = url;
            return NO;            
        }];
        if(!success) {
            [self notifyError:outError];
            goto end;
        }
        [files removeAllObjects];
        [files addObjectsFromArray:mergeableFiles];
    }
    
end:
    if(success) {
        self.settings.filesToCopy = files;
    } else {
        self.settings.filesToCopy = nil;
    }
    return success;
}

- (void)execute
{
    if([self prepareFilesToBeCopied]) {
        if(self.settings.filesToCopy.count == 0) {            
            [self reportInformativeAlertWithTitle:NSLocalizedString(@"Nothing to export", nil)
                                          message:NSLocalizedString(@"No files will be exported because the target bundle is already up to date.", nil)];
        }
    }
}

@end
