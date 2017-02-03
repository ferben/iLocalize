//
//  OperationErrorViewController.h
//  iLocalize
//
//  Created by Jean Bovet on 3/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"

@class TableViewCustom;

@interface OperationErrorViewController : OperationViewController<NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSImageView *imageView;
    IBOutlet NSTextField *infoField;
    IBOutlet NSTextView *textView;
    IBOutlet TableViewCustom *tableView;
    
    NSMutableArray *items;

    BOOL lastOperation;
    BOOL hasErrors;
}
@property BOOL lastOperation;
- (void)addErrors:(NSArray*)errors;
- (void)addWarnings:(NSArray*)warnings;
@end
