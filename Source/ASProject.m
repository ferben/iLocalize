//
//  ASProject.m
//  iLocalize
//
//  Created by Jean on 12/1/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ASProject.h"
#import "ProjectWC.h"
#import "ProjectDocument.h"
#import "ExportProjectOperation.h"
#import "ProjectExportMailScripts.h"
#import "ASManager.h"
#import "Constants.h"

@implementation ASProject

+ (ASProject*)projectWithDocument:(ProjectDocument*)doc
{
	ASProject *p = [[ASProject alloc] init];
	[p setDocument:doc];
	return p;
}

- (id)init
{
	if(self = [super init]) {
		mDocument = nil;
	}
	return self;
}

- (void)setDocument:(ProjectDocument*)doc
{
	mDocument = doc;
}

- (NSString*)name
{
	return [[mDocument fileURL] path];
}

- (NSScriptObjectSpecifier*)objectSpecifier
{
	NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
					[NSScriptClassDescription classDescriptionForClass:[NSApp class]];
	return [[NSNameSpecifier alloc] initWithContainerClassDescription:containerClassDesc
													containerSpecifier:nil
																   key:@"projects"
																  name:[self name]];
}

#pragma mark Commands

- (id)handleUpdateBaseCommand:(NSScriptCommand*)cmd
{
	NSLog(@"UpdateBase %@", cmd);

	[[ASManager shared] beginAsyncCommand:cmd delegate:self];
	// todo next release
//	[[ImportOperation operationWithProjectProvider:mDocument] performImportApplication];		

	return nil;
}

- (id)handleUpdateLocalizedCommand:(NSScriptCommand*)cmd
{
	NSLog(@"UpdateLocalized %@", cmd);
	
	[[ASManager shared] beginAsyncCommand:cmd delegate:self];
	// todo next release
//	[[ImportOperation operationWithProjectProvider:mDocument] performImportApplication];		
		
	return nil;
}

- (id)handleExportCommand:(NSScriptCommand*)cmd
{
	NSLog(@"Export %@", cmd);
	
//	ASManager *manager = [ASManager shared];
	[[ASManager shared] beginSyncCommand:cmd delegate:self];
		
//	ExportProjectSettings *settings = [[[ExportProjectSettings alloc] init] autorelease];	
//	[settings setExportAll:[manager boolValueForKey:ATTRIBUTE_EXPORT_LOCALIZATION]];
//	[settings setDestination:[manager attributeForKey:ATTRIBUTE_EXPORT_TARGET]];
//	[settings setLanguages:[manager attributeForKey:ATTRIBUTE_EXPORT_LANGUAGES]];
//	[settings setCompress:[manager boolValueForKey:ATTRIBUTE_EXPORT_COMPRESS]];
//	[settings setCompactNib:[manager boolValueForKey:ATTRIBUTE_EXPORT_COMPACTNIB]];	
//	NSString *email = [manager attributeForKey:ATTRIBUTE_EXPORT_EMAIL];
//	[settings setEmail:email != nil];
//	if(email != nil) {
//		[settings setEmailProgram:email];
//	}
//	[settings setupTargetBundle:mDocument];
//		
//	// This command is synchronous
//	[[ExportProjectOperation operationWithProjectProvider:mDocument] exportProject:settings];

	[[ASManager shared] endSyncCommand];

	return nil;
}

#pragma mark Delegate

- (id)scriptAttributeForKey:(NSString*)key command:(NSScriptCommand*)cmd
{
	NSDictionary *args = [cmd evaluatedArguments];
	
	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_UPDATE_BASE]) {
		if([key isEqualToString:ATTRIBUTE_KEY_BASESOURCE]) {
			return args[@"source"];
		}		
	}

	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_UPDATE_LOCALIZED]) {
		if([key isEqualToString:ATTRIBUTE_KEY_LOCALIZEDSOURCE]) {
			return args[@"source"];
		}		
		if([key isEqualToString:ATTRIBUTE_KEY_LANGUAGES]) {
			return args[@"languages"];
		}		
	}
		
	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_EXPORT]) {
		if([key isEqualToString:ATTRIBUTE_EXPORT_TARGET]) {
			return args[@"target"];
		}		
		if([key isEqualToString:ATTRIBUTE_EXPORT_LANGUAGES]) {
			return args[@"languages"];
		}		
		if([key isEqualToString:ATTRIBUTE_EXPORT_EMAIL]) {
			return args[@"email"];
		}		
	}
	
	return nil;
}

- (BOOL)scriptBoolValueForKey:(NSString*)key command:(NSScriptCommand*)cmd
{
	NSDictionary *args = [cmd evaluatedArguments];

	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_UPDATE_BASE]) {
		if([key isEqualToString:ATTRIBUTE_KEY_IMPORT_BASE]) {
			return YES;
		}
		if([key isEqualToString:ATTRIBUTE_KEY_KEEPLAYOUTS]) {
			return ![args[@"resetLayouts"] boolValue];
		}		
	}
	
	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_UPDATE_LOCALIZED]) {
		if([key isEqualToString:ATTRIBUTE_KEY_IMPORT_LOCALIZED]) {
			return YES;
		}
		if([key isEqualToString:ATTRIBUTE_KEY_VERSIONIDENTICAL]) {
			return [args[@"versionIdentical"] boolValue];
		}
		if([key isEqualToString:ATTRIBUTE_KEY_IMPORTLAYOUTS]) {
			return [args[@"importLayouts"] boolValue];
		}
		if([key isEqualToString:ATTRIBUTE_KEY_COPYONLYIFEXISTS]) {
			return ![args[@"createNonExistingFiles"] boolValue];
		}
	}	

	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_EXPORT]) {
		if([key isEqualToString:ATTRIBUTE_EXPORT_COMPRESS]) {
			return [args[@"compress"] boolValue];
		}
		if([key isEqualToString:ATTRIBUTE_EXPORT_COMPACTNIB]) {
			return [args[@"compactNib"] boolValue];
		}
		if([key isEqualToString:ATTRIBUTE_EXPORT_LOCALIZATION]) {
			return [args[@"exportLocalization"] boolValue];
		}
	}
	
	return NO;
}

- (int)scriptIntValueForKey:(NSString*)key command:(NSScriptCommand*)cmd
{
	NSDictionary *args = [cmd evaluatedArguments];
	
	if([[[cmd commandDescription] commandName] isEqualToString:SCRIPT_OPERATION_UPDATE_LOCALIZED]) {
		if([key isEqualToString:ATTRIBUTE_KEY_CONFLICTINGFILESDECISION]) {
			if(args[@"resolveConflictWithBundle"]) {
				return RESOLVE_USE_IMPORTED_FILE;
			}
			if(args[@"resolveConflictWithProject"]) {
				return RESOLVE_USE_PROJET_FILE;
			}
		}
	}	
	
	return NO;
}

- (void)scriptOperationCompleted:(NSString*)op
{
	[[ASManager shared] endAsyncCommand];	
}

@end

