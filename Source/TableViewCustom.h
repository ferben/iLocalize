//
//  TableViewCustom.h
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class TableViewCustomDefaultDelegate;
@class TableViewCustomRowHeightCache;
#import "TextViewCustom.h"

@interface TableViewCustom : NSTableView<TextViewCustomDelegate>
{
    TableViewCustomDefaultDelegate  *mDefaultDelegate;
    TableViewCustomRowHeightCache   *rowHeightCache;
    BOOL                             mMouseDownTrigger;
    NSSize                           cachedSize;
    BOOL                             inRefreshRowHeight;
    
    // Text view for cell editing
    NSInteger                        editingRow,
                                     editingColumn;
    TextViewCustom                  *textView;
}

@property (readonly) TableViewCustomRowHeightCache *rowHeightCache;

- (void)setMouseDownTrigger:(BOOL)flag;
- (BOOL)mouseDownTrigger;

- (void)setSortDescriptorKey:(NSString *)key columnIdentifier:(NSString *)identifier;

- (float)computeHeightForRow:(NSInteger)row;

- (void)rowsHeightChanged;
- (void)rowsHeightChangedForRow:(NSInteger)row;
- (void)selectedRowsHeightChanged;

- (void)makeSelectedRowVisible;

@end
