//
//  ImportFilesLocalizedOp.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ImportFilesSettings;

/**
 This operation updates the specified files in the project.
 */
@interface ImportFilesLocalizedOp : Operation {
	ImportFilesSettings *settings;
}
@property (strong) ImportFilesSettings *settings;
@end
