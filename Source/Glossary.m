//
//  ILGlossary.m
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Glossary.h"
#import "GlossaryEntry.h"
#import "GlossaryFolder.h"
#import "GlossaryManager.h"
#import "GlossaryNotification.h"

#import "XMLImporter.h"
#import "XMLImporterElement.h"
#import "XMLExporter.h"

#import "SEIManager.h"
#import "SimpleFileController.h"
#import "SimpleStringController.h"

@interface Glossary (PrivateMethods)
- (void)ensureEntries;
@end

@implementation Glossary

@synthesize folder;
@synthesize file;
@synthesize targetFile;
@synthesize modificationDate;
@synthesize format;
@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize entryCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		entries = nil;
		mappedCaseInsensitiveEntries = nil;
		mappedEntries = nil;
	}
	return self;
}


- (NSString*)name
{
	return [self.file lastPathComponent];
}

- (NSString*)relativeFile
{
	NSString* rel = [self.file stringByRemovingPrefix:self.folder.path];
	return [rel hasPrefix:@"/"]?[rel stringByRemovingPrefix:@"/"]:rel;
}

- (XMLImporter*)importer
{
	NSError *error = nil;
	NSURL *fileURL = [NSURL fileURLWithPath:self.targetFile];
	XMLImporter *importer = [[SEIManager sharedInstance] importerForFile:fileURL error:&error];
	if(!importer) {
		if(error) {
			ERROR(@"Unable to prepare importer for glossary %@: %@", fileURL, error);
		}
		return nil;
	}
	
	if(![importer importDocument:fileURL error:&error]) {
		if(error) {
			ERROR(@"Unable to read glossary %@: %@", fileURL, error);
		}
		return nil;
	}
	
	format = importer.format;
	
	return importer;
}

- (void)addEntryWithSource:(NSString*)source translation:(NSString*)translation
{
	GlossaryEntry *entry = [[GlossaryEntry alloc] init];
	entry.source = source;
	entry.translation = translation;
	[self ensureEntries];
	@synchronized(self) {
		[entries addObject:entry];		
	}
}

- (void)addEntries:(NSArray*)otherEntries
{
	[self ensureEntries];
	@synchronized(self) {
		[entries addObjectsFromArray:otherEntries];
	}
}

- (void)replaceEntries:(NSArray*)otherEntries
{
	@synchronized(self) {
		for(GlossaryEntry *entry in entries) {
			for(GlossaryEntry *otherEntry in otherEntries) {
				if([entry.source isEqual:otherEntry.source]) {
					entry.translation = otherEntry.translation;
				}				
			}
		}
	}
}

- (void)updateEntries:(NSArray*)otherEntries
{
	[self ensureEntries];
	@synchronized(self) {
        NSMutableArray *remainingEntries = [NSMutableArray arrayWithArray:otherEntries];
		for(GlossaryEntry *entry in entries) {
			for(GlossaryEntry *otherEntry in otherEntries) {
				if([entry.source isEqual:otherEntry.source]) {
					entry.translation = otherEntry.translation;
                    [remainingEntries removeObject:otherEntry];
				}
			}
		}
        
        // Add entries not found in the glossary
        [entries addObjectsFromArray:remainingEntries];
	}
}

- (void)removeAllEntries
{
	@synchronized(self) {
		[entries removeAllObjects];
	}
}

- (BOOL)removeDuplicateEntries
{
	BOOL removed = NO;
	NSMutableDictionary *duplicates = [NSMutableDictionary dictionary];
	
	@synchronized(self) {
		int index;
		for(index = [entries count]-1; index >= 0; index--) {
			GlossaryEntry *entry = entries[index];
			NSMutableSet *targets = duplicates[entry.source];
			if(targets != nil) {
				if([targets containsObject:entry.translation]) {
					[entries removeObjectAtIndex:index];				
					removed = YES;
				} else {
					[targets addObject:entry.translation];
				}
			} else {
				NSString *source = entry.source;
				NSMutableSet *targets = duplicates[source];
				if(targets == nil) {
					targets = [NSMutableSet set];
					duplicates[source] = targets;
				}
				[targets addObject:entry.translation];
			}
		}			
	}
	
	return removed;
}

- (void)ensureEntries
{
	@synchronized(self) {
		if(!entries) {
			entries = [[NSMutableArray alloc] init];
		}		
	}	
}

- (void)internalLoadEntries:(XMLImporter*)importer
{
	[self ensureEntries];
	
	@synchronized(self) {
		[entries removeAllObjects];
	}
	
	for(XMLImporterElement *element in [importer allElements]) {
		[self addEntryWithSource:element.source translation:element.translation];
	}	
}

- (void)loadEntries
{	
	@synchronized(self) {
		XMLImporter *importer = [self importer];
		[self internalLoadEntries:importer];		
	}	
}

- (BOOL)entriesLoaded
{
	BOOL loaded;
	@synchronized(self) {
		loaded = entries != nil;
	}
	return loaded;
}

- (NSArray*)entries
{
	@synchronized(self) {
		if(!entries) {
			[self loadEntries];
		}
	}
	return [entries copy];
}

- (NSDictionary*)buildMappedEntries:(BOOL)caseInsensitive
{
	NSMutableDictionary *map = [NSMutableDictionary dictionary];
	@synchronized(self) {
		for(GlossaryEntry *entry in entries) {
            if (entry.translation.length > 0) {
                map[caseInsensitive?[entry.source lowercaseString]:entry.source] = entry.translation;                
            }
		}
	}
	return map;
}

