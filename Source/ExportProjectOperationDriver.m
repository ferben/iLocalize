//
//  ExportProjectOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ExportProjectOperationDriver.h"
#import "ExportProjectSettings.h"
#import "ExportProjectOVC.h"
#import "ExportProjectOptionsOVC.h"
#import "ExportProjectOperation.h"
#import "ExportProjectPrepareFilesOp.h"
#import "ExportProjectMergeOVC.h"

#import "ProjectPrefs.h"

@implementation ExportProjectOperationDriver

- (id) init
{
    self = [super init];
    if (self != nil) {
        settings = [[ExportProjectSettings alloc] init];
    }
    return self;
}


enum {
    STATE_EXPORT_OP,
    STATE_EXPORT_OVC,
    STATE_EXPORT_MERGE_OP,
    STATE_EXPORT_MERGE_OVC
};

/**
 Returns the name of the preset that needs to be executed. This value is nil when the user
 chooses the Export command and non-nil when he chooses Export Again As.
 */
- (NSString*)presetName
{
    return [self arguments][EXPORT_PRESET_NAME];
}

- (id)operationForState:(int)state
{
    id op = nil;
    switch (state) {
        case STATE_EXPORT_OVC: {
            ExportProjectOVC *operation = [ExportProjectOVC createInstance];
            operation.settings = settings;
            // indicate to bypass this view controller if the user choose
            // Export Again As (which means nothing will be displayed but the validation
            // code against Overwrite/Merge will be executed).
            operation.bypass = [self presetName] != nil;
            op = operation;
            break;            
        }
                        
        case STATE_EXPORT_OP: {
            ExportProjectOperation *operation = [ExportProjectOperation operation];
            operation.settings = settings;
            op = operation;
            break;                        
        }

        case STATE_EXPORT_MERGE_OP: {
            ExportProjectPrepareFilesOp *operation = [ExportProjectPrepareFilesOp operation];
            operation.settings = settings;
            op = operation;
            break;                        
        }
            
        case STATE_EXPORT_MERGE_OVC: {
            ExportProjectMergeOVC *operation = [ExportProjectMergeOVC createInstance];
            operation.settings = settings;
            op = operation;
            break;                        
        }
    }
    return op;
}

- (void)loadSettings
{
    settings.provider = self.provider;
    [settings setData:[[self.provider projectPrefs] exportSettings]];

    NSString *presetName = [self presetName];
    if(presetName) {
        for(NSDictionary *p in [[self.provider projectPrefs] exportSettingsPresets]) {
            if([p[EXPORT_PRESET_NAME] isEqualToString:presetName]) {
                [settings setData:p[EXPORT_PRESET_SETTINGS]];
            }
        }
    }
}

- (void)saveSettings
{
    [[self.provider projectPrefs] setExportSettings:[settings data]];
}

- (void)operationCancel
{
    [self saveSettings];
    [super operationCancel];
}

- (int)previousState:(int)state
{
    int previousState = STATE_ERROR;
    switch (state) {
        case STATE_INITIAL:
            previousState = STATE_END;
            break;
            
        case STATE_EXPORT_OVC:
            previousState = STATE_END;            
            break;    
                        
        case STATE_EXPORT_OP:
        case STATE_EXPORT_MERGE_OP:
        case STATE_EXPORT_MERGE_OVC:
            previousState = STATE_EXPORT_OVC;            
            break;                
    }    
    return previousState;
}

- (int)nextState:(int)state
{
    int nextState = STATE_ERROR;
    switch (state) {
        case STATE_INITIAL:
            [self loadSettings];
            nextState = STATE_EXPORT_OVC;    
            break;
            
        case STATE_EXPORT_OVC:
            [self saveSettings];
            nextState = STATE_EXPORT_MERGE_OP;
            break;    
                                
        case STATE_EXPORT_MERGE_OP:
            if(settings.filesToCopy.count == 0) {
                nextState = STATE_END;
            } else {
                if(settings.mergeFiles && settings.filesToCopy.count > 0) {
                    nextState = STATE_EXPORT_MERGE_OVC;                
                } else {
                    nextState = STATE_EXPORT_OP;                
                }                
            }
            break;

        case STATE_EXPORT_MERGE_OVC:
            nextState = STATE_EXPORT_OP;
            break;

        case STATE_EXPORT_OP:
            nextState = STATE_END;
            break;
    }
    return nextState;
}

@end
