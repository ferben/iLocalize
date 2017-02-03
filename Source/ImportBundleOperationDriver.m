//
//  ImportFromBundleOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportBundleOperationDriver.h"

#import "ImportBundleOVC.h"

#import "ImportBundlePreviewOp.h"
#import "ImportPreviewOVC.h"

#import "ImportRebaseBundleOp.h"
#import "ImportLanguagesOp.h"

#import "ImportLocalizedDetectConflictsOp.h"
#import "ImportLocalizedResolveConflictsOVC.h"

#import "AnalyzeBundleOp.h"
#import "AnalyzeBundleOVC.h"

#import "ScanBundleOp.h"
#import "ScanBundleOVC.h"
#import "BundleSource.h"

#import "ProjectModel.h"

#import "ImportDiff.h"

@implementation ImportBundleOperationDriver

@synthesize analyzeOp;
@synthesize importBundleOVC;
@synthesize previewOp;
@synthesize detectConflictsOp;
@synthesize scanBundleOp;
@synthesize scanBundleOVC;
@synthesize baseBundleSource;

- (id) init
{
    self = [super init];
    if (self != nil) {
        importDiff = [[ImportDiff alloc] init];
    }
    return self;
}


// Various states that this state machine can have.
enum STATES {
    STATE_IMPORT_BUNDLE_OVC,
    
    STATE_REBASE_SCAN_BUNDLE_OP,
    STATE_REBASE_SCAN_BUNDLE_OVC,
    
    STATE_REBASE_ANALYZE_OP,
    STATE_REBASE_ANALYZE_OVC,
    STATE_REBASE_PREVIEW_OP,
    STATE_REBASE_PREVIEW_OVC,
    STATE_REBASE_OP,
    
    STATE_LOCALIZED_DETECT_CONFLICTS_OP,
    STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC,
    STATE_LOCALIZED_IMPORT_OP,    
};

- (BOOL)projectSourceIsApplication
{
    return [[[self.provider projectModel] projectSourceFilePath] isPathApplication];
}

- (id)operationForState:(int)state
{
    id op = nil;
    switch (state) {
        case STATE_IMPORT_BUNDLE_OVC:
            self.importBundleOVC = [ImportBundleOVC createInstance];
            op = self.importBundleOVC;
            break;
        
        case STATE_REBASE_SCAN_BUNDLE_OP:
            self.scanBundleOp = [ScanBundleOp operation];
            self.scanBundleOp.path = self.baseBundleSource.sourcePath;
            op = self.scanBundleOp;
            break;
            
        case STATE_REBASE_SCAN_BUNDLE_OVC:
            self.scanBundleOVC = [ScanBundleOVC createInstance];
            self.scanBundleOVC.node = self.scanBundleOp.node;
            op = self.scanBundleOVC;
            break;

        case STATE_REBASE_ANALYZE_OP:
            self.analyzeOp = [AnalyzeBundleOp operation];
            self.analyzeOp.node = self.baseBundleSource.sourceNode;
            op = self.analyzeOp;
            break;
            
        case STATE_REBASE_ANALYZE_OVC: {
            AnalyzeBundleOVC *operation = [AnalyzeBundleOVC createInstance];
            operation.rootPath = self.baseBundleSource.sourcePath;
            operation.problems = self.analyzeOp.problems;
            op = operation;
            break;            
        }
            
        case STATE_REBASE_PREVIEW_OP:
            self.previewOp = [ImportBundlePreviewOp operation];
            self.previewOp.importDiff = importDiff;
            self.previewOp.sourcePath = self.baseBundleSource;
            op = self.previewOp;
            break;
            
        case STATE_REBASE_PREVIEW_OVC: {
            ImportPreviewOVC * ovc = [ImportPreviewOVC createInstance];
            ovc.baseBundleSource = self.baseBundleSource;
            ovc.items = [importDiff items];
            op = ovc;
            break;            
        }
            
        case STATE_REBASE_OP: {
            ImportRebaseBundleOp *operation = [ImportRebaseBundleOp operation];
            operation.usePreviousLayout = self.importBundleOVC.keepLayout;
            operation.importDiff = importDiff;
            op = operation;
            break;            
        }
            
        case STATE_LOCALIZED_DETECT_CONFLICTS_OP: {
            ImportLocalizedDetectConflictsOp *operation = [ImportLocalizedDetectConflictsOp operation];
            operation.languages = [importBundleOVC languages];
            operation.localizedBundle = [importBundleOVC localizedBundle];
            op = operation;
            break;            
        }
            
        case STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC: {
            ImportLocalizedResolveConflictsOVC *ovc = [ImportLocalizedResolveConflictsOVC createInstance];
            ovc.fileConflictItems = [self.detectConflictsOp conflictingFileItems];
            op = ovc;
            break;            
        }
            
        case STATE_LOCALIZED_IMPORT_OP: {
            ImportLanguagesOp *operation = [ImportLanguagesOp operation];
            operation.languages = importBundleOVC.languages;
            // GUI attribute is always NO as we don't propose it anymore
            operation.identical = NO;
            operation.layouts = importBundleOVC.layouts;
            operation.copyOnlyIfExists = importBundleOVC.copyOnlyIfExists;
            operation.sourcePath = importBundleOVC.localizedBundle;
            op = operation;            
            break;            
        }
    }
    return op;
}

