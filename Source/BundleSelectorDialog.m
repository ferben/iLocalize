//
//  BundleSelectorDialog.m
//  iLocalize
//
//  Created by Jean on 3/29/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "BundleSelectorDialog.h"


@implementation BundleSelectorDialog

@synthesize defaultPath;
@synthesize callback;


- (NSString*)promptForBundle
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:YES];
	[panel setPrompt:NSLocalizedString(@"Select", nil)];
	[panel setDelegate:self];
	[panel setAllowsMultipleSelection:NO];
    if([defaultPath isPathExisting]) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:defaultPath]];
    }
	NSInteger result = [panel runModal];
	if(result == NSOKButton) {
		return [[panel URL] path];
	} else {
		return nil;
	}
}

- (void)promptForBundleForWindow:(NSWindow*)window callback:(CallbackBlockWithFile)_callback
{
	self.callback = _callback;
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:YES];
	[panel setPrompt:NSLocalizedString(@"Select", nil)];
	[panel setDelegate:self];
	[panel setAllowsMultipleSelection:NO];
    if([defaultPath isPathExisting]) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:defaultPath]];
    }
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if(result == NSOKButton) {
            self.callback([[panel URL] path]);
        } else {
            self.callback(nil);
        }	
    }];
}

- (BOOL)panel:(id)sender shouldEnableURL:(nonnull NSURL *)url
{
    NSString *filename = url.path;
    
	return [filename isPathPackage] || [filename isPathDirectory];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
	return YES;	
}

@end
