//
//  AZCache.m
//  iLocalize
//
//  Created by Jean on 6/8/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "AZCache.h"


@interface AZDateEntry : NSObject {
    id    mKey;
    NSDate *mAccessDate;
}
+ (AZDateEntry*)entryWithKey:(id)key;
- (void)setKey:(id)key;
@end

@implementation AZDateEntry

+ (AZDateEntry*)entryWithKey:(id)key
{
    AZDateEntry *entry = [[AZDateEntry alloc] init];
    [entry setKey:key];
    return entry;
}

- (id)init
{
    if(self = [super init]) {
        mAccessDate = [NSDate date];
        mKey = nil;
    }
    return self;
}


- (void)setKey:(id)key
{
    mKey = key;
}

- (id)key
{
    return mKey;
}

- (void)access
{
    mAccessDate = [NSDate date];
}

- (NSDate*)date
{
    return mAccessDate;
}

- (NSComparisonResult)compare:(id)other
{
    return [mAccessDate compare:[other date]];
}

@end

@implementation AZCache

- (id)init
{
    if(self = [super init]) {
        mTimeBasedSizeDic = [[NSMutableDictionary alloc] init];
        mContentDic = [[NSMutableDictionary alloc] init];
        mCacheSize = 10;
    }
    return self;
}


- (void)setCacheSize:(int)size
{
    mCacheSize = size;
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    mContentDic[aKey] = anObject;
    
    mTimeBasedSizeDic[aKey] = [AZDateEntry entryWithKey:aKey];    
    NSArray *sortedKeys = [mTimeBasedSizeDic keysSortedByValueUsingSelector:@selector(compare:)];
    int deleteCount = [sortedKeys count] - mCacheSize;
    if(deleteCount > 0) {
        int i;
        for(i=0; i<deleteCount; i++) {
            id removeKey = [sortedKeys firstObject];
            [mTimeBasedSizeDic removeObjectForKey:removeKey];
            [mContentDic removeObjectForKey:removeKey];
        }
    }
}

- (id)objectForKey:(id)aKey
{
    [mTimeBasedSizeDic[aKey] access];
    return mContentDic[aKey];
}

- (NSArray*)allValues
{
    return [mContentDic allValues];
}

@end

