//
//  ImportConflictPreviewWC.m
//  iLocalize3
//
//  Created by Jean on 26.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportLocalizedResolveConflictsOVC.h"
#import "ProjectModel.h"
#import "FileTool.h"
#import "Constants.h"
#import "FileConflictItem.h"
#import "FileConflictDecision.h"

@implementation ImportLocalizedResolveConflictsOVC

@synthesize fileConflictItems;

- (id)init
{
	if(self = [super initWithNibName:@"ImportConflictPreview"]) {
	}
	return self;
}


- (NSArray*)conflictingFilesDecision
{
    NSMutableArray *decision = [NSMutableArray array];
    
    NSEnumerator *enumerator = [[mPreviewController content] objectEnumerator];
    NSDictionary *dic;
    while(dic = [enumerator nextObject]) {
		FileConflictDecision *d = [[FileConflictDecision alloc] init];
		d.decision = [dic[@"useSource"] boolValue]?RESOLVE_USE_IMPORTED_FILE:RESOLVE_USE_PROJET_FILE;
		d.file = dic[@"file"];
        [decision addObject:d];
    }
    return decision;
}

- (NSString*)nextButtonTitle
{
	return NSLocalizedString(@"Continue", nil);
}

- (void)willShow
{
	[sourcePathControl setDoubleAction:@selector(doubleClickOnPath:)];
	[sourcePathControl setTarget:self];
	[targetPathControl setDoubleAction:@selector(doubleClickOnPath:)];
	[targetPathControl setTarget:self];
	
    [mTableView setAction:@selector(clickOnTableView:)];
	[mTableView setDoubleAction:@selector(doubleClickOnTableView:)];	
    
    [mPreviewController removeObjects:[mPreviewController content]];
    
    for(FileConflictItem *item in self.fileConflictItems) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"useSource"] = @YES;
        dic[@"file"] = [[self.projectProvider projectModel] relativePathFromAbsoluteProjectPath:item.project];
                
        dic[@"source"] = item.source;
        dic[@"sourceURL"] = [NSURL fileURLWithPath:item.source];
        dic[@"sourceExists"] = @([item.source isPathExisting]);
        if([item.source isPathExisting]) {
            dic[@"sourceCreationDate"] = [item.source pathCreationDate];
            dic[@"sourceModificationDate"] = [item.source pathModificationDate];            
        } else {
            dic[@"sourceCreationDate"] = @"";
            dic[@"sourceModificationDate"] = @"";                        
        }
        
        dic[@"project"] = item.project;
        dic[@"projectURL"] = [NSURL fileURLWithPath:item.project];
        dic[@"projectExists"] = @([item.project isPathExisting]);
        if([item.project isPathExisting]) {
            dic[@"projectCreationDate"] = [item.project pathCreationDate];
            dic[@"projectModificationDate"] = [item.project pathModificationDate];            
        } else {
            dic[@"projectCreationDate"] = @"";
            dic[@"projectModificationDate"] = @"";                        
        }

        [mPreviewController addObject:dic];
    }
    [mPreviewController rearrangeObjects];        
}

- (void)willContinue
{
	[[self projectProvider] setConflictingFilesDecision:[self conflictingFilesDecision]];
}

- (void)doubleClickOnPath:(id)sender
{
	NSPathControl *pc = sender;
	NSURL *url = [[pc clickedPathComponentCell] URL];
	if(url) {
		[FileTool revealFile:[url path]];		
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if([[aTableColumn identifier] isEqualToString:@"file"]) {
		NSString *path = [mPreviewController arrangedObjects][rowIndex][@"source"];
		[aCell setImage:[[NSWorkspace sharedWorkspace] iconForFile:path]];		
	}
}

- (NSString*)sourceFile
{
    return [[mPreviewController selectedObjects] firstObject][@"source"];
}

- (NSString*)projectFile
{
    return [[mPreviewController selectedObjects] firstObject][@"project"];
}

- (IBAction)allSource:(id)sender
{
    NSEnumerator *enumerator = [[mPreviewController content] objectEnumerator];
    NSMutableDictionary *dic;
    while(dic = [enumerator nextObject]) {
        dic[@"useSource"] = @YES;
    }
}

- (IBAction)allProject:(id)sender
{
    NSEnumerator *enumerator = [[mPreviewController content] objectEnumerator];
    NSMutableDictionary *dic;
    while(dic = [enumerator nextObject]) {
        dic[@"useSource"] = @NO;
    }    
}

- (IBAction)openSource:(id)sender
{
	[FileTool openFile:[self sourceFile]];    
}

- (IBAction)revealSource:(id)sender
{
	[FileTool revealFile:[self sourceFile]];
}

- (IBAction)openProject:(id)sender
{
    [FileTool openFile:[self projectFile]];
}

- (IBAction)revealProject:(id)sender
{
	[FileTool revealFile:[self projectFile]];
}

@end
