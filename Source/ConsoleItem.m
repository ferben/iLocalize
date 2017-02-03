//
//  ConsoleItem.m
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ConsoleItem.h"
#import "Console.h"

static NSDateFormatter *dateFormatter = nil;

@implementation ConsoleItem

+ (void)initialize
{
    if (self == [ConsoleItem class])
    {
        [self setVersion:2];
    }
}

+ (ConsoleItem *)itemWithTitle:(NSString *)title
                   description:(NSString *)description
                         class:(Class)class
                          type:(long)bit
{
    ConsoleItem *item = [[ConsoleItem alloc] init];
    
    [item setTitle:title];
    [item setDescription:description];
    [item setTypeBit:bit];
    [item setClassName:NSStringFromClass(class)];
    
    return item;
}

- (id)init
{
    if (self = [super init])
    {
        mDate = [NSDate date];
        mTitle = NULL;
        mDescription = NULL;
        mType = 0;
        mClassName = NULL;
        
        mItems = [[NSMutableArray alloc] init];        
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    // Use the name of the class "hard-coded" instead of [self class] (to avoid subclass problem)
    NSInteger version = [coder versionForClassName:@"ConsoleItem"];
    
    if (self = [super init])
    {
        mDate = [coder decodeObject];
        
        if (version > 1)
            mTitle = [coder decodeObject];
        else
            mTitle = NULL;
        
        mDescription = [coder decodeObject];
        mType = [[coder decodeObject] unsignedCharValue];
        
        if (version > 0)
            mClassName = [coder decodeObject];
        else
            mClassName = NULL;
        
        mItems = [coder decodeObject];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:mDate];
    [coder encodeObject:mTitle];
    [coder encodeObject:mDescription];
    [coder encodeObject:@(mType)];
    [coder encodeObject:mClassName];
    [coder encodeObject:mItems];
}

- (void)setTitle:(NSString *)title
{
    mTitle = title;
}

- (NSString *)title
{
    return mTitle;
}

- (void)setDescription:(NSString *)description
{
    mDescription = description;
}

- (NSString *)description
{
    return mDescription;
}

- (NSDate *)date
{
    return mDate;
}

- (NSString *)dateDescription
{
    if (dateFormatter == NULL)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"%m/%d/%Y %H:%M:%S"];
    }
    
    return [dateFormatter stringForObjectValue:mDate];
}

- (NSString *)fullDescription
{
    if (mTitle && ![mTitle isEqualToString:mDescription])
    {
        return [NSString stringWithFormat:@"[%@] %@ : %@", [self dateDescription] , mTitle, mDescription];        
    }
    else
    {
        return [NSString stringWithFormat:@"[%@] %@", [self dateDescription] , mDescription];
    }
}

- (void)setTypeBit:(long)bit
{
    NSAssert(bit >= 0 && bit <= 7, @"ConsoleItem: * WARNING * cannot handle more than 8 bits");
    mType = 1 << bit;
}

- (unsigned char)type
{
    return mType;
}

- (void)setClassName:(NSString *)className
{
    mClassName = className;
}

- (NSString *)className
{
    return mClassName;
}

- (BOOL)isOperation
{
    return mType & (1 << CONSOLE_OPERATION);
}

- (BOOL)isWarning
{
    return mType & (1 << CONSOLE_WARNING);
}

- (BOOL)isError
{
    return mType & (1 << CONSOLE_ERROR) || mType & (1 << CONSOLE_FATAL);
}

- (void)addItem:(ConsoleItem *)item
{
    [mItems addObject:item]; 
}

- (void)removeAllItems
{
    [mItems removeAllObjects];
}

