//
//  GlossaryNotIndexed.m
//  iLocalize3
//
//  Created by Jean on 09.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryNotIndexedWC.h"
#import "Glossary.h"
#import "GlossaryFolder.h"
#import "GlossaryManager.h"

#import "FileTool.h"

@implementation GlossaryNotIndexedWC

@synthesize didCloseCallback;
@synthesize targetPath;

- (id)init
{
	if(self = [super initWithWindowNibName:@"GlossaryNotIndexed"]) {
		mGlossaryPath = nil;
		mPaths = nil;
		mLocalPathExists = NO;
		[self window];
	}
	return self;
}


- (void)prepare
{
	id firstDocument = [[GlossaryManager orderedProjectDocuments] firstObject];
	mLocalPathExists = firstDocument != nil;
	
	mPaths = [[GlossaryManager sharedInstance] globalFoldersAndLocalFoldersForProject:firstDocument];
	
	[mPathPopUp removeAllItems];	
	for(GlossaryFolder *folder in mPaths) {
		[mPathPopUp addItemWithTitle:folder.name];
	}
}

- (void)displayView:(NSView*)view
{
	[[self window] setContentView:view resize:YES animate:NO];		//[[self window] isVisible]
}

- (void)setGlossaryPath:(NSString*)glossaryPath
{
	mGlossaryPath = glossaryPath;
	self.targetPath = mGlossaryPath;
}

- (void)showWithParent:(NSWindow*)parent
{
	[self prepare];
	[NSApp beginSheet:[self window] modalForWindow:parent modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)createAliasInPath:(GlossaryFolder*)folder
{
	NSString *source = mGlossaryPath;
	NSString *targetName = [[mGlossaryPath lastPathComponent] stringByDeletingPathExtension];
	NSString *targetExtension = [mGlossaryPath pathExtension];
	NSString *target = [folder.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ (alias).%@", targetName, targetExtension]];
	
	[[FileTool shared] preparePath:folder.path atomic:YES skipLastComponent:NO];
	
	int count = 0;
	while([target isPathExisting]) {
		count++;
		target = [folder.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %d (alias).%@", targetName, count, targetExtension]];
	}
		
	if(![FileTool createAliasOfFile:source toFile:target]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Cannot create the alias", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Cannot create the alias because an error has occurred.", nil)];	
		[alert runModal];
	} else {
		[[GlossaryManager sharedInstance] reload];
	}
}

- (void)moveInPath:(GlossaryFolder*)folder
{
	NSString *source = mGlossaryPath;
	NSString *target = [folder.path stringByAppendingPathComponent:[mGlossaryPath lastPathComponent]];
	
	[[FileTool shared] preparePath:folder.path atomic:YES skipLastComponent:NO];

	NSError *error = nil;
	if(![[NSFileManager defaultManager] moveItemAtPath:source toPath:target error:&error]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Cannot move the glossary", nil) 
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"An error has occurred when trying to move the glossary: %@", nil), error];
		[alert runModal];
	} else {
		self.targetPath = target;
		[[GlossaryManager sharedInstance] reload];
	}
}

- (void)addParentFolderToPreferences
{
	NSString *parent = [mGlossaryPath stringByDeletingLastPathComponent];	
	GlossaryFolder *folder = [GlossaryFolder folderForPath:parent name:[parent lastPathComponent]];
	folder.deletable = YES;
	[[GlossaryManager sharedInstance] addFolder:folder];
}

- (void)hide
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
	if(self.didCloseCallback) {
		self.didCloseCallback();		
	}
}

- (IBAction)cancel:(id)sender
{
	[self hide];
}

- (IBAction)ok:(id)sender
{
	switch([mActionPopUp indexOfSelectedItem]) {
		case 0:
			[self createAliasInPath:mPaths[[mPathPopUp indexOfSelectedItem]]];
			break;
		case 1:
			[self moveInPath:mPaths[[mPathPopUp indexOfSelectedItem]]];
			break;
		case 2:
			[self addParentFolderToPreferences];
			break;
	}
	[self hide];
}

@end
