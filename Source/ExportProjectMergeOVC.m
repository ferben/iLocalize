//
//  ExportProjectMergeOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 6/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ExportProjectMergeOVC.h"
#import "ExportProjectSettings.h"

@implementation ExportProjectMergeOVC

@synthesize node;
@synthesize settings;

- (id)init
{
	if((self = [super initWithNibName:@"ExportProjectMerge" bundle:nil])) {
		pathNodeSelectionView = [[AZPathNodeSelectionView alloc] init];
	}
	return self;
}


- (void)willShow
{
    self.node = [AZPathNode rootNodeWithPath:[self.settings.provider sourceApplicationPath]];
    for(NSString *file in self.settings.filesToCopy) {
        [self.node addRelativePath:file];
    }
	pathNodeSelectionView.outlineView = outlineView;
	pathNodeSelectionView.rootPath = self.node;
    [pathNodeSelectionView selectAll];
	[pathNodeSelectionView refresh];	
}

- (void)willContinue
{
    NSMutableArray *files = [NSMutableArray array];
    for(NSString *selectedFile in [node selectedRelativePaths]) {
        // The path contains the name of the bundle in its first component so let's remove it.
        [files addObject:[selectedFile stringByRemovingFirstPathComponent]];
    }
    self.settings.filesToCopy = files;
}

@end
