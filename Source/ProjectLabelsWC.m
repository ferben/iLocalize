//
//  ProjectLabels.m
//  iLocalize3
//
//  Created by Jean on 3/21/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "ProjectLabelsWC.h"
#import "ProjectLabels.h"
#import "ProjectWC.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "Constants.h"

@implementation ProjectLabelsWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"ProjectLabels"]) {
		[self window];
	}
	return self;
}

- (void)willShow
{
	[self setDidCloseSelector:nil target:nil];
	
	ProjectWC *project = [[self projectProvider] projectWC];
	[[project projectLabels] buildLabelColorsMenu:mColorMenu];
	[mLabelsController setContent:[[project projectLabels] labels]];
}

- (NSArray*)stringControllersUsingLabelIndex:(int)index
{
	NSMutableArray *array = [NSMutableArray array];
	NSNumber *indexObj = @(index);
	NSEnumerator *lcEnumerator = [[[[self projectProvider] projectController] languageControllers] objectEnumerator];
	LanguageController *lc;
	while(lc = [lcEnumerator nextObject]) {
		NSEnumerator *fcEnumerator = [[lc fileControllers] objectEnumerator];
		FileController *fc;
		while(fc = [fcEnumerator nextObject]) {
			NSEnumerator *scEnumerator = [[fc stringControllers] objectEnumerator];
			StringController *sc;
			while(sc = [scEnumerator nextObject]) {
				if([[sc labelIndexes] containsObject:indexObj])
					[array addObject:sc];
			}				
		}
	}
	return array;
}

- (void)removeLabelIndex:(int)index fromStringControllers:(NSArray*)scs
{
	NSNumber *indexObj = @(index);
	StringController *sc;
	for(sc in scs) {
		NSMutableSet *indexes = [[NSMutableSet alloc] initWithSet:[sc labelIndexes]];
		[indexes removeObject:indexObj];
		[sc setLabelIndexes:indexes];
	}
}

- (BOOL)labelExistsWithID:(NSString*)ID
{
	int count = 0;
	NSEnumerator *enumerator = [[mLabelsController content] objectEnumerator];
	NSDictionary *dic;
	while(dic = [enumerator nextObject]) {
		if([dic[@"ID"] isEqualCaseInsensitiveToString:ID])
			count++;
	}
	return count > 1;
}


- (void)invalidIDWithMessage:(NSString*)message
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Invalid label ID", nil)
									 defaultButton:NSLocalizedString(@"OK", nil)
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@"%@", message];
	[alert runModal];	
}

- (void)displayEmptyID
{
	[self invalidIDWithMessage:NSLocalizedString(@"Label ID cannot be empty.", nil)];
}

- (void)displayAlreadyExistsID:(NSString*)ID
{
	[self invalidIDWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Label ID “%@” already exists.", nil), ID]];	
}

- (BOOL)checkLabels
{
	NSMutableSet *ids = [NSMutableSet set];
	NSEnumerator *enumerator = [[mLabelsController content] objectEnumerator];
	NSDictionary *dic;
	while(dic = [enumerator nextObject]) {
		id ID = dic[@"ID"];
		if([ID length] == 0) {
			[self displayEmptyID];
			return NO;
		}
		if([ids containsObject:ID]) {
			[self displayAlreadyExistsID:ID];
			return NO;
		}
		[ids addObject:ID];
	}
	return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSTableView *tv = (NSTableView*)control;
	if([tv editedColumn] == 0) {
		NSString *s = [fieldEditor string];
		if([s length] == 0) {
			[self displayEmptyID];
			return NO;
		}
		if([self labelExistsWithID:s]) {
			[self displayAlreadyExistsID:s];
			return NO;			
		}
	}
	return YES;	
}

- (IBAction)remove:(id)sender
{
	int index = [mLabelsController selectionIndex];
	NSArray *scs = [self stringControllersUsingLabelIndex:index];
	if([scs count] > 0) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"The selected label is used in the project", nil)
										 defaultButton:NSLocalizedString(@"Remove", nil)
									   alternateButton:NSLocalizedString(@"Cancel", nil)
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"By choosing to remove it, iLocalize will remove all its references in the project", nil)];	
		if([alert runModal] == NSAlertDefaultReturn) {
			[self removeLabelIndex:index fromStringControllers:scs];
			[mLabelsController removeObjectAtArrangedObjectIndex:index];
		}		
	} else
		[mLabelsController removeObjectAtArrangedObjectIndex:index];
}

- (IBAction)ok:(id)sender
{
	if(![self checkLabels])
		return;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ILProjectLabelsDidChange
														object:nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ILStringsFilterDidChange
														object:nil];
	
	[[self projectProvider] setDirty];
	[self hide];	
}

@end
