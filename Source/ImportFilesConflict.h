//
//  ImportFilesConflict.h
//  iLocalize3
//
//  Created by Jean on 07.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#include "ProjectProvider.h"

@interface ImportFilesConflict : NSWindowController {
	IBOutlet NSTextField	*mProjectFileNameField;
	IBOutlet NSTextField	*mProjectFilePathField;
	IBOutlet NSTextField	*mProjectFileCreationDateField;
	IBOutlet NSTextField	*mProjectFileModificationDateField;

	IBOutlet NSTextField	*mImportedFileNameField;
	IBOutlet NSTextField	*mImportedFilePathField;
	IBOutlet NSTextField	*mImportedFileCreationDateField;
	IBOutlet NSTextField	*mImportedFileModificationDateField;
	
	IBOutlet NSButton		*mUseProjectFileButton;
	IBOutlet NSButton		*mUseImportedFileButton;
	IBOutlet NSButton		*mApplyToAllButton;
	
	NSString				*mProjectFile;
	NSString				*mImportedFile;
    
    id <ProjectProvider>    mProjectProvider;
}

+ (void)reset;
+ (void)setOverrideValue:(unsigned)value;

+ (unsigned)resolveConflictBetweenProjectFile:(NSString*)projectFile andImportedFile:(NSString*)importedFile provider:(id<ProjectProvider>)provider;

- (IBAction)openProjectFile:(id)sender;
- (IBAction)revealProjectFile:(id)sender;
- (IBAction)useProjectFile:(id)sender;

- (IBAction)openImportedFile:(id)sender;
- (IBAction)revealImportedFile:(id)sender;
- (IBAction)useImportedFile:(id)sender;

- (IBAction)continue:(id)sender;

@end
