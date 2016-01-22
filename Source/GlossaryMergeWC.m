//
//  GlossaryMergeWC.m
//  iLocalize3
//
//  Created by Jean on 26.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryMergeWC.h"
#import "Glossary.h"

#import "GlossaryWC.h"
#import "GlossaryDocument.h"

#import "GlossaryManager.h"

@implementation GlossaryMergeWC

- (id)init
{
    if((self = [super initWithWindowNibName:@"GlossaryMerge"])) {
        [self window];
    }
    return self;
}

- (void)setGlossaries:(NSArray*)glossaries
{
    [mMergeController removeObjects:[mMergeController content]];
    
    NSMutableArray *mergeTargetGlossaries = [NSMutableArray array];    
    for(Glossary *g in glossaries) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		dic[@"glossary"] = g;
		dic[@"selected"] = @YES;
		dic[@"name"] = [g relativeFile];
		[mMergeController addObject:dic];
		
		// Can only merge to a glossary that can be written to the disk!
		if(![g readOnly]) {
			[mergeTargetGlossaries addObject:g];	
		}
    }

    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:NSLocalizedString(@"< New >", @"Glossary New Menu Item") action:nil keyEquivalent:@""];
	
	if (mergeTargetGlossaries.count > 0) {
		[menu addItem:[NSMenuItem separatorItem]];
	}
    
	NSMenuItem *item;
		
	for(Glossary *g in mergeTargetGlossaries) {
		item = [[NSMenuItem alloc] initWithTitle:g.file action:nil keyEquivalent:@""];
        [item setRepresentedObject:g];
		[menu addItem:item];
	}
    
    [mMergeDestPopUp setMenu:menu];
}

- (void)performMerge
{
	Glossary *mergedGlossary = [[Glossary alloc] init];

    for(NSDictionary *dic in [mMergeController content]) {
        if([dic[@"selected"] boolValue]) {
            Glossary *g = dic[@"glossary"];
			if(g.sourceLanguage && g.targetLanguage && [g entryCount] > 0) {
				mergedGlossary.sourceLanguage = g.sourceLanguage;
				mergedGlossary.targetLanguage = g.targetLanguage;
				[mergedGlossary addEntries:g.entries];
			}
        }
    }
    
	// Optionally remove duplicate entries
	if([mRemoveDuplicateEntriesButton state] == NSOnState) {
		[mergedGlossary removeDuplicateEntries];
	}
	
    int index = [mMergeDestPopUp indexOfSelectedItem];

    if (index == 0)
    {
        NSError *outError = nil;
        
        // New glossary
        GlossaryDocument *document = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"TMX Glossary" error:&outError];
        [[NSDocumentController sharedDocumentController] addDocument:document];
        
		[document setGlossary:mergedGlossary];
        [document makeWindowControllers];
        [document updateChangeCount:NSChangeDone];
        
        GlossaryWC *glossary = [document glossaryWC];
        [[glossary window] makeKeyAndOrderFront:self];            
    }
    else
    {
        Glossary *g = [[mMergeDestPopUp selectedItem] representedObject];
		[g removeAllEntries];
		[g addEntries:mergedGlossary.entries];
		NSError *error = nil;
        
		if (![g writeToFile:&error])
        {
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		}
    }
}

- (void)showWithParent:(NSWindow*)parent
{
	[NSApp beginSheet:[self window] modalForWindow:parent modalDelegate:self didEndSelector:NULL contextInfo:NULL];
}

- (IBAction)cancel:(id)sender
{
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];
}

- (IBAction)merge:(id)sender
{
    [self performMerge];
    
	[NSApp endSheet:[self window]];
	[[self window] orderOut:self];    
}

@end
