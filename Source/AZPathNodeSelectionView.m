//
//  AZPathNodeSelectionView.m
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZPathNodeSelectionView.h"
#import "AZPathNode.h"

@implementation AZPathNodeSelectionView

- (void)selectAll
{
    [self.rootPath applyState:NSControlStateValueOn];
    [self refresh];
}

- (void)selectRelativePaths:(NSArray*)paths
{
    [self.rootPath visitLeaves:^(AZPathNode *node) {
        if([paths containsObject:[node relativePath]]) {
            [node applyState:NSControlStateValueOn];
        }
    }];    
    [self refresh];
}

- (BOOL)isAllSelected
{
    return self.rootPath.state == NSControlStateValueOn;
}

- (NSArray*)selectedRelativePaths
{
    return [self.rootPath selectedRelativePaths];
}

- (void)refresh
{
    [self.outlineView setDataSource:self];
    [self.outlineView setDelegate:self];

    [self.outlineView reloadData];
    [self.outlineView expandItem:[self.outlineView itemAtRow:0]];
}

#pragma mark Structure Source and Delegate

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    id object = [notification userInfo][@"NSObject"];
    AZPathNode *node = object;
    
    if (node.children.count == 1)
    {
        NSInteger row = [self.outlineView rowForItem:object];
        [self.outlineView expandItem:[self.outlineView itemAtRow:row+1]];
    }
}

- (NSInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
    if(item == NULL) {
        return 1;
    } else {
        return [item displayableChildren].count;
    }
}

- (id)outlineView:(NSOutlineView *)ov child:(NSInteger)index ofItem:(id)item
{
    if(item == NULL) {
        return self.rootPath;
    } else {
        return [item displayableChildren][index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
    return [item displayableChildren].count > 0;
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return [NSNumber numberWithInt:[item state]];
}

- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    int state = [object intValue];
    if(state == NSControlStateValueMixed) {
        state = NSControlStateValueOn;
    }
    
    [((AZPathNode*)item) applyState:state];
    [ov reloadData];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{    
    [cell setTitle:[item title]];
    [cell setImage:[item image]];        
}

@end
