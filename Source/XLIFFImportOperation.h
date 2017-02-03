//
//  XLIFFImportOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class XLIFFImportSettings;

/**
 Uses the xliff tree and applies the translation to its StringController.
 */
@interface XLIFFImportOperation : Operation
{
    XLIFFImportSettings *settings;
}

@property (strong) XLIFFImportSettings *settings;

@end
