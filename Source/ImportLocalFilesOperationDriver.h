//
//  ImportLocalFilesOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class ImportFilesSettings;
@class AnalyzeBundleOp;

@interface ImportLocalFilesOperationDriver : OperationDriver
{
    ImportFilesSettings  *settings;
    AnalyzeBundleOp      *analyzeOp;
}

@property (strong) ImportFilesSettings *settings;
@property (strong) AnalyzeBundleOp *analyzeOp;

@end
