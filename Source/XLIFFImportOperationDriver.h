//
//  XLIFFImportOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class XLIFFImportSettings;

@interface XLIFFImportOperationDriver : OperationDriver {
    XLIFFImportSettings *settings;
}

@end
