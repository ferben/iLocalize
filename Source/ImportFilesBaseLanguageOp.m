//
//  ImportFilesBaseLanguageOp.m
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportFilesBaseLanguageOp.h"
#import "ImportRebaseBundleOp.h"
#import "ImportFilesSettings.h"
#import "FileMatchItem.h"

@implementation ImportFilesBaseLanguageOp

@synthesize settings;

- (BOOL)needsDisconnectInterface
{
    return YES;
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Updating Files of Base Language…", nil)];
    
    // Build the list of file controllers and files
    NSMutableArray *fcs = [NSMutableArray array];
    NSMutableArray *files = [NSMutableArray array];
    
    for(FileMatchItem *item in self.settings.matchItems) {
        [fcs addObject:[item matchingFileController]];
        [files addObject:[item file]];
    }
    
    ImportRebaseBundleOp *op = [ImportRebaseBundleOp operation];
    [self setSubOperation:op];
    op.usePreviousLayout = !self.settings.resetLayout;
    [op rebaseFileControllers:fcs usingCorrespondingFiles:files];
}

@end
