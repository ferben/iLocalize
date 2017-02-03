//
//  XLIFFExportOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class XLIFFExportSettings;

@interface XLIFFExportOperationDriver : OperationDriver {
    XLIFFExportSettings *settings;
}

@end
