//
//  UpdateLocalFilesOperation.m
//  iLocalize
//
//  Created by Jean on 9/23/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ImportLocalFilesOperation.h"
#import "LanguageController.h"
#import "FileController.h"
#import "FileMatchItem.h"
#import "FileTool.h"
#import "ImportFilesMultiMatchOVC.h"
#import "FMEngine.h"
#import "FileMatchItem.h"
#import "ImportFilesSettings.h"

@implementation ImportLocalFilesOperation

@synthesize settings;


- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Updating Local Files…", nil)];
    
    for(FileMatchItem *item in self.settings.matchItems) {
        FileController *fc = [item matchingFileController];
        NSString *file = [item file];

        [[FileTool shared] copySourceFile:file
                            toReplaceFile:[fc absoluteFilePath]
                                  console:[self console]];
        [fc setModificationDate:[[fc absoluteFilePath] pathModificationDate]];
        [[[self projectProvider] fileModuleEngineForFile:file] reloadFileController:fc usingFile:[fc absoluteFilePath]];        
    }    
}

@end
