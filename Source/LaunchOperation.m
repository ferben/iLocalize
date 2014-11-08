//
//  LaunchOperation.m
//  iLocalize3
//
//  Created by Jean on 21.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LaunchOperation.h"

#import "OperationWC.h"
#import "Console.h"

#import "LanguageController.h"
#import "ProjectModel.h"

#import "FileTool.h"
#import "AppTool.h"

@implementation LaunchOperation

- (BOOL)assertLaunch
{
	if(![[[self projectProvider] sourceApplicationPath] isPathExisting]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Cannot launch the application", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"The application is not found. Make sure to build the application before launching it.", nil)];	
		[alert runModal];
		return NO;
	} else {
		return YES;		
	}
}

- (void)launch
{
	if(![self assertLaunch]) return;
	
	NSString *path = [[[self projectProvider] projectModel] projectSourceFilePath];
	if([path isPathApplication]) {
		[AppTool launchApplication:[[self projectProvider] sourceApplicationPath] 
						  language:[[self selectedLanguageController] language]
					  bringToFront:YES];
	} else {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Cannot launch non-application bundle", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Only .app or .ape bundles can be launched from within iLocalize.", nil)];	
		[alert runModal];
	}
	[self close];
}

@end
