//
//  Console.m
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "Console.h"
#import "ConsoleItem.h"
//#import "OperationReportWC.h"

#import "Stack.h"

#import "Preferences.h"

@implementation Console

+ (void)initialize
{
    if (self == [Console class])
    {
        [self setVersion:1];
    }
}

- (id)init
{
    if ((self = [super init]))
    {
        mRootItem = [[ConsoleItem alloc] init];
        [mRootItem setDescription:CONSOLE_ROOT];
        mCurrentItemStack = [[Stack alloc] init];
        mDeleteOldDays = 7;
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]))
    {
        NSInteger version = [coder versionForClassName:[self className]];

        mRootItem = [coder decodeObject];
        mCurrentItemStack = [coder decodeObject];
        
        if (version == 1)
            mDeleteOldDays = [[coder decodeObject] intValue];
        
        if (mRootItem == NULL)
        {
            mRootItem = [[ConsoleItem alloc] init];
            [mRootItem setDescription:CONSOLE_ROOT];
        }
        
        if (mCurrentItemStack)
        {
            // Clear stack in case an exception has occurred and the corresponding
            // endOperation method didn't get called (leaving open forever the beginOperation)
            [mCurrentItemStack clear];
        }
        else
            mCurrentItemStack = [[Stack alloc] init];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [self deleteItemOldDays];
    
    [coder encodeObject:mRootItem];
    [coder encodeObject:mCurrentItemStack];
    [coder encodeObject:@(mDeleteOldDays)];
}

- (void)addItem:(ConsoleItem *)item
{
    @synchronized(self)
    {
        if ([[Preferences shared] consoleDisplayUsingNSLog])
            NSLog(@"[Console] %@", item);
        
        ConsoleItem *currentItem = [mCurrentItemStack currentObject];
        
        if (currentItem)
            [currentItem addItem:item];
        else
            [mRootItem addItem:item];        
    }
}

- (void)removeAllItems
{
    @synchronized(self)
    {
        [mRootItem removeAllItems];
        [mCurrentItemStack clear];        
    }
}

- (void)setDeleteOldDays:(int)value
{
    mDeleteOldDays = value;
}

- (int)deleteOldDays 
{
    return mDeleteOldDays;    
}

- (void)deleteItemOldDays
{
    /* Delete only the top-item only */
    NSCalendarDate *limit = [NSCalendarDate calendarDate];
    limit = [limit dateByAddingYears:0 months:0 days:-[self deleteOldDays]
                               hours:-[limit hourOfDay]
                             minutes:-[limit minuteOfHour]
                             seconds:-[limit secondOfMinute]];
    NSUInteger i;
    
    for (i = [self numberOfItemsOfType:CONSOLE_ALL] - 1; i > 0; i--)
    {
        id item = [self itemOfType:CONSOLE_ALL atIndex:i];
        
        if ([limit compare:[item date]] == NSOrderedDescending)
        {
            [self deleteItem:item];
        }
    }
}

- (void)beginOperation:(NSString*)name class:(Class)class
{
    ConsoleItem *operationItem = [ConsoleItem itemWithTitle:name description:name class:class type:CONSOLE_OPERATION];
    [self addItem:operationItem];    
    [mCurrentItemStack pushObject:operationItem];
}

- (void)addLog:(NSString *)log class:(Class)class
{
    [self addItem:[ConsoleItem itemWithTitle:log description:log class:class type:CONSOLE_LOG]];
}

- (void)addWarning:(NSString *)warning description:(NSString *)description class:(Class)class
{
    mWarningsCount++;
    [self addItem:[ConsoleItem itemWithTitle:warning description:description class:class type:CONSOLE_WARNING]];
}

- (void)addError:(NSString *)error description:(NSString *)description class:(Class)class
{
    mErrorsCount++;
    [self addItem:[ConsoleItem itemWithTitle:error description:description class:class type:CONSOLE_ERROR]];
}

- (void)endOperation
{
    [mCurrentItemStack popObject];
}

- (NSUInteger)numberOfItems
{
    return [mRootItem numberOfItems];
}

- (ConsoleItem *)itemAtIndex:(int)index
{
    return [mRootItem itemAtIndex:index];
}

- (NSUInteger)numberOfItemsOfType:(NSInteger)type
{
    return [mRootItem numberOfItemsOfType:type];
}

- (ConsoleItem *)itemOfType:(NSInteger)type atIndex:(NSUInteger)index
{
    return [mRootItem itemOfType:type atIndex:index];
}

- (NSArray *)itemsOfType:(NSInteger)type range:(NSRange)r
{
    return [mRootItem itemsOfType:type range:r];
}

- (NSArray *)allItemsOfStrictType:(NSInteger)type range:(NSRange)r
{
    return [mRootItem allItemsOfStrictType:type range:r];
}

- (void)deleteItem:(ConsoleItem *)item
{
    [mRootItem deleteItem:item];
}

- (void)resetWarningsAndErrorsCount
{
    mWarningsCount = 0;
    mErrorsCount = 0;
}

- (int)numberOfWarnings
{
    return mWarningsCount;
}

- (int)numberOfErrors
{
    return mErrorsCount;
}

- (BOOL)hasWarningsOrErrors
{
    return mWarningsCount > 0 || mErrorsCount > 0;
}

- (void)mark
{
    mIndexMark = [self numberOfItems];
    [self resetWarningsAndErrorsCount];
}

- (NSUInteger)indexMark
{
    return mIndexMark;
}

- (NSArray *)allItemsSinceMark
{
    NSUInteger fromIndex = [self indexMark];
    NSUInteger toIndex = [self numberOfItems];
    
    return [self allItemsOfStrictType:(1 << CONSOLE_ERROR | 1 << CONSOLE_WARNING) range:NSMakeRange(fromIndex, toIndex - fromIndex)];
}

- (NSString*)description
{
    NSMutableString *string = [NSMutableString string];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y %H:%M:%S" allowNaturalLanguage:NO];
    [string appendFormat:@"Console Entries on %@\n", [dateFormatter stringForObjectValue:[NSDate date]]];
    [string appendString:[mRootItem textRepresentation]];    
    return string;
}

@end
