//
//  XLIFFImportOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportOperationDriver.h"
#import "XLIFFImportSettings.h"
#import "XLIFFImportOVC.h"
#import "XLIFFImportPreviewOVC.h"
#import "XLIFFImportPreviewOperation.h"
#import "XLIFFImportOperation.h"
#import "LanguageController.h"
#import "ProjectPrefs.h"

@implementation XLIFFImportOperationDriver

- (id) init
{
    self = [super init];
    if (self != nil) {
        settings = [[XLIFFImportSettings alloc] init];
    }
    return self;
}


#define STATE_IMPORT_OVC 1
#define STATE_IMPORT_PREVIEW_OVC 2
#define STATE_IMPORT_PREVIEW_OP 3
#define STATE_IMPORT_OP 4

- (id)operationForState:(int)state
{
    id op = nil;
    switch (state) {
        case STATE_IMPORT_OVC: {
            XLIFFImportOVC *operation = [XLIFFImportOVC createInstance];
            operation.settings = settings;
            op = operation;
            break;            
        }

        case STATE_IMPORT_PREVIEW_OVC: {
            XLIFFImportPreviewOVC *operation = [XLIFFImportPreviewOVC createInstance];
            operation.settings = settings;
            op = operation;
            break;            
        }

        case STATE_IMPORT_PREVIEW_OP: {
            XLIFFImportPreviewOperation *operation = [XLIFFImportPreviewOperation operation];
            operation.settings = settings;
            op = operation;
            break;            
        }
            
        case STATE_IMPORT_OP: {
            XLIFFImportOperation *operation = [XLIFFImportOperation operation];
            operation.settings = settings;
            op = operation;
            break;                        
        }
    }
    return op;
}

- (void)loadSettings
{
    [settings setData:[[self.provider projectPrefs] importXLIFFSettings]];
    
    NSArray *files = arguments[@"fcs"];
    if(files) {
        settings.targetFiles = files;
    } else {
        settings.targetFiles = [[self.provider selectedLanguageController] fileControllers];        
    }    
}

- (void)saveSettings
{
    [[self.provider projectPrefs] setImportXLIFFSettings:[settings data]];
}

- (int)previousState:(int)state
{
    int previousState = STATE_ERROR;
    switch (state) {
        case STATE_INITIAL:
            previousState = STATE_END;
            break;
            
        case STATE_IMPORT_OVC:
            previousState = STATE_END;            
            break;    

        case STATE_IMPORT_PREVIEW_OP:
            previousState = STATE_IMPORT_OVC;            
            break;    
            
        case STATE_IMPORT_PREVIEW_OVC:
            previousState = STATE_IMPORT_OVC;            
            break;    
            
        case STATE_IMPORT_OP:
            previousState = STATE_IMPORT_PREVIEW_OVC;            
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
            nextState = STATE_IMPORT_OVC;
            break;
            
        case STATE_IMPORT_OVC:
            [self saveSettings];
            nextState = STATE_IMPORT_PREVIEW_OP;
            break;    

        case STATE_IMPORT_PREVIEW_OP:
            nextState = STATE_IMPORT_PREVIEW_OVC;
            break;    

        case STATE_IMPORT_PREVIEW_OVC:
            [self saveSettings];
            nextState = STATE_IMPORT_OP;
            break;    
            
        case STATE_IMPORT_OP:
            nextState = STATE_END;
            break;
    }
    return nextState;
}

@end
