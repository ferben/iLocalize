//
//  NewProjectGeneralOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "PresetsManager.h"

@class NewProjectSettings;

@interface NewProjectGeneralOVC : OperationViewController<PresetsManagerDelegate>
{
    IBOutlet NSPopUpButton  *mPresetPopUp;
    
    IBOutlet NSPathControl  *projectFolderPathControl;
    IBOutlet NSPathControl  *projectSourcePathControl;
    
    IBOutlet NSTextField    *projectNameField;
    
    IBOutlet NSTextField    *projectInfoField;
    
    NewProjectSettings      *settings;

    PresetsManager          *presetsManager;
}

@property (strong) NewProjectSettings *settings;

- (IBAction)chooseProjectFolder:(id)sender;
- (IBAction)projectFolderPathChanged:(id)sender;

- (IBAction)chooseSourceBundle:(id)sender;
- (IBAction)sourceBundlePathChanged:(id)sender;

@end
