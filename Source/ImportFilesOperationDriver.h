//
//  ImportFilesOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class ImportFilesSettings;
@class AnalyzeBundleOp;
@class ImportLocalizedDetectConflictsOp;

@interface ImportFilesOperationDriver : OperationDriver
{
    ImportFilesSettings               *settings;
    AnalyzeBundleOp                   *analyzeOp;
    ImportLocalizedDetectConflictsOp  *detectConflictsOp;
}

@property (strong) ImportFilesSettings *settings;
@property (strong) AnalyzeBundleOp *analyzeOp;
@property (strong) ImportLocalizedDetectConflictsOp *detectConflictsOp;

@end
