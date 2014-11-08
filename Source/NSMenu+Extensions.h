//
//  NSMenu+Extensions.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface NSMenu (iLocalize)
- (void)setMenuItemsState:(int)state;
- (void)setMenuItemState:(int)state atIndex:(int)index;
- (void)setMenuItemState:(int)state withTag:(int)tag;
@end
