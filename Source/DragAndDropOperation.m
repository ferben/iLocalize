//
//  DragAndDropOperation.m
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "DragAndDropOperation.h"

#import "WindowLayerWC.h"
#import "ProjectWC.h"
#import "LanguageController.h"

#import "PreferencesWC.h"
#import "PreferencesAdvanced.h"
#import "FileTool.h"

#import "ImportBundleOperationDriver.h"
#import "ImportFilesOperationDriver.h"

#define OPERATION_NONE					0
#define OPERATION_IMPORT_APPLICATION	1
#define OPERATION_IMPORT_FILES			2

#define FIRST_PARAM @"1"

@implementation DragAndDropOperation

- (void)awake
{
	mWindowLayerWC = [[WindowLayerWC alloc] init];
	[mWindowLayerWC setParentWindow:[self projectWindow]];
	[mWindowLayerWC setDelegate:[self projectWC]];
	
	mParameters = [[NSMutableDictionary alloc] init];
	mOperation = OPERATION_NONE;
	mOptionKeyMask = NO;
	
	mFilterApplicationPathsCache = nil;
	mFilterResourcePathsCache = nil;
}


- (void)showWindowLayer
{
	[mWindowLayerWC show];
}

- (void)hideWindowLayer
{
	[mWindowLayerWC hide];
}

- (void)clearFilterCaches
{
	mFilterApplicationPathsCache = nil;

	mFilterResourcePathsCache = nil;
}

- (NSArray *)filterApplicationPaths:(NSArray *)filenames
{
	if (mFilterApplicationPathsCache == nil)
    {
		mFilterApplicationPathsCache = [[filenames pathsIncludingOnlyBundles] mutableCopy];
	}
	
    return mFilterApplicationPathsCache;
}

- (NSArray *)filterResourcePaths:(NSArray *)filenames
{
	if (mFilterResourcePathsCache == nil)
    {
		mFilterResourcePathsCache = [[NSMutableArray alloc] init];
		NSString *path;
        
		for (path in filenames)
        {
			if ([path isPathInvisible])
				continue;
			
			if (![path isPathNib] && ([path isPathAlias] || [path isPathBundle]))
				continue;
			
			if ([path isPathDirectory] && ![path isPathNib] && ![path isPathRTFD])
            {
				NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
				NSString *file;
                
				while (file = [enumerator nextObject])
                {
					if ([file isPathInvisible])
						continue;

					if ([file isPathNibBundle])
						[enumerator skipDescendents];
					else if ([file isPathAlias] || [file isPathBundle])
						continue;                
					
					[mFilterResourcePathsCache addObject:[path stringByAppendingPathComponent:file]];
				}
                
				// Don't add the directory itself
				continue;
			}
			
			[mFilterResourcePathsCache addObject:path];			
		}
	}

    return mFilterResourcePathsCache;
}

- (void)setOperation:(int)op withParameter:(id)parameter
{
	mOperation = op;
	mParameters[FIRST_PARAM] = parameter;
	
	switch (mOperation)
    {
		case OPERATION_IMPORT_APPLICATION:
			[mWindowLayerWC setTitle:NSLocalizedString(@"Update application", nil)];
			[mWindowLayerWC setInfo:[NSString stringWithFormat:@"\"%@\"", [parameter lastPathComponent]]];
			break;
            
		case OPERATION_IMPORT_FILES:
        {
			NSUInteger count = [parameter count];
			
            if (count > 1)
				[mWindowLayerWC setTitle:[NSString stringWithFormat:NSLocalizedString(@"Update %d files", nil), count]];
			else
				[mWindowLayerWC setTitle:[NSString stringWithFormat:NSLocalizedString(@"Update file “%@”", nil), [[parameter firstObject] lastPathComponent]]];
            
			[mWindowLayerWC setInfo:@""];
			break;			
		}
	}
    
	[self showWindowLayer];
}

- (int)operation:(int)op
{
//	BOOL base = [[mMainWindowController selectedLanguageController] isBaseLanguage];	
	return op;
}

- (void)modifierFlagsChanged:(NSEvent *)event
{
	unsigned int flags = [event modifierFlags];	
	mOptionKeyMask = (flags & NSAlternateKeyMask) == NSAlternateKeyMask;
		
	if (mOperation != OPERATION_NONE)
		[self setOperation:[self operation:mOperation] withParameter:mParameters[FIRST_PARAM]];
}

- (void)updateWindowLayerInformationBasedOnFilenames:(NSArray *)filenames
{	
	if ([[self filterApplicationPaths:filenames] count] == 1)
		[self setOperation:[self operation:OPERATION_IMPORT_APPLICATION] withParameter:[[self filterApplicationPaths:filenames] firstObject]];
	else
    {
		NSArray *files = [self filterResourcePaths:filenames];
	
        if ([files count])
			[self setOperation:[self operation:OPERATION_IMPORT_FILES] withParameter:files];
	}
}

- (NSDragOperation)dragOperationBasedOnFilenames:(NSArray *)filenames
{
	if ([[self filterApplicationPaths:filenames] count] == 1)
		return NSDragOperationCopy;
	else
    {
		NSArray *files = [self filterResourcePaths:filenames];
        
		if ([files count] >= 1)
			return NSDragOperationCopy;
	}

    return NSDragOperationNone;
}

- (NSDragOperation)dragOperationEnteredForPasteboard:(NSPasteboard *)pboard
{
	[self clearFilterCaches];
	
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];	
	[self updateWindowLayerInformationBasedOnFilenames:filenames];
	return [self dragOperationBasedOnFilenames:filenames];	
}

- (NSDragOperation)dragOperationUpdatedForPasteboard:(NSPasteboard *)pboard
{
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];	
	[self updateWindowLayerInformationBasedOnFilenames:filenames];
	return [self dragOperationBasedOnFilenames:filenames];	
}

- (void)bringAppToFront
{
	if([NSApp isActive])
		return;
	
	[NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)dragOperationPerformWithPasteboard:(NSPasteboard*)pboard
{
	[self hideWindowLayer];
	
	NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
	
	BOOL result = NO;
	
    if ([[self filterApplicationPaths:filenames] count] == 1)
    {
		switch (mOperation)
        {
			case OPERATION_IMPORT_APPLICATION:
				[self bringAppToFront];
				NSDictionary *args = @{@"importBundlePath": [[self filterApplicationPaths:filenames] firstObject]};
				[[ImportBundleOperationDriver driverWithProjectProvider:[self projectProvider]] executeWithArguments:args];
				result = YES;
				break;
		}
	}
    else
    {
		if ([[self filterResourcePaths:filenames] count])
        {
			[self bringAppToFront];
			NSDictionary *args = @{@"importFilesPaths": [self filterResourcePaths:filenames]};
			[[ImportFilesOperationDriver driverWithProjectProvider:[self projectProvider]] executeWithArguments:args];
			result = YES;
		}
	}
	
	mOperation = OPERATION_NONE;

	return result;
}

- (void)dragOperationEnded
{
	mOperation = OPERATION_NONE;
	[self hideWindowLayer];
}

@end
