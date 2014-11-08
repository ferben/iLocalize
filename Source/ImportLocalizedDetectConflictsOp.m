//
//  ImportLocalizedDetectConflictsOp.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportLocalizedDetectConflictsOp.h"
#import "FMEngine.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "FileTool.h"
#import "FileConflictItem.h"

@implementation ImportLocalizedDetectConflictsOp

@synthesize fileConflictItems;
@synthesize languages;
@synthesize localizedBundle;

- (id) init
{
	self = [super init];
	if (self != nil) {
		conflictingFileItems = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSArray*)conflictingFileItems
{
	return conflictingFileItems;
}

/**
 Expecting an array of FileConflictItem items.
 */
- (void)resolveAnyConflictingFiles:(NSArray*)files
{
    [conflictingFileItems removeAllObjects];
    for(FileConflictItem *item in files) {
        // Skip non-existing source file because it doesn't make sense to resolve
        // a conflict if the source file doesn't exist ;-)
        if(![item.source isPathExisting])
            continue;
		
        if(![[[self projectProvider] fileModuleEngineForFile:item.source] supportsContentTranslation]) {
			// Files is conflicting because we cannot merge them.
			// Check if there are the same: in that case, don't bother display them
			if(![item.source isPathContentEqualsToPath:item.project]) {				
				[conflictingFileItems addObject:item];
			}
		}
    }
	
    [[self projectProvider] resetConflictingFilesDecision];
}

- (void)execute
{
	// resolve conflicts if identical is false:
    // - use actual projects file to scan for any conflicts.
    // - use also the new languages in the source for any conflicts because new languages are also added during the update process            
    
	// Either the list of file conflict items is specified or we need to build it.
	if(self.fileConflictItems) {
		[self resolveAnyConflictingFiles:self.fileConflictItems];		
	} else {
		NSMutableArray *fileItems = [NSMutableArray array];
		
		for(NSString *language in self.languages) {
			LanguageController *lc = [[self projectController] languageControllerForLanguage:language];
			if(lc == nil) {
				// The language doesn't exist yet. Use the base language and translate the source path.
				lc = [[self projectController] baseLanguageController];
			}
			
			for(FileController *fc in [lc fileControllers]) {
				NSString *source = [self.localizedBundle stringByAppendingPathComponent:[fc relativeFilePath]];
				NSString *project = [fc absoluteFilePath];
				
				source = [FileTool resolveEquivalentFile:[FileTool translatePath:source toLanguage:language]];
				project = [FileTool resolveEquivalentFile:[FileTool translatePath:project toLanguage:language]];
				
				FileConflictItem *item = [[FileConflictItem alloc] init];
				item.source = source;
				item.project = project;
				
				[fileItems addObject:item];            
			}
		}
		
		[self resolveAnyConflictingFiles:fileItems];				
	}
}

- (BOOL)cancellable
{
	return YES;
}

@end
