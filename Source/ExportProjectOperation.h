//
//  ProjectExportLocalization.h
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class ExportProjectSettings;

@interface ExportProjectOperation : Operation {
	ExportProjectSettings *settings;
}
@property (strong) ExportProjectSettings *settings;
@end