- (NSArray *)itemsOfType:(NSInteger)type items:(NSArray *)items
{
    if (type == CONSOLE_ALL)
        return items;
    
    BOOL showLog     = type & (1 << CONSOLE_LOG);
    BOOL showWarning = type & (1 << CONSOLE_WARNING);
    BOOL showError   = type & (1 << CONSOLE_ERROR);
        
    NSMutableArray *array = [NSMutableArray array];
    ConsoleItem *item;
    
    for (item in items)
    {
        int itemType = [item type];
        
        BOOL add = NO;

        if (showLog && (itemType & (1 << CONSOLE_LOG)))
            add = YES;

        if (showWarning && (itemType & (1 << CONSOLE_WARNING)))
            add = YES;
        
        if (showError && (    (itemType & (1 << CONSOLE_ERROR))
                           || (itemType & (1 << CONSOLE_FATAL))
                         )
           )
        {
            add = YES;
        }
        
        if ((itemType & (1 << CONSOLE_OPERATION)) || add)
            [array addObject:item];
    }
    
    return array;
}

- (NSArray *)itemsOfType:(long)type
{
    return [self itemsOfType:type items:mItems];
}

- (NSUInteger)numberOfItems
{
    return [mItems count];
}

- (ConsoleItem *)itemAtIndex:(NSUInteger)index
{
    return mItems[index];
}

- (NSUInteger)numberOfItemsOfType:(NSInteger)type
{
    return [[self itemsOfType:type] count];
}

- (ConsoleItem *)itemOfType:(NSInteger)type atIndex:(NSUInteger)index
{
    return [self itemsOfType:type][index];
}

- (NSArray *)itemsOfType:(NSInteger)type range:(NSRange)r
{
    return [self itemsOfType:type items:[mItems subarrayWithRange:r]];
}

- (BOOL)isItemOfStrictType:(NSInteger)type
{
    BOOL showLog       = type & (1 << CONSOLE_LOG);
    BOOL showWarning   = type & (1 << CONSOLE_WARNING);
    BOOL showError     = type & (1 << CONSOLE_ERROR);
    BOOL showOperation = type & (1 << CONSOLE_OPERATION);
    BOOL showAll       = type == CONSOLE_ALL;

    int itemType = [self type];
    
    BOOL match = NO;
    
    if (showLog && (itemType & (1 << CONSOLE_LOG)))
        match = YES;
    
    if (showWarning && (itemType & (1 << CONSOLE_WARNING)))
        match = YES;
    
    if (showError && (    (itemType & (1 << CONSOLE_ERROR))
                       || (itemType & (1 << CONSOLE_FATAL))
                     )
       )
    {
        match = YES;
    }
    
    if (showOperation && (itemType & (1 << CONSOLE_OPERATION)))
        match = YES;
    
    return showAll || match;
}

- (NSArray *)allItemsOfStrictType:(NSInteger)type
{
    NSMutableArray *array = [NSMutableArray array];
    ConsoleItem *item;
    
    for (item in mItems)
    {
        if ([item isItemOfStrictType:type])
        {
            [array addObject:item];
        }
        
        [array addObjectsFromArray:[item allItemsOfStrictType:type]];
    }
    
    return array;
}

- (NSArray *)allItemsOfStrictType:(NSInteger)type range:(NSRange)r
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *enumerator = [[mItems subarrayWithRange:r] objectEnumerator];
    ConsoleItem *item;
    
    while (item = [enumerator nextObject])
    {
        if ([item isItemOfStrictType:type])
        {
            [array addObject:item];
        }
        
        [array addObjectsFromArray:[item allItemsOfStrictType:type]];
    }
    
    return array;
}

- (void)deleteItem:(ConsoleItem *)item
{
    [mItems removeObject:item];
}

- (NSString *)textRepresentation
{
    NSMutableString *string = [NSMutableString string];
    
    if (![mDescription isEqualToString:CONSOLE_ROOT])
        [string appendFormat:@"[%@] %@", [self className], [self fullDescription]];
    
    ConsoleItem *item;
    
    for (item in mItems)
    {
        [string appendFormat:@"\n%@", [item textRepresentation]];
    }
    
    return string;
}

@end
