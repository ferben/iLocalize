//
//  XLIFFExportOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class XLIFFExportSettings;

@interface XLIFFExportOperation : Operation {
    XLIFFExportSettings *settings;
}
@property (strong) XLIFFExportSettings *settings;

// accessor for unit tests
- (NSString*)buildXLIFF;

@end
