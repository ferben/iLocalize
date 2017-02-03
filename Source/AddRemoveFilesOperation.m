//
//  AddRemoveFilesOperation.m
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AddRemoveFilesOperation.h"

#import "OperationWC.h"
#import "AddLocationWC.h"

#import "ProjectWC.h"

@implementation AddRemoveFilesOperation

- (void)awake
{
    mFiles = NULL;
    mLanguage = NULL;
}


- (AddLocationWC *)addLocationWC
{
    return (AddLocationWC *)[self instanceOfAbstractWCName:@"AddLocationWC"];
}

#pragma mark -

- (void)addFiles_
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel beginSheetModalForWindow:[self projectWindow]
                  completionHandler:^(NSInteger result)
    {
        if (result == NSFileHandlingPanelCancelButton)
        {
            [self close];
            return;
        }
       
        [self performSelector:@selector(performAddFiles:) withObject:[panel URLs] afterDelay:0];
    }];
}

- (void)addFiles
{
    mLanguage = nil;
    [self addFiles_];
}

- (void)addFilesToLanguage:(NSString*)language
{
    mLanguage = language;
    [self addFiles_];
}

- (void)performAddFiles:(NSArray*)files
{
    mFiles = nil;
    NSMutableArray *convertedFiles = [NSMutableArray arrayWithCapacity:files.count];

    for (NSObject *f in files)
    {
        if ([f isKindOfClass:[NSURL class]])
        {
            NSURL *url = (NSURL*)f;
            [convertedFiles addObject:[url path]];
        }
        else
        {
            [convertedFiles addObject:f];
        }
    }
    
    mFiles = convertedFiles;
    
    [[self addLocationWC] setDidCloseSelector:@selector(performAddFiles) target:self];
    [[self addLocationWC] showAsSheet];
}

- (void)performAddFiles
{
    if ([[self addLocationWC] hideCode] != 1)
    {
        [self close];
        return;
    }    
    
    if ([mFiles count] > 1)
    {
        [[self operation] setTitle:NSLocalizedString(@"Adding Files…", nil)];
        [[self operation] setCancellable:NO];
        [[self operation] setIndeterminate:YES];
        [[self operation] showAsSheet];        
    }
    
    [[self operationDispatcher] addFiles:mFiles language:mLanguage toSmartPath:[[self addLocationWC] location] completion:^(id results)
    {
        [[[[self projectProvider] projectWC] languagesController] rearrangeObjects];
        
        [[self operation] hide];
        [self close];
    }];
}

#pragma mark -

- (void)removeFileControllers:(NSArray*)fileControllers
{
    mFileControllers = fileControllers;

    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"AddRemoveFileOperationsTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"AddRemoveFileOperationsDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];  // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextDelete",@"Alerts",nil)];  // 2nd button
    
    // show and evaluate alert
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        [self close];
        return;
    }
    
    if ([mFileControllers count] > 1)
    {
        [[self operation] setTitle:NSLocalizedString(@"Removing Files…", nil)];
        [[self operation] setCancellable:NO];
        [[self operation] setIndeterminate:YES];
        [[self operation] showAsSheet];        
    }
    
    [[[self projectProvider] projectWC] deselectAll];
    
    [[self operationDispatcher] removeFileControllers:mFileControllers completion:^(id results)
    {
        [[[[self projectProvider] projectWC] languagesController] rearrangeObjects];
        
        [[self operation] hide];
        [self close];
    }];
}

@end
