//
//  Console.h
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#define CONSOLE_ALL            0    // For display: display all type of items

#define CONSOLE_LOG            1    // Log - only for information
#define CONSOLE_WARNING        2    // Warning - can continue without problem
#define CONSOLE_ERROR        3    // Error - can continue but must be reported to the user (may cause problem)
#define CONSOLE_FATAL        4    // Exception - has to stop and report to the user
#define CONSOLE_OPERATION    5    // Operation name - used to separate errors

#define CONSOLE_ROOT    @"root"

@class Stack;
@class ConsoleItem;

@interface Console : NSObject <NSCoding>
{
    ConsoleItem  *mRootItem;
    Stack        *mCurrentItemStack;
    
    int           mDeleteOldDays;
    int           mWarningsCount;
    int           mErrorsCount;
    
    NSUInteger    mIndexMark;
}

- (void)removeAllItems;

- (void)setDeleteOldDays:(int)value;
- (int)deleteOldDays;
- (void)deleteItemOldDays;

- (void)beginOperation:(NSString *)name class:(Class)class;
- (void)addLog:(NSString *)log class:(Class)class;
- (void)addWarning:(NSString *)warning description:(NSString *)description class:(Class)class;
- (void)addError:(NSString *)error description:(NSString *)description class:(Class)class;
- (void)endOperation;

- (NSUInteger)numberOfItems;
- (ConsoleItem *)itemAtIndex:(int)index;

- (NSUInteger)numberOfItemsOfType:(NSInteger)type;
- (ConsoleItem *)itemOfType:(NSInteger)type atIndex:(NSUInteger)index;
- (NSArray *)itemsOfType:(NSInteger)type range:(NSRange)r;
- (NSArray *)allItemsOfStrictType:(NSInteger)type range:(NSRange)r;
- (void)deleteItem:(ConsoleItem *)item;

- (void)resetWarningsAndErrorsCount;
- (int)numberOfWarnings;
- (int)numberOfErrors;
- (BOOL)hasWarningsOrErrors;

- (void)mark;
- (NSUInteger)indexMark;

// Returns an array of ConsoleItem since the last time the console was marker using [self mark].
- (NSArray *)allItemsSinceMark;

@end