- (int)previousState:(int)state
{
    int previousState = STATE_ERROR;
    switch (state) {
        case STATE_INITIAL:
            previousState = STATE_END;
            break;
            
        case STATE_IMPORT_BUNDLE_OVC:
            previousState = STATE_END;            
            break;    
            
        case STATE_REBASE_SCAN_BUNDLE_OP:
        case STATE_REBASE_SCAN_BUNDLE_OVC:
        case STATE_REBASE_ANALYZE_OP:
        case STATE_REBASE_ANALYZE_OVC:
        case STATE_REBASE_PREVIEW_OP:
        case STATE_REBASE_PREVIEW_OVC:
        case STATE_REBASE_OP:
        case STATE_LOCALIZED_DETECT_CONFLICTS_OP:
        case STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC:
        case STATE_LOCALIZED_IMPORT_OP:
            previousState = STATE_IMPORT_BUNDLE_OVC;
            break;
    }    
    return previousState;
}

- (int)nextState:(int)state
{
    int nextState = STATE_ERROR;
    switch (state) {
        case STATE_INITIAL:
            nextState = STATE_IMPORT_BUNDLE_OVC;
            break;
            
        case STATE_IMPORT_BUNDLE_OVC:            
            if([self.importBundleOVC importBaseLanguage]) {
                self.baseBundleSource = [BundleSource sourceWithPath:[self.importBundleOVC baseBundle]];
                nextState = STATE_REBASE_SCAN_BUNDLE_OP;
            } else {
                nextState = STATE_LOCALIZED_DETECT_CONFLICTS_OP;
            }
            break;    
        
        case STATE_REBASE_SCAN_BUNDLE_OP:
            // Assign which files to use based on the scanning of the bundle
            self.baseBundleSource.sourceNode = self.scanBundleOp.node;
            
            // Allow the user to choose which portion of the source bundle to rebase
            // only if the project source is an application (like before). If the project
            // source is a folder, then let the user choose which part to rebase.
            if([self projectSourceIsApplication]) {
                nextState = STATE_REBASE_ANALYZE_OP;                
            } else {
                nextState = STATE_REBASE_SCAN_BUNDLE_OVC;
            }
            break;
        
        case STATE_REBASE_SCAN_BUNDLE_OVC:
            nextState = STATE_REBASE_ANALYZE_OP;
            break;
            
        case STATE_REBASE_ANALYZE_OP:
            if([self.analyzeOp hasProblems]) {
                nextState = STATE_REBASE_ANALYZE_OVC;
            } else {
                nextState = STATE_REBASE_PREVIEW_OP;
            }
            break;
            
        case STATE_REBASE_ANALYZE_OVC:
            nextState = STATE_REBASE_PREVIEW_OP;
            break;
            
        case STATE_REBASE_PREVIEW_OP:
            if([self.previewOp needsToRebase]) {
                nextState = STATE_REBASE_PREVIEW_OVC;
            } else {
                nextState = STATE_REBASE_OP;
            }
            break;
            
        case STATE_REBASE_PREVIEW_OVC:
            nextState = STATE_REBASE_OP;
            break;
            
        case STATE_REBASE_OP:
            nextState = STATE_LOCALIZED_DETECT_CONFLICTS_OP;
            break;
            
        case STATE_LOCALIZED_DETECT_CONFLICTS_OP:
            if([[self.detectConflictsOp conflictingFileItems] count] > 0) {
                nextState = STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC;
            } else {
                nextState = STATE_LOCALIZED_IMPORT_OP;
            }
            break;
            
        case STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC:
            nextState = STATE_LOCALIZED_IMPORT_OP;
            break;
            
        case STATE_LOCALIZED_IMPORT_OP:
            nextState = STATE_END;
            break;
    }
    return nextState;
}

@end
