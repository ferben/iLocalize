//
//  ResourceFileEngine.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ResourceFileEngine.h"

#import "LanguageTool.h"
#import "FileTool.h"

#import "Console.h"

@implementation ResourceFileEngine

+ (ResourceFileEngine*)engine
{
	return [[ResourceFileEngine alloc] init];
}

- (id)init
{
	if((self = [super init])) {
		mFiles = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)parseFiles:(NSArray*)files
{
	[mFiles removeAllObjects];

    for(NSString *file in files) {
		if([file isValidResourceFile]) {
			[mFiles addObject:file];			
		}
    }
}

- (void)parseFilesInPath:(NSString*)path
{
    NSMutableArray *files = [NSMutableArray array];
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	NSString *relativeFilePath;
	while((relativeFilePath = [enumerator nextObject])) {
		NSString *filePath = [path stringByAppendingPathComponent:relativeFilePath];

		if([FileTool isPathSVNFolder:filePath]) {
			[enumerator skipDescendents];
		}
		
		if([[FileTool shared] isFileAtomic:filePath]) {
			[enumerator skipDescendents];
		}
		
		if([[relativeFilePath lastPathComponent] isEqualToString:@"Resources Disabled"]) {
			[enumerator skipDescendents];			
		}

        [files addObject:filePath];
	}
    
    [self parseFiles:files];
}

- (NSArray*)files
{
	return mFiles;
}

- (NSArray*)filesOfLanguage:(NSString*)language
{
	NSMutableArray *array = [NSMutableArray array];
	
	@autoreleasepool {

		NSString *file;
		for(file in mFiles) {
			NSString *fileLanguage = [LanguageTool languageOfFile:file];
			if([fileLanguage isEquivalentToLanguage:language])
				[array addObject:file];
		}
		
		return array;
	}
}

- (void)removeFilesOfLanguages:(NSArray*)languages inPath:(NSString*)path
{
	@autoreleasepool {
		NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
		NSString *relativeFilePath;
		while(relativeFilePath = [enumerator nextObject]) {
			@autoreleasepool {
				NSString *file = [path stringByAppendingPathComponent:relativeFilePath];
				if([relativeFilePath isPathLanguageProject]) {
					NSString *language = [LanguageTool languageOfFile:relativeFilePath];
					NSEnumerator *le = [[LanguageTool equivalentLanguagesWithLanguage:language] objectEnumerator];
					NSString *l;
					while(l = [le nextObject]) {
						if([languages containsObject:l]) {
							NSString *languageFolder = [path stringByAppendingPathComponent:relativeFilePath];
							[[self console] addLog:[NSString stringWithFormat:@"Delete folder \"%@\"", languageFolder] class:[self class]];
							[languageFolder removePathFromDisk];
						}				
					}
					if([file isPathDirectory]) {
						[enumerator skipDescendents];				
					}
				} else if([[FileTool shared] isFileAtomic:file]) {
					[enumerator skipDescendents];			
				}
			}
		}	
	}
}

@end
