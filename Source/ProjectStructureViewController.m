//
//  ProjectDetailsPath.m
//  iLocalize
//
//  Created by Jean Bovet on 1/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectStructureViewController.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "AZPathNode.h"
#import "ImageAndTextCell.h"
#import "ProjectModel.h"
#import "ProjectDocument.h"

@implementation ProjectStructureViewController

+ (ProjectStructureViewController*)newInstance:(ProjectWC*)projectWC
{
	ProjectStructureViewController *controller = [[ProjectStructureViewController alloc] initWithNibName:@"ProjectInfoViewPath" bundle:nil];
	controller.projectWC = projectWC;
	return controller;
}

- (void)awakeFromNib
{
	ImageAndTextCell *imageAndTextCell = [[ImageAndTextCell alloc] init];
	[imageAndTextCell setEditable:NO];
	[[[outlineView tableColumns] firstObject] setDataCell:imageAndTextCell];
}

- (void)applyFilter:(AZPathNode*)node
{
	NSString *pformat = [NSString stringWithFormat:@"pFile.pFilePath BEGINSWITH[cd] '%@'", [node absolutePath]];
	[self.projectWC setPathPredicate:[NSPredicate predicateWithFormat:pformat]];		
}

+ (AZPathNode*)pathTreeForProjectProvider:(id<ProjectProvider>)pp
{
	ProjectModel *pm = [pp projectModel];
	AZPathNode *root = [AZPathNode rootNodeWithPath:[pm projectSourceFilePath]];
    [root beginModifications];
	[[[pp projectController] languageControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		LanguageController *lc = obj;
		[[lc fileControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			FileController *fc = obj;
			
			[root addRelativePath:[fc relativeFilePath]];
		}];
	}];	

    [root endModifications];
    [root setHideLanguageFolders:YES];

    return root;
}

- (void)update
{
	NSMutableArray *expandedItems = [NSMutableArray array];
	for(int row=0; row<[outlineView numberOfRows]; row++) {
		id item = [outlineView itemAtRow:row];
		if([outlineView isItemExpanded:item]) {
			[expandedItems addObject:[item representedObject]];			
		}
	}
	
	AZPathNode *root = [ProjectStructureViewController pathTreeForProjectProvider:[self.projectWC projectDocument]];	
	[controller setContent:root];

	for(int row=0; row<[outlineView numberOfRows]; row++) {
		id item = [outlineView itemAtRow:row];
		for(AZPathNode *node in expandedItems) {
			if([[item representedObject] isEqualTo:node]) {
				[outlineView expandItem:item];
			}			
		}
	}		

	[outlineView expandItem:[outlineView itemAtRow:0]];
	[self applyFilter:[[outlineView selectedItem] representedObject]];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell*)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	[cell setImage:[[item representedObject] image]];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
	id object = [notification userInfo][@"NSObject"];
	AZPathNode *node = [object representedObject];
	
    if (node.children.count == 1)
    {
		NSInteger row = [outlineView rowForItem:object];
		[outlineView expandItem:[outlineView itemAtRow:row + 1]];
	}
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	AZPathNode *node = [[outlineView selectedItem] representedObject];
	if(node) {
		[self applyFilter:node];
	}
}

@end
