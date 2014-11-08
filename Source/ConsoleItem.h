//
//  ConsoleItem.h
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@interface ConsoleItem : NSObject <NSCoding> {
	NSDate			*mDate;
	NSString		*mTitle;
	NSString		*mDescription;
	unsigned char	mType;
	NSString		*mClassName;
	
	NSMutableArray	*mItems;
}

+ (ConsoleItem*)itemWithTitle:(NSString*)title description:(NSString*)description class:(Class)class type:(long)bit;

- (void)setTitle:(NSString*)title;
- (NSString*)title;

- (void)setDescription:(NSString*)description;
- (NSString*)description;
- (NSDate*)date;
- (NSString*)dateDescription;
- (NSString*)fullDescription;

- (void)setTypeBit:(long)bit;
- (unsigned char)type;

- (void)setClassName:(NSString*)className;
- (NSString*)className;

- (BOOL)isOperation;
- (BOOL)isWarning;
- (BOOL)isError;

- (void)addItem:(ConsoleItem*)item;
- (void)removeAllItems;

- (int)numberOfItems;
- (ConsoleItem*)itemAtIndex:(int)index;

- (int)numberOfItemsOfType:(int)type;
- (ConsoleItem*)itemOfType:(int)type atIndex:(int)index;
- (NSArray*)itemsOfType:(int)type range:(NSRange)r;
- (NSArray*)allItemsOfStrictType:(int)type range:(NSRange)r;
- (void)deleteItem:(ConsoleItem*)item;

- (NSString*)textRepresentation;

@end
