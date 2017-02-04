//
//  FilterBundleOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZPathNodeSelectionView.h"
#import "AZPathNode.h"

@interface ScanBundleOVC : OperationViewController
{
    AZPathNode               *node;
    IBOutlet NSOutlineView   *outlineView;
    AZPathNodeSelectionView  *pathNodeSelectionView;
    IBOutlet NSButton        *importLocalizedResourcesOnlyButton;
}

@property (strong) AZPathNode *node;

//- (IBAction)toggleLocalizedOnly:(id)sender;

@end
