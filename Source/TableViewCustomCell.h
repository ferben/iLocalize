//
//  TableViewCustomCell.h
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class LayoutManagerCustom;
@class FindContentMatching;

@interface TableViewCustomCell : NSCell {
	NSTextStorage *mTextStorage;
	NSTextContainer *mTextContainer;
	LayoutManagerCustom *mLayoutManager;
		
	BOOL showInvisibleCharacters;
	
	FindContentMatching *contentMatching;
	int contentMatchingItem;	
}

@property (strong) NSColor *foregroundColor;
@property (strong) NSString *value;
@property BOOL showInvisibleCharacters;
@property (strong) FindContentMatching *contentMatching;
@property (assign) int contentMatchingItem;

+ (TableViewCustomCell*)cell;
+ (TableViewCustomCell*)textCell;

- (void)awake;

- (float)heightForWidth:(float)width defaultHeight:(float)height;

@end
