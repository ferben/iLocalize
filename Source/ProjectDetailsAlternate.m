//
//  ProjectDetailsAlternate.m
//  iLocalize
//
//  Created by Jean Bovet on 1/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectDetailsAlternate.h"
#import "IGroupEngineAlternate.h"
#import "ProjectDocument.h"
#import "IGroupElementAlternate.h"
#import "GlossaryTranslator.h"
#import "FMEditor.h"
#import "FileController.h"
#import "StringController.h"

@implementation ProjectDetailsAlternate

@synthesize elements;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]];
	elements = [[NSMutableArray alloc] init];
	
	IGroupEngine *engine = [IGroupEngineAlternate engine];
	mGroupEngineManager = [IGroupEngineManager managerForEngine:engine];
	[mGroupEngineManager setDelegate:self];	
	mGroupEngineManager.state.projectProvider = [self projectProvider];
	[mGroupEngineManager start];
	
	[mTableView setTarget:self];
	[mTableView setDoubleAction:@selector(doubleClickOnTableView:)];		
}


- (void)close
{
	[mGroupEngineManager setDelegate:nil];
	[mGroupEngineManager stop];	
}

- (NSView*)keyView
{
    return mTableView;
}

- (void)stringSelectionDidChange:(NSNotification*)notif
{
	[searchField setStringValue:[[[self.projectWC selectedStringControllers] firstObject] base]?:@""];
	[self search:nil];
}

- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager
{
	// use a set so the results are unique
	NSMutableSet *mutableSet = [NSMutableSet setWithArray:elements];
	
	// add the new results to the set
	for(NSDictionary *r in results) {
		IGroupElementAlternate *e = [IGroupElementAlternate elementWithDictionary:r];
		
		// don't add elements that have identical source and target
		if([e.source isEqualToString:e.target]) continue;
		
		// don't add if it comes from the same file
		FileController *fc = [[[self projectProvider] selectedFileControllers] firstObject];
		if([e.file isEqualToString:[fc relativeFilePath]]) continue;
		
		[mutableSet addObject:e];			
	}
	
	// get back a sorted array
	self.elements = [mutableSet sortedArrayUsingDescriptors:sortDescriptors];
	
	[mResultsController setContent:elements];
}

- (void)clearResultsForEngineManaged:(IGroupEngineManager*)manager
{
	self.elements = nil;
	[mResultsController setContent:nil];
}

- (void)notifyProcessing:(BOOL)processing
{
    
}

- (void)willShow
{
	[super willShow];
	[mGroupEngineManager setEnabled:YES];
}

- (void)willHide
{
	[super willHide];
	[mGroupEngineManager setEnabled:NO];
}

- (void)update
{
	[mGroupEngineManager updateCurrentState];
}

- (NSString *)tableView:(NSTableView *)tv toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
    if ([cell isKindOfClass:[NSTextFieldCell class]]) {
		IGroupElementAlternate *e = [mResultsController arrangedObjects][row];
		if(e) {
			return [NSString stringWithFormat:@"%@ - %.0f%%", e.file, e.score];
		}		
    }
    return nil;
}

- (void)doubleClickOnTableView:(NSTableView*)tv
{
	int row = [tv selectedRow];
	if(row >= 0) {
		IGroupElementAlternate *element = [mResultsController content][row]; 
		GlossaryTranslator *translator = [GlossaryTranslator translator];
		[translator setLanguageController:[[self projectProvider] selectedLanguageController]];
		
		NSArray *selectedStrings = [[self projectProvider] selectedStringControllers];
		if([selectedStrings count] == 1) {
			[translator translateStringControllers:selectedStrings withString:element.target base:nil];
			
			FMEditor *editor = [[self projectProvider] currentFileModuleEditor];
			if([editor respondsToSelector:@selector(performAutoPropagation)]) {
				[editor performSelector:@selector(performAutoPropagation)];			
			}
			
			if([[NSUserDefaults standardUserDefaults] boolForKey:@"glossaryTranslateSelectNextString"]) {
				[editor selectNextItem];
			}
		} else {
			[translator translateStringControllers:selectedStrings withString:element.target base:element.source];
		}			
	}
}

- (IBAction)search:(id)sender
{
	[mGroupEngineManager setSelectedString:[searchField stringValue]];
}

@end
