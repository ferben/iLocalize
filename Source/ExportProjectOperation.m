//
//  ProjectExportLocalization.m
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ExportProjectOperation.h"
#import "ProjectExportMailScripts.h"
#import "ExportProjectSettings.h"

#import "OperationWC.h"
#import "EngineProvider.h"
#import "OptimizeEngine.h"
#import "ResourceFileEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "FileTool.h"
#import "Console.h"

#import "Constants.h"
#import "NSAppleScript+HandlerCalls.h"
#import "ASManager.h"
#import "LanguageTool.h"
#import "FileOperationManager.h"
#import "FileMergeOperationManager.h"

@implementation ExportProjectOperation

@synthesize settings;

- (id)init
{
	if((self = [super init])) {
	}
	return self;
}

- (BOOL)performCopy:(NSString*)targetBundle
{
	BOOL success = YES;
	
	NSString *sourceApp = [[self projectProvider] sourceApplicationPath];

	// Now perform the copy
	[self setProgressMax:self.settings.filesToCopy.count];

    __block NSError *outError = nil;
    
	if(self.settings.mergeFiles) {
        FileMergeOperationManager *fmom = [FileMergeOperationManager manager];
        [fmom mergeProjectFiles:self.settings.filesToCopy projectSource:sourceApp inTarget:targetBundle errorHandler:^BOOL(NSError *error) {
            [[self console] addLog:[NSString stringWithFormat:@"Problem copying \"%@\" to \"%@\" (%@)", sourceApp, targetBundle, error] class:[self class]];
            outError = error;
            return NO;
        } progressHandler:^(NSString *source, NSString *target) {
            [self progressIncrement];		
        }];
    } else {
        [targetBundle movePathToTrash];
        [[FileTool shared] preparePath:targetBundle atomic:YES skipLastComponent:YES];
        
        FileOperationManager *fom = [FileOperationManager manager];
        success = [fom copyFiles:self.settings.filesToCopy source:sourceApp target:targetBundle errorHandler:^(NSError *error) {
            [[self console] addLog:[NSString stringWithFormat:@"Problem copying \"%@\" to \"%@\" (%@)", sourceApp, targetBundle, error] class:[self class]];
            outError = error;
            return NO;
        } progressHandler:^(NSString *source, NSString *target) {
            [self progressIncrement];		
        }];        
    }

	if(!success) {
		[self notifyError:outError];
		success = NO;
		goto end;
	}
	
end:
	return success;
}

- (void)createEmailUsingScript:(NSString*)scriptFile file:(NSString*)file error:(NSString**)error
{
	if(![scriptFile isPathExisting]) {
		*error = [NSString stringWithFormat:NSLocalizedString(@"Cannot find the script file “%@”", nil), scriptFile];
		return;
	}
	
	// Content: add two new lines to have the attachment a bit below the main text
	NSString *content = @"";
    if (self.settings.emailMessage) {
        content = [NSString stringWithFormat:@"%@\n\n", self.settings.emailMessage];
    }
	
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithContentsOfFile:scriptFile usedEncoding:nil error:nil]];
	NSAppleEventDescriptor *arguments = [[NSAppleEventDescriptor alloc] initListDescriptor];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.settings.emailToAddress] atIndex:1];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.settings.emailSubject] atIndex:2];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:content] atIndex:3];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:file] atIndex:4];
	
	NSDictionary *errorInfo = nil;
	NSAppleEventDescriptor *result = [script callHandler:@"exloc_email" withArguments:arguments errorInfo:&errorInfo];
	
	if([result int32Value] != 0) {
		*error = [NSString stringWithFormat:@"%d", (int)[result int32Value]];
	} else if(errorInfo) {
		*error = [NSString stringWithFormat:@"%@: %@", errorInfo[NSAppleScriptErrorNumber], errorInfo[NSAppleScriptErrorBriefMessage]];
	}
	
}

- (void)performCleaning:(NSString*)target
{
	[[[self engineProvider] optimizeEngine] cleanApp:target];
}

- (void)performCompactNib:(NSString*)target
{
	[[[self engineProvider] optimizeEngine] compactNibInApp:target];
}

- (void)performUpgradeNib:(NSString*)target
{
	[[[self engineProvider] optimizeEngine] upgradeNibInApp:target];
}

- (BOOL)performCompress:(NSString*)source to:(NSString*)target
{
	NSString *compressedTempTarget = [[source stringByDeletingPathExtension] stringByAppendingPathExtension:@"zip"];
	if([FileTool zipPath:source toFileName:compressedTempTarget recursive:YES]) {
        if (![compressedTempTarget isEqualToPath:target]) {
            // Move the temp target only if its path is different from the target
            if([[NSFileManager defaultManager] moveItemAtPath:compressedTempTarget toPath:target error:nil]) {
                [compressedTempTarget removePathFromDisk];
                [source removePathFromDisk];
            }
        }
		return YES;
	} else {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"An error occurred when compressing the exported localization", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"zip returned an error", nil)];
		[alert runModal];
		return NO;
	}	
}

- (void)performEmail: (NSString *)target
{
	NSString *error = nil;
	[self createEmailUsingScript:[[ProjectExportMailScripts shared] scriptFileForPrograms:[settings emailProgram]]
							file:target
						   error:&error];
	
	if (error) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"An error occurred while creating a new e-mail", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"AppleScript returned “%@”", nil), error];
		[alert runModal];			
	}		
}

- (void)execute
{
	[self setOperationName:NSLocalizedString(@"Exporting Project…", nil)];
			
	NSString *targetBundle = self.settings.targetBundle;
	
	BOOL success = [self performCopy:targetBundle];
	if(success) {
        if(!self.settings.mergeFiles) {
            [self performCleaning:targetBundle];
            
            if([settings compactNib]) {
                [self performCompactNib:targetBundle];
            }
            
            if ([settings upgradeNib]) {
                [self performUpgradeNib:targetBundle];
            }
        }

		if([settings compress]) {
			success = [self performCompress:targetBundle to:self.settings.compressedTargetBundle];
			if(success) {
                NSError *err = nil;
                if(![targetBundle removePathFromDisk:&err]) {
                    ERROR(@"Error removing original bundle: %@", err);
                }
				targetBundle = self.settings.compressedTargetBundle;
			}
		}
		
		if([settings email] && success) {
			[self performEmail:targetBundle];		
		}					
	}
}

@end
