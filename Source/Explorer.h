//
//  Explorer.h
//  iLocalize3
//
//  Created by Jean on 17.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerItem.h"
#import "ExplorerFilter.h"
#import "ExplorerDelegate.h"

#import "ProjectProvider.h"

@class StringController;

@interface Explorer : NSObject
{
    id <ExplorerDelegate>   mDelegate;
    
    ExplorerItem           *_rootItem;
}

@property (strong) ExplorerItem *rootItem;
@property (weak) id<ProjectProvider> projectProvider;

- (void)setDelegate:(id)delegate;

- (ExplorerItem *)allItem;

- (ExplorerItem *)itemForFilter:(ExplorerFilter *)filter;

- (BOOL)createSmartFilter:(ExplorerFilter *)filter;
- (void)deleteItem:(ExplorerItem *)item;

- (void)revalidateFindStringWrappersForStringController:(StringController *)sc;
- (void)removeFindStringWrappersForStringController:(StringController *)sc;

- (void)rebuild;

- (void)explorerFilterDidAdd:(ExplorerFilter *)filter;
- (void)explorerFilterDidChange:(ExplorerFilter *)filter;
- (void)explorerFilterDidRemove:(ExplorerFilter *)filter;

@end
