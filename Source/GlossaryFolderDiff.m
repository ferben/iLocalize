//
//  GlossaryFolderDiff.m
//  iLocalize
//
//  Created by Jean Bovet on 4/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryFolderDiff.h"
#import "GlossaryFolder.h"
#import "Glossary.h"
#import "GlossaryNotification.h"

#import "FileTool.h"
#import "AZOrderedDictionary.h"

@implementation GlossaryFolderDiff

@synthesize allowedExtensions;

+ (GlossaryFolderDiff*)diffWithAllowedExtensions:(NSArray*)allowedExtensions
{
	GlossaryFolderDiff *diff = [[GlossaryFolderDiff alloc] init];
	diff.allowedExtensions = allowedExtensions;
	return diff;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		diskGlossaries = [[NSMutableDictionary alloc] init];
		newFiles = [[NSMutableArray alloc] init];
		modifiedFiles = [[NSMutableArray alloc] init];
		unmodifiedFiles = [[NSMutableArray alloc] init];
		deletedFiles = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSDictionary*)glossariesInFolder:(GlossaryFolder*)folder
{
	NSMutableDictionary *glossaries = [NSMutableDictionary dictionary];
	if(![folder.path isPathExisting]) {
		return glossaries;
	}
	NSFileManager *fm = [[NSFileManager alloc] init];
	
	NSDirectoryEnumerator *de = [fm enumeratorAtURL:[NSURL fileURLWithPath:folder.path] 
						 includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentModificationDateKey]
											options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants
									   errorHandler:^(NSURL *url, NSError *error) {
										   ERROR(@"Error reading %@: %@", url, error);
										   return YES;
									   }];
	
	for(NSURL *url in de) {
		NSError *error = nil;
		
		// Get the directory attribute
		NSNumber *isDirectory;
        if(![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
			ERROR(@"Error getting directory attribute from %@", url);
			continue;
		}
		
		// Get the modification date attribute
		NSDate *modificationDate;
        if(![url getResourceValue:&modificationDate forKey:NSURLContentModificationDateKey error:&error]) {
			ERROR(@"Error getting modificationdate attribute from %@", url);
			continue;
		}
		
		// Do not go more than 3 level deep
		if([isDirectory intValue] == 1 && [de level] >= 3) {
			[de skipDescendants];
			continue;
		}
		
		// Skip file with unknown extension
		if(![allowedExtensions containsObject:[[url path] pathExtension]]) {
			continue;
		}
		
		NSString *file = [url path];
		NSString *targetFile = nil;
		if([file isPathAlias]) {
			targetFile = [FileTool resolvedPathOfAliasPath:file];
		}
		if(!targetFile) {
			targetFile = file;			
		}
		
		// Create the glossary
		Glossary *glossary = [[Glossary alloc] init];
		glossary.folder = folder;
		glossary.file = file;
		glossary.targetFile = targetFile;
		if([file isEqual:targetFile]) {
			glossary.modificationDate = modificationDate;			
		} else {
			glossary.modificationDate = [targetFile pathModificationDate];			
		}
		glossaries[targetFile] = glossary;
	}
	
	return glossaries;
}

- (NSUInteger)analyzeFolder:(GlossaryFolder*)folder
{
	// Do the diff between what's on the disk and what's in memory
	[diskGlossaries removeAllObjects];
	[diskGlossaries addEntriesFromDictionary:[self glossariesInFolder:folder]];	
		
	[newFiles removeAllObjects];
	[modifiedFiles removeAllObjects];
	[unmodifiedFiles removeAllObjects];
	[deletedFiles removeAllObjects];
		
	for(NSString *diskFile in [diskGlossaries allKeys]) {
		Glossary *memoryGlossary = [folder.glossaryMap objectForKey:diskFile];
		if(memoryGlossary) {
			// Glossary already exists in memory.
			// Check if the modification date on the disk is newer.
			NSDate *memoryModificationDate = memoryGlossary.modificationDate;
			NSDate *diskModificationDate = [diskGlossaries[diskFile] modificationDate];
			if([diskModificationDate compare:memoryModificationDate] == NSOrderedDescending) {
				// Disk glossary is newer. Reloads the glossary.
				[modifiedFiles addObject:diskFile];
			} else {
				[unmodifiedFiles addObject:diskFile];
			}
		} else {
			// New glossary (it exists on the disk but not in memory).
			[newFiles addObject:diskFile];
		}
	}
	
	NSMutableSet *deletedFilesSet = [NSMutableSet setWithArray:[folder.glossaryMap allKeys]];
	[deletedFilesSet minusSet:[NSSet setWithArray:newFiles]];
	[deletedFilesSet minusSet:[NSSet setWithArray:modifiedFiles]];
	[deletedFilesSet minusSet:[NSSet setWithArray:unmodifiedFiles]];	
	[deletedFiles addObjectsFromArray:[deletedFilesSet allObjects]];
	
	return newFiles.count+modifiedFiles.count;
}

- (GlossaryNotification*)applyToFolder:(GlossaryFolder*)folder callback:(CancellableCallbackBlock)callback
{
	// Apply the diff to the in memory representation of the folder
	AZOrderedDictionary *newMemoryGlossaries = [[AZOrderedDictionary alloc] init];
	
    __block BOOL cancelled = NO;
    
    // Note: don't run in concurrent mode because the NSXMLDocument is not thread safe
    // and this can lead to issue reading a glossary
	[newFiles enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *file = obj;
		Glossary *g = diskGlossaries[file];
		[g loadProperties];
		@synchronized(newMemoryGlossaries) {
			[newMemoryGlossaries setObject:g forKey:file];			
		}
		if(callback && !callback()) {
            cancelled = YES;
            *stop = YES;
        }
	}];

    if(cancelled) return nil;
    
	[modifiedFiles enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *file = obj;
		// Update the modification date and the target file of the modified glossary.
		Glossary *g = [folder.glossaryMap objectForKey:file];
		Glossary *diskGlossary = diskGlossaries[file];
		g.modificationDate = diskGlossary.modificationDate;
		g.targetFile = diskGlossary.targetFile;
		[g markContentToReload];	
		[g loadProperties];
		@synchronized(newMemoryGlossaries) {
			[newMemoryGlossaries setObject:g forKey:file];			
		}
		if(callback && !callback()) {
            cancelled = YES;
            *stop = YES;
        }
	}];

    if(cancelled) return nil;

	for(NSString *file in unmodifiedFiles) {
		[newMemoryGlossaries setObject:[folder.glossaryMap objectForKey:file] forKey:file];
	}
	
	[newMemoryGlossaries sortKeysUsingComparator:(NSComparator)^(id obj1, id obj2) {
		return [obj1 compare:obj2]; 
	}];
	
	folder.glossaryMap = newMemoryGlossaries;
	
	if(newFiles.count > 0 || modifiedFiles.count > 0 || deletedFiles.count > 0) {
		GlossaryNotification *notif = [GlossaryNotification notificationWithAction:INDEX_CHANGED];
		notif.listOfNewFiles = newFiles;
		notif.modifiedFiles = modifiedFiles;
		notif.deletedFiles = deletedFiles;
		notif.folder = folder;
		notif.source = self;
		return notif;
	} else {
		return nil;
	}	
}

@end
