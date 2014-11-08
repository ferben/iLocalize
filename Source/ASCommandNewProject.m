//
//  ASCommandNewProject.m
//  iLocalize
//
//  Created by Jean on 12/2/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ASCommandNewProject.h"
#import "ASProject.h"
#import "ASManager.h"

#import "ApplicationDelegate.h"
#import "NewProjectSettings.h"
#import "NibEngine.h"

@implementation ASCommandNewProject

- (id)performDefaultImplementation
{
	NSLog(@"Execute %@", [self commandDescription]);
	NSLog(@"Arguments %@", [self evaluatedArguments]);
	NSLog(@"Receivers %@", [self evaluatedReceivers]);
	NSLog(@"dp %@", [self directParameter]);
	
	
	[[ASManager shared] beginAsyncCommand:self delegate:nil];
	
//	NSDictionary *args = [self evaluatedArguments];
	
//	NewProjectSettings *settings = [[[NewProjectSettings alloc] init] autorelease];
//	[settings setName:[args objectForKey:@"name"]];
//	[settings setProjectFolder:[args objectForKey:@"target"]];
//	[settings setSourcePath:[args objectForKey:@"source"]];
//	[settings setBaseLanguage:[args objectForKey:@"baseLanguage"]];
//	[settings setLocalizedLanguages:[args objectForKey:@"languages"]];
//	[settings setCopySourceOnlyIfExists:[args objectForKey:@"createNonExistingLocalizedFiles"] != nil];
	
//	if([[args objectForKey:@"compatibility"] intValue] == 1) {
//		[settings setNibtoolType:TYPE_IBTOOL];	 
//	} else {
//		[settings setNibtoolType:TYPE_NIBTOOL];
//	}
	
	/*	[settings setProjectName:@"Amadeus Pro"];
	 [settings setProjectFolder:@"/Volumes/Marcel/Test/Amadeus Pro"];
	 [settings setProjectSourcePath:@"/Applications/Amadeus Pro.app"];
	 [settings setBaseLanguage:@"English"];
	 [settings setLocalizedLanguages:[NSArray arrayWithObject:@"English"]];
	 [settings setCopySourceOnlyIfExists:NO];
	 [settings setNibtoolType:TYPE_NIBTOOL];*/
	
	// todo next release
	//[[NSApp delegate] createNewProject:settings];
	
	return nil;
}

@end
