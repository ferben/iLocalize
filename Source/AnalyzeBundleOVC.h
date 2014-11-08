//
//  NewProjectAnalyzeBundle.h
//  iLocalize
//
//  Created by Jean on 6/11/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class AZPathNode;

@interface AnalyzeBundleOVC : OperationViewController {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSButton *revealButton;
	IBOutlet NSButton *copyToClipboardButton;
    NSString *rootPath;
	NSArray *problems;
    AZPathNode *rootNode;
}

@property (strong) NSString *rootPath;
@property (strong) NSArray *problems;

- (IBAction)copyToClipboard:(id)sender;
- (IBAction)revealInFinder:(id)sender;

@end
