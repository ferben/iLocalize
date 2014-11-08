//
//  GlossaryScopeAbstractWC.m
//  iLocalize
//
//  Created by Jean Bovet on 1/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryScopeAbstractWC.h"
#import "GlossaryScope.h"
#import "GlossaryScopeItem.h"

#import "TreeNode.h"

#import "KNImageAndTextButtonCell.h"

@implementation GlossaryScopeAbstractWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"GlossaryScope"]) {
		rootNode = nil;
	}
	return self;
}


- (void)updatePathNodeStates
{
	rootNode = [self.scope rootNode];
	for(TreeNode *pathNode in [rootNode nodes]) {
		int state = NSMixedState;
		for(TreeNode *glossaryNode in [pathNode nodes]) {
			GlossaryScopeItem *gsi = [glossaryNode payload];
			if(state == NSMixedState) {
				state = [gsi state];
			} else if(state != [gsi state]) {
				state = NSMixedState;
				break;
			}
		}					
		GlossaryScopeItem *pathScopeItem = [pathNode payload];
		pathScopeItem.state = state;
	}
}

- (void)willShow
{
	[self updatePathNodeStates];
	[outlineView reloadData];
	[outlineView expandItem:nil expandChildren:YES];
}

- (void)setTitle:(NSString*)string
{
	[titleTextField setStringValue:string];
}

- (void)setCancellable:(BOOL)flag
{
	[cancelButton setHidden:!flag];
}

#pragma mark Source

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if(item == NULL) {
		return [rootNode nodes].count;
	} else {
		return [item nodes].count;
	}
}

- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{
	if(item == NULL) {
		return [rootNode nodes][index];
	} else {
		return [item nodes][index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
	return [[item nodes] count] > 0;
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	GlossaryScopeItem *gsi = [item payload];
	if([[item nodes] count] == 0 && [ov levelForItem:item] == 0) {
		return @(NSOffState);
	} else {
		return [NSNumber numberWithInt:gsi.state];
	}
}

- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	TreeNode *tn = item;
	GlossaryScopeItem *gsi = [tn payload];
	gsi.state = [object intValue];
	if(gsi.state == NSMixedState) {
		gsi.state = NSOnState;
	}
	
	if(gsi.folder != nil) {
		// Propagate the state to all the glossary if the item represents a glossary folder.
		for(TreeNode *c in [tn nodes]) {
			[[c payload] setState:gsi.state];
		}
	} else {
		[self updatePathNodeStates];
	}
	[outlineView reloadData];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{	
	//[cell setEnabled:[item nodes].count > 0];
	[cell setTitle:[item title]];
	[(KNImageAndTextButtonCell *)cell setImage:[[item payload] icon]];
}

@end
