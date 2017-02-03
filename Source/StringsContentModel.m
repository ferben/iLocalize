//
//  StringsContentModel.m
//  iLocalize
//
//  Created by Jean on 11/13/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "StringsContentModel.h"
#import "StringModel.h"
#import "Constants.h"

@interface StringsContentModel (Cache)
- (void)rebuildCache;
@end

@implementation StringsContentModel

+ (void)initialize
{
    if (self == [StringsContentModel class])
    {
        [self setVersion:0];
    }
}

+ (StringsContentModel *)model
{
    return [[StringsContentModel alloc] init];
}

- (id)init
{
    if (self = [super init])
    {
        mStrings = [[NSMutableArray alloc] init];
        mCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        mStrings = [coder decodeObject];
        mCache = [[NSMutableDictionary alloc] init];
        [self rebuildCache];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:mStrings];
}

- (void)addToCache:(StringModel *)sm
{
    mCache[[sm key]] = sm;
}

- (void)rebuildCache
{
    [mCache removeAllObjects];
    
    for (id loopItem in mStrings)
    {
        [self addToCache:loopItem];
    }    
}

- (void)setStringModels:(NSArray *)models
{
    [mStrings setArray:models];
    [self rebuildCache];
}

- (void)addStringModel:(StringModel *)sm
{
    [mStrings addObject:sm];
    [self addToCache:sm];
}

- (void)removeAllStrings
{
    [mStrings removeAllObjects];
    [mCache removeAllObjects];
}

- (NSEnumerator *)stringsEnumerator
{
    return [mStrings objectEnumerator];
}

- (NSUInteger)numberOfStrings
{
    return [mStrings count];
}

- (StringModel *)stringModelAtIndex:(NSUInteger)index
{
    return mStrings[index];
}

- (StringModel *)findStringModelForKey:(NSString *)key
{
    StringModel *model;
    
    for (model in mStrings)
    {
        if ([[model key] isEqualToString:key])
            return model;
    }
    
    return nil;        
}

- (StringModel *)stringModelForKey:(NSString *)key
{
    StringModel *sm = mCache[key];
    return sm;
}

- (void)sortByKeys
{
    [mStrings sortUsingSelector:@selector(compareKeys:)];    
}

- (id)copyWithZone:(NSZone *)zone
{
    StringsContentModel *newModel = [[StringsContentModel alloc] init];
    newModel->mStrings = [mStrings mutableCopy];
    
    return newModel;
}

- (BOOL)isEqual:(id)object
{
    return [mStrings isEqualToArray:((StringsContentModel *)object)->mStrings];
}

- (NSUInteger)hash
{
    return [mStrings hash];
}

- (NSMutableArray *)strings
{
    return mStrings;
}

- (NSString *)description
{
    return [mStrings description];
}

@end
