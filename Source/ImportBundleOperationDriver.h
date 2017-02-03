//
//  ImportFromBundleOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class AnalyzeBundleOp;
@class ImportBundleOVC;
@class ImportBundlePreviewOp;
@class ImportLocalizedDetectConflictsOp;
@class ImportDiff;
@class ScanBundleOp;
@class ScanBundleOVC;
@class BundleSource;

@interface ImportBundleOperationDriver : OperationDriver {
    AnalyzeBundleOp *analyzeOp;
    ImportBundleOVC *importBundleOVC;
    ImportBundlePreviewOp *previewOp;
    ImportLocalizedDetectConflictsOp *detectConflictsOp;
    ImportDiff *importDiff;
    ScanBundleOp *scanBundleOp;
    ScanBundleOVC *scanBundleOVC;
    
    /**
     Holds the path information about the base bundle, that is:
     the source path and the selected files within that path.
     */
    BundleSource *baseBundleSource;    
}
@property (strong) AnalyzeBundleOp *analyzeOp;
@property (strong) ImportBundleOVC *importBundleOVC;
@property (strong) ImportBundlePreviewOp *previewOp;
@property (strong) ImportLocalizedDetectConflictsOp *detectConflictsOp;
@property (strong) ScanBundleOp *scanBundleOp;
@property (strong) ScanBundleOVC *scanBundleOVC;
@property (strong) BundleSource *baseBundleSource;
@end
