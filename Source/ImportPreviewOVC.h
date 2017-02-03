//
//  ImportPreviewWC.h
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class AZPathNode;
@class BundleSource;

@interface ImportPreviewOVC : OperationViewController {
    IBOutlet NSOutlineView *outlineView;   
    
    BundleSource *baseBundleSource;    

    // Array of ImportDiffItem objects.
    NSArray *items;
    
    // Tree:
    // operation -> array of ImportDiffItem
    AZPathNode *root;
        
    // Description used to export
    NSMutableString    *mDescription;
}

@property (strong) NSArray *items;
@property (strong) BundleSource *baseBundleSource;    

- (IBAction)export:(id)sender;

@end
