//
//  PreferencesEditors.h
//  iLocalize3
//
//  Created by Jean on 06.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@class FMModule;

@interface PreferencesEditors : PreferencesObject
{
    IBOutlet NSTableView        *mEditorsTableView;
    IBOutlet NSArrayController  *mEditorsController;
    
    IBOutlet NSArrayController  *mBuiltinTypesController;
    IBOutlet NSArrayController  *mBuiltinExtensionsController;
    IBOutlet NSTableView        *mBuiltinExtensionsTableView;
    
    IBOutlet NSPanel            *mExternalPanel;
    IBOutlet NSTextField        *mExternalExtensionField;
    IBOutlet NSTextField        *mExternalAppField;
    
    NSMutableDictionary         *mEditingEditor;
}

+ (id)shared;

- (void)loadData:(NSDictionary *)data;
- (NSDictionary  *)data;

- (NSString *)editorForExtension:(NSString *)extension;

- (FMModule *)moduleForExtension:(NSString *)extension;

- (IBAction)addExternalEditor:(id)sender;
- (IBAction)addInternalEditor:(id)sender;

- (IBAction)externalPanelChoose:(id)sender;
- (IBAction)externalPanelCancel:(id)sender;
- (IBAction)externalPanelOK:(id)sender;

@end
