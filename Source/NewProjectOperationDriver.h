//
//  NewProjectOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class NewProjectGeneralOVC;
@class NewProjectLanguagesOVC;
@class AnalyzeBundleOp;
@class NewProjectSettings;
@class ScanBundleOp;
@class ScanBundleOVC;

@interface NewProjectOperationDriver : OperationDriver {
    NewProjectSettings *settings;
    NewProjectGeneralOVC *generalOVC;
    NewProjectLanguagesOVC *languagesOVC;
    ScanBundleOp *filterBundleOp;
    ScanBundleOVC *filterBundleOVC;
    AnalyzeBundleOp *analyzeOp;
}
@property (strong) NewProjectSettings *settings;
@property (strong) NewProjectGeneralOVC *generalOVC;
@property (strong) NewProjectLanguagesOVC *languagesOVC;
@property (strong) ScanBundleOp *filterBundleOp;
@property (strong) ScanBundleOVC *filterBundleOVC;
@property (strong) AnalyzeBundleOp *analyzeOp;
@end
