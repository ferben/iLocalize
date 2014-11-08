//
//  ILGlossaryManager.m
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryManager.h"
#import "Glossary.h"
#import "GlossaryFolder.h"
#import "GlossaryManagerOperation.h"
#import "GlossaryNotification.h"
#import "GlossaryFolderDiff.h"

#import "SEIManager.h"
#import "ProjectDocument.h"
#import "ProjectModel.h"
#import "AZOrderedDictionary.h"

@implementation GlossaryManager

@synthesize processing;

static GlossaryManager *instance = nil;

+ (GlossaryManager*)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[GlossaryManager alloc] init];
		}
	}
	return instance;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		folders = [[NSMutableArray alloc] init];
				
		refreshQueue = [[NSOperationQueue alloc] init];
		[refreshQueue setMaxConcurrentOperationCount:1]; // serial processing

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(glossaryDidChange:)
													 name:GlossaryDidChange
												   object:nil];	
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(projectProviderDidOpen:)
													 name:ILNotificationProjectProviderDidOpen
												   object:nil];	
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(projectProviderWillClose:)
													 name:ILNotificationProjectProviderWillClose
												   object:nil];				
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[refreshQueue cancelAllOperations];
	[refreshQueue waitUntilAllOperationsAreFinished];
	
}

- (void)projectProviderDidOpen:(NSNotification*)notif
{
	id<ProjectProvider> provider = [notif object];
	[self addFolder:[GlossaryFolder folderForProject:provider name:NSLocalizedString(@"Local", @"Local Glossary Name")]];	
}

- (void)projectProviderWillClose:(NSNotification*)notif
{
	id<ProjectProvider> provider = [notif object];
	
	NSMutableArray *foldersToRemove = [NSMutableArray array];
	for(GlossaryFolder *folder in folders) {
		if([folder isBoundToProject:provider]) {
			[foldersToRemove addObject:folder];
		}
	}
	
	@synchronized(folders) {
		[folders removeObjectsInArray:foldersToRemove];
	}
}

- (void)glossaryDidChange:(NSNotification*)notif
{
	GlossaryNotification *gn = [notif object];
	if(gn.action == GLOSSARY_SAVED) {
		// This is emitted when a glossary is saved on the disk (it doesn't come from this class).
		[self reload];
	}
}

- (void)notifyFolderChanged:(GlossaryFolder*)folder added:(BOOL)added
{
	GlossaryNotification *notif = [GlossaryNotification notificationWithAction:added?FOLDER_ADDED:FOLDER_DELETED];
	notif.folder = folder;
	notif.source = self;
	[self notifyGlossaryChanged:notif];	
}

- (void)addFolder:(GlossaryFolder*)folder
{
	[self addFolder:folder immediately:NO];
}

- (void)addFolder:(GlossaryFolder*)folder immediately:(BOOL)immediately
{
	@synchronized(folders) {
		if(![folders containsObject:folder]) {
			[folders addObject:folder];
			[self notifyFolderChanged:folder added:YES];
			[self reload:immediately];
		}
	}
}

- (void)removeFolder:(GlossaryFolder*)folder
{
	@synchronized(folders) {
		[folders removeObject:folder];
		[self notifyFolderChanged:folder added:NO];
		[self reload];
	}
}

- (NSArray*)globalFolders
{
	NSMutableArray *global = [NSMutableArray array];
	@synchronized(folders) {
		for(GlossaryFolder *folder in folders) {
			if(!folder.boundToProject) {
				[global addObject:folder];
			}
		}
	}
	return global;
}

- (NSArray*)foldersForProject:(id<ProjectProvider>)project
{
	NSMutableArray *array = [NSMutableArray array];
	@synchronized(folders) {
		for(GlossaryFolder *folder in folders) {
			if([folder isBoundToProject:project]) {
				[array addObject:folder];
			}
		}		
	}
	return array;
}

- (NSArray*)globalFoldersAndLocalFoldersForProject:(id<ProjectProvider>)provider
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObjectsFromArray:[self foldersForProject:provider]];
	[array addObjectsFromArray:[self globalFolders]];
	return array;
}

- (void)reload:(BOOL)immediately
{
	GlossaryManagerOperation *op = [[GlossaryManagerOperation alloc] init];
	@synchronized(folders) {
		op.folders = [NSArray arrayWithArray:folders];
	}
	if(immediately) {
		[op main];		
	} else {
		// Cancel all queued operations as we just want the latest operation to run.
		[refreshQueue cancelAllOperations];
		// Add the operation for execution
		[refreshQueue addOperation:op];				
	}	
}

- (void)reload
{
	[self reload:NO];
}

- (BOOL)isGlossaryFileIndexed:(NSString*)file
{
	BOOL indexed = NO;
	@synchronized(folders) {
		for(GlossaryFolder *folder in folders) {
			if([folder.glossaryMap objectForKey:file]) {
				indexed = YES;
				goto end;
			} else {
				// Check each target file because the glossary might be in fact an alias
				for(Glossary *g in [folder glossaries]) {
					if([g.targetFile isEqual:file]) {
						indexed = YES;
						goto end;
					}
				}
			}
		}
	}
end:
	return indexed;
}

- (void)notifyGlossaryChanged:(GlossaryNotification*)notif
{
	if([[NSThread currentThread] isMainThread]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:GlossaryDidChange object:notif];		
	} else {
		[self performSelectorOnMainThread:@selector(notifyGlossaryChanged:) withObject:notif waitUntilDone:NO];	
	}
}		

- (void)notifyGlossaryProcessingChanged:(GlossaryNotification*)notif
{
	if([[NSThread currentThread] isMainThread]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:GlossaryProcessingDidChange object:notif];		
	} else {
		[self performSelectorOnMainThread:@selector(notifyGlossaryProcessingChanged:) withObject:notif waitUntilDone:NO];	
	}
}		

+ (NSArray*)orderedProjectDocuments
{
	NSMutableArray *array = [NSMutableArray array];

	for(NSDocument *doc in [NSApp orderedDocuments]) {
		if([doc isKindOfClass:[ProjectDocument class]]) {
			[array addObject:doc];			
		}
	}	
	return array;
}

#pragma mark Persistent Data

- (void)setPersistentData:(NSArray*)data
{
	if(data == nil)
		return;
	
	@synchronized(folders) {
		[folders removeAllObjects];
		for(id fdata in data) {
			GlossaryFolder *folder = [[GlossaryFolder alloc] init];
			[folder setPersistentData:fdata];
			if(![folders containsObject:folder]) {
				[folders addObject:folder];				
			}
		}
	}
	
	[self reload];
}

- (NSArray*)persistentData
{
	NSMutableArray *array = [NSMutableArray array];	
	@synchronized(folders) {
		for(GlossaryFolder *folder in folders) {
			[array addObject:[folder persistentData]];
		}		
	}
	return array;
}

@end
