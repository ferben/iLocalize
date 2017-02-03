//
//  AZListSelectionView.h
//  iLocalize
//
//  Created by Jean Bovet on 3/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@protocol AZListSelectionViewDelegate

/**
 Invoked when the selection of any item changes.
 @param noSelection YES if no elements are selected
 */
- (void)elementsSelectionChanged:(BOOL)noSelection;

@end

@protocol AZListSelectionViewItem

- (id)objectForKeyedSubscript:(id)key;
- (id)objectForKey:(NSString*)key;
- (void)setObject:(id)object forKey:(NSString*)key;

@end

@interface AZListSelectionView : NSObject<NSOutlineViewDataSource,NSOutlineViewDelegate> {
    NSArray *elements;
}

@property (weak) id<AZListSelectionViewDelegate> delegate;

@property (weak) NSOutlineView *outlineView;

/**
 An array of AZListSelectionViewItem. Each AZListSelectionViewItem contains a key that identifies the column and a value for
 the content of the column.
 */
@property (strong) NSArray *elements;

/**
 Returns the name of the key that will store the selection information in the dictionary of each element.
 */
+ (NSString*)selectedKey;

/**
 Returns the name of the key that will store an optional image to be used in the first column of the outline view.
 */
+ (NSString*)imageKey;

/**
 Reload the data.
 */
- (void)reloadData;

/**
 Returns an array of dictionary for all the selected elements.
 */
- (NSArray*)selectedElements;

@end
