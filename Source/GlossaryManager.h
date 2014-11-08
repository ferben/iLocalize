//
//  ILGlossaryManager.h
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class GlossaryFolder;
@class Glossary;
@class GlossaryNotification;

/**
 Manager of all the glossary folders and glossaries.
 */
@interface GlossaryManager : NSObject {
	// Array of IGlossaryFolder
	NSMutableArray *folders;
	
	// The queue used to refresh the glossary asynchronously
	NSOperationQueue *refreshQueue;
	
	// Flag indicating if the background processing is active or not
	BOOL processing;	
}

@property BOOL processing;

/**
 Returns the shared instance.
 */
+ (GlossaryManager*)sharedInstance;

/**
 Adds a glossary folder.
 */
- (void)addFolder:(GlossaryFolder*)folder;

// Same but the immediately flag decide if the reloading takes place immediately (e.g. for unit tests
// or not (production).
- (void)addFolder:(GlossaryFolder*)folder immediately:(BOOL)immediately;

/**
 Removes a glossary folder.
 */
- (void)removeFolder:(GlossaryFolder*)folder;

/**
 Returns an array of global folders (that is, not bound to a specific project).
 */
- (NSArray*)globalFolders;

/**
 Returns an array of folders for a given project.
 */
- (NSArray*)foldersForProject:(id<ProjectProvider>)project;

/**
 Returns an array of all the global folders and the folders for the particular project.
 */
- (NSArray*)globalFoldersAndLocalFoldersForProject:(id<ProjectProvider>)provider;

/**
 Reloads the content of all the folders immediately or in the background.
 */
- (void)reload:(BOOL)immediately;

/**
 Reloads the content of all the folders in the background.
 */
- (void)reload;

/**
 Returns YES if the specified file is contained in one of the glossary folders.
 */
- (BOOL)isGlossaryFileIndexed:(NSString*)file;

/**
 Notifies that something happened with a glossary or group of glossaries.
 @param notif This parameter contains the details of the changes
 */
- (void)notifyGlossaryChanged:(GlossaryNotification*)notif;

/**
 Notifies when the background indexing starts or stops.
 */
- (void)notifyGlossaryProcessingChanged:(GlossaryNotification*)notif;

/**
 Returns an (ordered) array of all the opened project documents.
 */
+ (NSArray*)orderedProjectDocuments;

// Persistent data
- (void)setPersistentData:(NSArray*)data;
- (NSArray*)persistentData;

@end