- (NSDictionary*)mappedCaseInsensitiveEntries
{        
	@synchronized(self) {
		if(!mappedCaseInsensitiveEntries) {
			mappedCaseInsensitiveEntries = [[self buildMappedEntries:YES] mutableCopy];
		}
	}
	return mappedCaseInsensitiveEntries;
}

- (NSDictionary*)mappedEntries
{
	@synchronized(self) {
		if(!mappedEntries) {
			mappedEntries = [[self buildMappedEntries:NO] mutableCopy];
		}
	}
	return mappedEntries;
}

- (void)internalLoadProperties:(XMLImporter*)importer
{
	self.sourceLanguage = importer.sourceLanguage?:@"?";
	self.targetLanguage = importer.targetLanguage?:self.sourceLanguage;
	self.entryCount = [[importer allElements] count];	
}

- (void)loadProperties
{
	@synchronized(self) {
		XMLImporter *importer = [self importer];
		[self internalLoadProperties:importer];
	}
}

- (BOOL)loadContent
{
	BOOL success = NO;
	@synchronized(self) {
		XMLImporter *importer = [self importer];
		[self internalLoadProperties:importer];
		[self internalLoadEntries:importer];
		success = importer != nil;
	}
	return success;
}

- (void)markContentToReload
{
	@synchronized(self) {
		entries = nil;
		self.sourceLanguage = nil;
		self.targetLanguage = nil;
		self.entryCount = -1;
	}
}

- (BOOL)readOnly
{
	return [[SEIManager sharedInstance] exporterForFormat:self.format] == nil;
}

- (BOOL)writeToFile:(NSError**)error
{
	return [self exportToFile:self.targetFile referenceFile:self.file?:self.targetFile format:self.format error:error];
}

- (BOOL)exportToFile:(NSString*)inFile referenceFile:(NSString*)referenceFile format:(SEI_FORMAT)inFormat error:(NSError**)error
{
	XMLExporter *exporter = [[SEIManager sharedInstance] exporterForFormat:inFormat];
	exporter.sourceLanguage = self.sourceLanguage;
	exporter.targetLanguage = self.targetLanguage;
	exporter.errorCallback = ^(NSError *err) {
		if(*error) {
			*error = err;			
		}
	};
	
	SimpleFileController *fc = [[SimpleFileController alloc] init];
	fc.path = nil; // indicate that we don't want a file marker in the export if possible
	
	@synchronized(self) {
		int index = 0;
		for(GlossaryEntry *entry in entries) {
			SimpleStringController *sc = [[SimpleStringController alloc] init];
			sc.key = [NSString stringWithFormat:@"%d", index];
			sc.base = entry.source;
			sc.translation = entry.translation;
			[fc addString:sc];
			index++;
		}		
	}
	
	[exporter buildHeader];
	[exporter buildFile:fc];
	[exporter buildFooter];
	
	
	if([exporter.content writeToFile:inFile atomically:YES encoding:NSUTF8StringEncoding error:error]) {
		GlossaryNotification *gn = [GlossaryNotification notificationWithAction:GLOSSARY_SAVED];
		gn.source = self;
		gn.modifiedFiles = @[referenceFile];
		// Fire in the next event loop. This is necessary because when this method is called when a glossary document
		// is saved, it will first save the content of the glossary under a temporary file before swapping the file.
		// We need to return from this method for that to happen so the real glossary file is actually modified on the disk.
		[[GlossaryManager sharedInstance] performSelector:@selector(notifyGlossaryChanged:) withObject:gn afterDelay:0];
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isEqual:(id)anObject
{	
	if(![anObject isKindOfClass:[Glossary class]]) {
		return NO;
	}
	
	return [self.file isEqualToPath:[anObject file]];
}

- (NSUInteger)hash
{
	return [self.file hash];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ - %@ (f=%d, #entries=%ld)", [super description], self.file, self.format, self.entryCount];
}

#pragma mark Persistent Data

- (BOOL)setPersistentData:(NSDictionary*)data
{
	self.file = data[@"file"];
	self.targetFile = data[@"targetFile"];
	self.modificationDate = data[@"modificationDate"];		
	self.format = [data[@"format"] intValue];
	self.sourceLanguage = data[@"sourceLanguage"];
	self.targetLanguage = data[@"targetLanguage"];
	self.entryCount = [data[@"entryCount"] intValue];
	
	return self.file != nil && self.targetFile != nil && self.modificationDate != nil && self.format != NO_FORMAT &&
	self.sourceLanguage != nil && self.targetLanguage != nil && self.entryCount >= 0;
}

- (NSDictionary*)persistentData
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObjectOrNil:self.file forKey:@"file"];
	[dic setObjectOrNil:self.targetFile forKey:@"targetFile"];		
	[dic setObjectOrNil:self.modificationDate forKey:@"modificationDate"];
	dic[@"format"] = [NSNumber numberWithInt:self.format];
	[dic setObjectOrNil:self.sourceLanguage forKey:@"sourceLanguage"];
	[dic setObjectOrNil:self.targetLanguage forKey:@"targetLanguage"];
	dic[@"entryCount"] = [NSNumber numberWithInt:self.entryCount];
	return dic;
}

@end
