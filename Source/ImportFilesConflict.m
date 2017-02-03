//
//  ImportFilesConflict.m
//  iLocalize3
//
//  Created by Jean on 07.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportFilesConflict.h"
#import "ProjectModel.h"
#import "FileTool.h"
#import "Constants.h"

@interface ImportFilesConflict (PrivateMethods)
- (unsigned)resolveConflictBetweenProjectFile:(NSString*)projectFile andImportedFile:(NSString*)importedFile provider:(id<ProjectProvider>)provider;
@end

@implementation ImportFilesConflict

// This value is set by the unit test to return avoid using the GUI when invoked during operations
static unsigned overrideValue = -1;
static unsigned applyToAllResult = RESOLVE_USE_NONE;

+ (void)reset
{
    applyToAllResult = RESOLVE_USE_NONE;
}

+ (void)setOverrideValue:(unsigned)value
{
    overrideValue = value;
}

+ (unsigned)resolveConflictBetweenProjectFile:(NSString*)projectFile andImportedFile:(NSString*)importedFile provider:(id<ProjectProvider>)provider
{
    if(overrideValue == -1) {
        ImportFilesConflict *dialog = [[ImportFilesConflict alloc] init];
        unsigned result = [dialog resolveConflictBetweenProjectFile:projectFile andImportedFile:importedFile provider:provider];
        return result;        
    } else {
        return overrideValue;
    }
}

- (id)init
{
    if(self = [super initWithWindowNibName:@"ImportFilesConflict"]) {
        mProjectFile = NULL;
        mImportedFile = NULL;
        [self window];
    }
    return self;
}


- (void)prepare
{
    [self useImportedFile:self];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    [mProjectFileNameField setStringValue:[mProjectFile lastPathComponent]];
    [mProjectFilePathField setStringValue:mProjectFile];
    [mProjectFileCreationDateField setStringValue:[dateFormatter stringForObjectValue:[mProjectFile pathCreationDate]]];
    [mProjectFileModificationDateField setStringValue:[dateFormatter stringForObjectValue:[mProjectFile pathModificationDate]]];

    [mImportedFileNameField setStringValue:[mImportedFile lastPathComponent]];
    [mImportedFilePathField setStringValue:mImportedFile];
    [mImportedFileCreationDateField setStringValue:[dateFormatter stringForObjectValue:[mImportedFile pathCreationDate]]];
    [mImportedFileModificationDateField setStringValue:[dateFormatter stringForObjectValue:[mImportedFile pathModificationDate]]];
}

- (unsigned)resolveConflictBetweenProjectFile:(NSString*)projectFile andImportedFile:(NSString*)importedFile provider:(id<ProjectProvider>)provider
{
    if(provider) {
        int decision = [provider decisionForConflictingRelativeFile:[[provider projectModel] relativePathFromAbsoluteProjectPath:projectFile]];
        if(decision != RESOLVE_USE_NONE)
            return decision;
    }
    
    if(applyToAllResult != RESOLVE_USE_NONE)
        return applyToAllResult;
    
    if(![importedFile isPathExisting])
        return RESOLVE_USE_PROJET_FILE;

    if(![projectFile isPathExisting])
        return RESOLVE_USE_PROJET_FILE;

    if([projectFile isPathContentEqualsToPath:importedFile]) {
        return RESOLVE_USE_PROJET_FILE;        
    }
    
    mProjectFile = projectFile;

    mImportedFile = importedFile;

    [self prepare];
    
    [NSApp runModalForWindow:[self window]];
    unsigned result = RESOLVE_USE_NONE;
    if([mUseProjectFileButton state] == NSOnState)
        result = RESOLVE_USE_PROJET_FILE;
    else
        result = RESOLVE_USE_IMPORTED_FILE;
    
    if([mApplyToAllButton state] == NSOnState)
        applyToAllResult = result;
    
    return result;
}

- (IBAction)openProjectFile:(id)sender
{
    [FileTool openFile:mProjectFile];
}

- (IBAction)revealProjectFile:(id)sender
{
    [FileTool revealFile:mProjectFile];
}

- (IBAction)useProjectFile:(id)sender
{
    [mUseProjectFileButton setState:NSOnState];
    [mUseImportedFileButton setState:NSOffState];
}

- (IBAction)openImportedFile:(id)sender
{
    [FileTool openFile:mImportedFile];
}

- (IBAction)revealImportedFile:(id)sender
{
    [FileTool revealFile:mImportedFile];
}

- (IBAction)useImportedFile:(id)sender
{
    [mUseProjectFileButton setState:NSOffState];
    [mUseImportedFileButton setState:NSOnState];
}

- (IBAction)continue:(id)sender
{
    [NSApp stopModal];
    [[self window] orderOut:self];
}

@end
