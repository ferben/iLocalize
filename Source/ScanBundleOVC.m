//
//  FilterBundleOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ScanBundleOVC.h"


@implementation ScanBundleOVC

@synthesize node;

- (id)init
{
	if((self = [super initWithNibName:@"ScanBundle" bundle:nil])) {
		pathNodeSelectionView = [[AZPathNodeSelectionView alloc] init];
	}
	return self;
}


- (void)willShow
{
	pathNodeSelectionView.outlineView = outlineView;
	pathNodeSelectionView.rootPath = self.node;
	[pathNodeSelectionView refresh];	
}

//- (IBAction)toggleLocalizedOnly:(id)sender
//{
//    [self.node visitAll:^BOOL(AZPathNode *n) {
//        n.localizedPathsOnly = [sender state] == NSOnState;
//        return YES;
//    }];
//	[pathNodeSelectionView refresh];	
//}

@end
