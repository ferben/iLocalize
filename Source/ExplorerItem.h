//
//  ExplorerItem.h
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class ExplorerFilter;

@class FileController;
@class StringController;

@interface ExplorerItem : NSObject
{
    NSString        *mTitle;
    NSImage         *mImage;
    BOOL             mSelectable;
    BOOL             mEditable;
    BOOL             mDeletable;
    BOOL             all;
    BOOL             group;
    ExplorerFilter  *mFilter;
    NSMutableArray  *_children;
}

@property BOOL all;
@property BOOL group;
@property (readonly) NSArray *children;

+ (ExplorerItem *)itemWithTitle:(NSString *)title;
+ (ExplorerItem *)groupItemWithTitle:(NSString *)title;

- (void)setImage:(NSImage *)image;
- (NSImage *)image;

- (void)setSelectable:(BOOL)flag;
- (BOOL)selectable;

- (void)setDeletable:(BOOL)flag;
- (BOOL)deletable;

- (void)setEditable:(BOOL)flag;
- (BOOL)editable;

- (void)setFilter:(ExplorerFilter *)filter;
- (ExplorerFilter *)filter;

- (void)setTitle:(NSString *)title;
- (NSString *)title;

- (void)addChild:(ExplorerItem *)child;
- (void)removeChild:(ExplorerItem *)child;

- (void)removeItem:(ExplorerItem *)item;

- (ExplorerItem *)itemForFilter:(ExplorerFilter *)filter;
- (NSIndexPath *)indexPathOfItem:(ExplorerItem *)item;

- (void)moveFiltersIdentifiedByFiles:(NSArray *)files toChildIndex:(int)index;
- (void)reorderByFilterFiles:(NSArray *)files;

@end
