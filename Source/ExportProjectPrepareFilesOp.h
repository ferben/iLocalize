//
//  MergeBundleOp.h
//  iLocalize
//
//  Created by Jean Bovet on 6/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ExportProjectSettings;

/**
 This operation prepares the list of files to copy (or to merge).
 */
@interface ExportProjectPrepareFilesOp : Operation
{
    @private
    ExportProjectSettings  *settings;
}

@property (strong) ExportProjectSettings *settings;

@end
