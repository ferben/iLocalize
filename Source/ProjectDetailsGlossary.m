//
//  ProjectDetailsGlossary.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetailsGlossary.h"
#import "IGroupEngineGlossary.h"
#import "ProjectDocument.h"
#import "IGroupElementGlossary.h"
#import "GlossaryTranslator.h"
#import "FMEditor.h"
#import "GlossaryScopeWC.h"
#import "GlossaryScope.h"
#import "GlossaryWC.h"
#import "GlossaryDocument.h"
#import "Glossary.h"
#import "StringController.h"
#import "AZLevelIndicatorCell.h"
#import "GlossaryNotification.h"

@implementation ProjectDetailsGlossary

@synthesize elements;

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]];
	elements = [[NSMutableArray alloc] init];
	
	IGroupEngine *engine = [IGroupEngineGlossary engine];
	mGroupEngineManager = [IGroupEngineManager managerForEngine:engine];
	[mGroupEngineManager setDelegate:self];	
	mGroupEngineManager.state.projectProvider = [self projectProvider];
	[mGroupEngineManager start];
	
	[mTableView setTarget:self];
	[mTableView setDoubleAction:@selector(doubleClickOnTableView:)];		
	
	[mTableView setColumnAutoresizingStyle:NSTableViewFirstColumnOnlyAutoresizingStyle];
	
	NSTableColumn *translationColumn = [[mTableView tableColumns] firstObject];
	[[translationColumn dataCell] setLineBreakMode:NSLineBreakByTruncatingTail];
	
//	NSLevelIndicatorCell *scoreCell = [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSRelevancyLevelIndicatorStyle];
//	[scoreCell setMinValue:0];
//	[scoreCell setMaxValue:100];
	AZLevelIndicatorCell *scoreCell = [[AZLevelIndicatorCell alloc] init];
	
	scoreColumn = [[NSTableColumn alloc] initWithIdentifier:@"score"];
	[scoreColumn bind:@"value" toObject:mResultsController withKeyPath:@"arrangedObjects.score" options:nil];
	[scoreColumn setMinWidth:50];
	[scoreColumn setMaxWidth:50];
    [scoreColumn setEditable:NO];

	[scoreColumn setDataCell:scoreCell];

	[mTableView addTableColumn:scoreColumn];
    
    [progressIndicator setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(glossaryDidChange:)
                                                 name:GlossaryDidChange
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [scoreColumn unbind:@"value"];
    
}

- (void)close
{
	[mGroupEngineManager setDelegate:nil];
	[mGroupEngineManager stop];	
    [[self view] removeFromSuperview];
    [self removeFromParentViewController];
    //	[self setView:nil];
}

- (NSView*)keyView
{
    return mTableView;
}

- (void)stringSelectionDidChange:(NSNotification*)notif
{
	[searchField setStringValue:[[[self.projectWC selectedStringControllers] firstObject] base] ? : @""] ;
	[self search:nil];
}

- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager
{
	// use a set so the results are unique
	NSMutableSet *mutableSet = [NSMutableSet setWithArray:elements];
	
	// add the new results to the set
	for(NSDictionary *r in results) {
		IGroupElementGlossary *e = [IGroupElementGlossary elementWithDictionary:r];

		// don't add elements that have identical source and target
		if([e.source isEqualToString:e.target]) continue;
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
    [progressIndicator setHidden:!processing];
    if(processing) {
        [progressIndicator startAnimation:self];
    } else {
        [progressIndicator stopAnimation:self];        
    }
}

- (NSMenu*)actionMenu
{
	return actionMenu;
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

- (void)reload {
	[self clearResultsForEngineManaged:nil];
	[self update];
	
	// Do it once with an empty string then with the real value to trigger another search
	[mGroupEngineManager setSelectedString:@""];
	[mGroupEngineManager setSelectedString:[searchField stringValue]];
}

- (void)glossaryDidChange:(NSNotification*)notif {
    [self reload];
}

- (NSString *)tableView:(NSTableView *)tv toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
	IGroupElementGlossary *e = [mResultsController arrangedObjects][row];
    if ([cell isKindOfClass:[NSTextFieldCell class]]) {
		if(e) {
			return [NSString stringWithFormat:@"%@", e.source];
		}
    } else if ([cell isKindOfClass:[NSLevelIndicatorCell class]]) {
		if(e) {
			return [NSString stringWithFormat:@"%.0f%%", e.score];
		}
    } else if ([cell isKindOfClass:[AZLevelIndicatorCell class]]) {
		if(e) {
			return [NSString stringWithFormat:@"%.0f%%", e.score];
		}
    }
    return nil;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	IGroupElementGlossary *e = [mResultsController arrangedObjects][rowIndex];
    if ([cell isKindOfClass:[AZLevelIndicatorCell class]]) {
		[cell setDoubleValue:e.score];
	}	
}

- (IGroupElementGlossary*)selectedGlossaryElement
{
	int row = [mTableView selectedRow];
	if(row >= 0) {
		return [mResultsController content][row]; 
	} else {
		return nil;
	}		
}

- (void)doubleClickOnTableView:(NSTableView*)tv
{
	[self use:tv];
}

- (BOOL)canExecuteCommand:(SEL)command {
    if (command == @selector(translateUsingSelectedGlossaryEntry:)) {
        return nil != [self selectedGlossaryElement];
    } else {
        return [super canExecuteCommand:command];
    }
}

- (void)executeCommand:(SEL)command {
    if (command == @selector(translateUsingSelectedGlossaryEntry:)) {
        [self use:nil];
    } else {
        return [super executeCommand:command];
    }    
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	SEL action = [anItem action];
	BOOL selection = [self selectedGlossaryElement] != nil;
	
	if(action == @selector(use:)) {
		return selection;
	}
	if(action == @selector(reveal:)) {
		return selection;
	}
	if(action == @selector(copy:)) {
		return selection;
	}
	return YES;
}

- (IBAction)use:(id)sender
{
	IGroupElementGlossary *element = [self selectedGlossaryElement]; 
	if(element) {
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

- (IBAction)reveal:(id)sender
{
    IGroupElementGlossary *element = [self selectedGlossaryElement];
    
	if (element)
    {
        NSDocument *document;
        
        NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
        
        [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:element.glossary.targetFile] display:YES completionHandler:
        ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
        {
            if (error)
                [documentController presentError:error];
        }];

        GlossaryWC *wc = [(GlossaryDocument *)document glossaryWC];
        
		if (wc)
        {
            [wc selectEntryWithBase:element.source translation:element.target];
		}
	}
}

- (IBAction)copy:(id)sender
{
	IGroupElementGlossary *element = [self selectedGlossaryElement]; 
	if(element) {
		NSPasteboard *pb = [NSPasteboard generalPasteboard];
		[pb declareTypes:@[NSStringPboardType] owner:nil];
		[pb setString:element.target forType:NSStringPboardType];						
	}
}

- (IBAction)scope:(id)sender
{
	GlossaryScope *scope = ((IGroupEngineGlossary*)mGroupEngineManager.engine).scope;
	self.scopeWC = [[GlossaryScopeWC alloc] init];
	[self.scopeWC setDidCloseSelector:@selector(scopeDidClose) target:self];
	[self.scopeWC setParentWindow:[[self projectWC] window]];
	[self.scopeWC setProjectProvider:[self projectProvider]];
	[self.scopeWC setScope:scope];
	[self.scopeWC showAsSheet];
}

- (IBAction)search:(id)sender
{
	[mGroupEngineManager setSelectedString:[searchField stringValue]];
}

- (void)scopeDidClose
{
    [self reload];
    self.scopeWC = nil;
}

@end
