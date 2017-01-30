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


- (AddLocationWC*)addLocationWC
{
	return (AddLocationWC*)[self instanceOfAbstractWCName:@"AddLocationWC"];
}

#pragma mark -

- (void)addFiles_
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];
    [panel beginSheetModalForWindow:[self projectWindow]
                  completionHandler:^(NSInteger result) {
                      if(result == NSFileHandlingPanelCancelButton) {
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
    for (NSObject *f in files) {
        if ([f isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL*)f;
            [convertedFiles addObject:[url path]];
        } else {
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
	
	NSBeginAlertSheet(NSLocalizedString(@"Delete selected files?", nil),
					  NSLocalizedString(@"Delete", nil), NSLocalizedString(@"Cancel", nil),
					  nil, [self projectWindow], self,
					  nil, @selector(removeFileControllersSheetDidDismiss:returnCode:contextInfo:),
					  (void*)CFBridgingRetain(self),
					  NSLocalizedString(@"Do you really want to delete the selected files? This action cannot be undone.", nil));
	
}

- (void)removeFileControllersSheetDidDismiss:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode != NSAlertDefaultReturn)
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
