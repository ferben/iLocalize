//
//  ProjectExportSettings.m
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ExportProjectSettings.h"
#import <RegexKitLite.h>

@implementation ExportProjectSettings

@synthesize paths;
@synthesize languages;
@synthesize exportLanguageFoldersOnly;
@synthesize exportAsFolder;
@synthesize compactNib;
@synthesize upgradeNib;
@synthesize compress;
@synthesize nameIncludesBuildNumber;
@synthesize nameIncludesLanguages;
@synthesize email;
@synthesize emailProgram;
@synthesize emailSubject;
@synthesize emailMessage;
@synthesize destFolder;

@synthesize mergeFiles;
@synthesize filesToCopy;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.emailProgram = @"Mail";
	}
	return self;
}

/**
 Returns a suffix composed of all the languages:
 fr_en_de
 */
- (NSString*)exportLocalizationSuffix
{
	NSMutableString *suffix = [NSMutableString string];
	for(NSString *language in self.languages) {
		if([suffix length] > 0)
			[suffix appendString:@" "];
		[suffix appendString:language];
	}
	return suffix;
}

- (NSString*)targetName
{
	// Example: ilocalize
	NSString *targetName = [self.provider applicationExecutableName]; 
	
	// Example: app
	NSString *targetExtension = [[self.provider sourceApplicationPath] pathExtension];
	
	// Build the name using the user settings
	NSMutableString *name = [NSMutableString stringWithString:targetName];
	if(self.nameIncludesBuildNumber) {
		NSString *version = [self.provider projectAppVersionString];
		if(![version isEqualToString:@"n/a"]) {
			[name appendFormat:@" %@", version];
		}
	}
	if(self.nameIncludesLanguages) {
		NSString *nameLanguages = [self exportLocalizationSuffix];
		[name appendFormat:@" (%@)", nameLanguages];		
	}
	
    if([targetExtension length] > 0) {
        if(self.exportAsFolder) {
            [name appendFormat:@"_%@", targetExtension];
        } else {
            [name appendFormat:@".%@", targetExtension];
        }        
    }
	
//	if(self.exportAsFolder) {
//		// Replaces all the "." in the name by "_" to avoid the Finder to think it is a package.
//		[name replaceCharactersInRange:NSMakeRange(0, name.length)
//							withString:[name stringByReplacingOccurrencesOfRegex:@"\\." withString:@"_"]];
//	}

	return name;
}

- (NSString*)targetBundle
{	
	return [self.destFolder stringByAppendingPathComponent:[self targetName]];	
}

- (NSString*)compressedTargetBundle
{
	NSString *compressedTargetBundle;
	if(self.compress) {
		compressedTargetBundle = [[[self targetBundle] stringByDeletingPathExtension] stringByAppendingPathExtension:@"zip"];
	} else {
		compressedTargetBundle = [self targetBundle];
	}
	return compressedTargetBundle;	
}

- (NSString*)emailSubject {
    return [NSString stringWithFormat:NSLocalizedString(@"Exported project “%@”", nil), self.targetName];
}

+ (NSSet*)keyPathsForValuesAffectingTargetName
{
	return [NSSet setWithObjects:@"nameIncludesBuildNumber", @"nameIncludesLanguages", @"exportAsFolder", nil ];
}

// used for persistence
- (void)setData:(NSDictionary*)data
{
	if(data == nil) return;
	
	self.paths = data[@"paths"];
	self.languages = data[@"languages"];
	self.exportLanguageFoldersOnly = [data booleanForKey:@"exportLanguageFoldersOnly"];
	self.exportAsFolder = [data booleanForKey:@"exportAsFolder"];
	self.compactNib = [data booleanForKey:@"compactNib"];
	self.upgradeNib = [data booleanForKey:@"upgradeNib"];
	self.compress = [data booleanForKey:@"compress"];
	self.nameIncludesBuildNumber = [data booleanForKey:@"nameIncludesBuildNumber"];
	self.nameIncludesLanguages = [data booleanForKey:@"nameIncludesLanguages"];
	self.email = [data booleanForKey:@"email"];
	self.emailProgram = data[@"emailProgram"];
	self.emailToAddress = data[@"emailToAddress"];
	self.emailMessage = data[@"emailMessage"];
	self.destFolder = data[@"destFolder"];
}

- (NSDictionary*)data
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObjectOrNil:paths forKey:@"paths"];
	[dic setObjectOrNil:languages forKey:@"languages"];
	[dic setBoolean:exportLanguageFoldersOnly forKey:@"exportLanguageFoldersOnly"];
	[dic setBoolean:exportAsFolder forKey:@"exportAsFolder"];
	[dic setBoolean:compactNib forKey:@"compactNib"];
	[dic setBoolean:upgradeNib forKey:@"upgradeNib"];
	[dic setBoolean:compress forKey:@"compress"];
	[dic setBoolean:nameIncludesBuildNumber forKey:@"nameIncludesBuildNumber"];
	[dic setBoolean:nameIncludesLanguages forKey:@"nameIncludesLanguages"];
	[dic setBoolean:email forKey:@"email"];
	[dic setObjectOrNil:self.emailToAddress forKey:@"emailToAddress"];
	[dic setObjectOrNil:emailProgram forKey:@"emailProgram"];
	[dic setObjectOrNil:emailMessage forKey:@"emailMessage"];
	[dic setObjectOrNil:destFolder forKey:@"destFolder"];
	return dic;
}

@end
