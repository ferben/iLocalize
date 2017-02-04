//
//  ProjectExport.h
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZListSelectionView.h"
#import "AZPathNodeSelectionView.h"
#import "PresetsManager.h"

#define EXPORT_PRESET_NAME      @"PRESET_NAME"
#define EXPORT_PRESET_SETTINGS  @"PRESET_SETTINGS"

@class ExportProjectSettings;
@class AZPathNode;

@interface ExportProjectOVC : OperationViewController<PresetsManagerDelegate>
{
    AZPathNode               *rootPath;
    IBOutlet NSOutlineView   *outlineView;
    AZPathNodeSelectionView  *pathNodeSelectionView;
    
    IBOutlet NSOutlineView   *languagesOutlineView;
    AZListSelectionView      *languagesSelectionView;
            
    IBOutlet NSPathControl   *targetPathControl;
    IBOutlet NSPopUpButton   *presetPopUpButton;

    PresetsManager           *presetsManager;
    ExportProjectSettings    *settings;
}

@property (strong) AZPathNode *rootPath;
@property (strong) ExportProjectSettings *settings;

- (IBAction)options:(id)sender;
- (IBAction)chooseTargetDirectory:(id)sender;

@end
