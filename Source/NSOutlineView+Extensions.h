//
//  NSOutlineView+Extensions.h
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface NSOutlineView (iLocalize)
- (id)selectedItem;
- (NSArray*)selectedItems;
- (id)rootItemOfItem:(id)item;
@end
