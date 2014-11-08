//
//  ExportProjectOperationDriver.h
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationDriver.h"

@class ExportProjectSettings;

@interface ExportProjectOperationDriver : OperationDriver {
	ExportProjectSettings		*settings;
}

@end
