//
//  ToolLaunchApp.m
//  iLocalize3
//
//  Created by Jean on 06.09.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ToolLaunchApp.h"

#import "LanguageTool.h"
#import "AppTool.h"

@implementation ToolLaunchApp

- (id)init
{
	if(self = [super initWithWindowNibName:@"ToolLaunchApp"]) {
		[self window];
	}
	return self;
}

- (void)launchApplication:(NSString*)path
{
    [mLanguagesPopUp removeAllItems];
    [mLanguagesPopUp addItemsWithTitles:[LanguageTool legacyLanguages:[LanguageTool languagesInPath:path]]];
    
	if([NSApp runModalForWindow:[self window]] == 1) {
        [AppTool launchApplication:path language:[mLanguagesPopUp titleOfSelectedItem] bringToFront:YES];
	}
}

- (IBAction)cancel:(id)sender
{
	[[self window] orderOut:self];
	[NSApp stopModalWithCode:0];
}

- (IBAction)launch:(id)sender
{
	[[self window] orderOut:self];
	[NSApp stopModalWithCode:1];
}

@end
