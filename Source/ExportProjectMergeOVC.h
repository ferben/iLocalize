//
//  ExportProjectMergeOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 6/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZPathNodeSelectionView.h"
#import "AZPathNode.h"

@class ExportProjectSettings;

@interface ExportProjectMergeOVC : OperationViewController
{
    @private
    ExportProjectSettings    *settings;
    AZPathNode               *node;
    IBOutlet NSOutlineView   *outlineView;
    AZPathNodeSelectionView  *pathNodeSelectionView;
}

@property (strong) AZPathNode *node;
@property (strong) ExportProjectSettings *settings;

@end
