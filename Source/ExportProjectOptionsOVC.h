//
//  ExportOptionsOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class ExportProjectSettings;

@interface ExportProjectOptionsOVC : OperationViewController
{
    IBOutlet NSObjectController  *objectController;
    ExportProjectSettings        *settings;
    NSSize                        originalSize;
    IBOutlet NSView              *hideEmailComponentsView;
}

@property (strong) ExportProjectSettings *settings;

- (IBAction)email:(id)sender;

@end
