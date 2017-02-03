//
//  UpdateLocalFilesOperation.h
//  iLocalize
//
//  Created by Jean on 9/23/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ImportFilesSettings;

@interface ImportLocalFilesOperation : Operation {
    ImportFilesSettings *settings;
}
@property (strong) ImportFilesSettings *settings;
@end
