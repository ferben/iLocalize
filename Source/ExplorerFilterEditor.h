//
//  ExplorerSmartFilterEditor.h
//  iLocalize3
//
//  Created by Jean on 18.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@class ExplorerFilter;
@class Explorer;
@class ProjectExplorerController;

@interface ExplorerFilterEditor : AbstractWC {
    IBOutlet NSTextField            *mNameField;
    IBOutlet NSPredicateEditor        *mPredicateEditor;
    IBOutlet NSButton                *mGlobalButton;    
}

@property (weak) ProjectExplorerController *controller;
@property (strong) ExplorerFilter    *filter;
@property (weak) Explorer *explorer;

- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

@end
