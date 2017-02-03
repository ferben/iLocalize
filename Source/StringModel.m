//
//  StringModel.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "StringModel.h"
#import "Constants.h"

static NSString *LOCK = @"lock";
static NSString *STATUS = @"status";
static NSString *LABELS = @"labels";

static NSString *COMMENT_STRING = @"comment_string";
static NSString *COMMENT_TYPE = @"comment_type";
static NSString *COMMENT_ROW = @"comment_row";

// New key to hold the array of comments when more than one is present (version >= 4.2)
static NSString *COMMENTS = @"comments";

static NSString *KEY_STRING = @"key_string";
static NSString *KEY_TYPE = @"key_type";
static NSString *KEY_ROW = @"key_row";

static NSString *VALUE_STRING = @"value_string";
static NSString *VALUE_TYPE = @"value_type";
static NSString *VALUE_ROW = @"value_row";

@implementation StringModel

+ (void)initialize
{
    if (self == [StringModel class])
    {
        [self setVersion:0];
    }
}

+ (StringModel *)model
{
    return [[StringModel alloc] init];
}

- (id)init
{
    if (self = [super init])
    {
        mAttributes = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        mAttributes = [coder decodeObject];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:mAttributes];
}

- (id)copyWithZone:(NSZone *)zone
{
    StringModel *newModel = [[StringModel alloc] init];
    newModel->mAttributes = [mAttributes mutableCopy];
    return newModel;
}

- (void)setLock:(BOOL)lock
{
    mAttributes[LOCK] = @(lock);    
}

- (BOOL)lock
{
    if ([self valueType] == STRING_OLDSTYLE)
    {
        // old-style value are currently locked to avoid editing because otherwhise
        // the "transformer" bound to the cell will escape this string which we don't want.
        // In the future, we might give more context to the "transformer" to avoid escaping
        // old-style value.
        return YES;
    }
    else
    {
        return [mAttributes[LOCK] boolValue];        
    }
}

- (void)setStatus:(unsigned char)status
{
    mAttributes[STATUS] = @(status);    
}

- (unsigned char)status
{
    id status = mAttributes[STATUS];
    
    if (status)
        return [status unsignedCharValue];
    else
        // HACK
        return (1 << STRING_STATUS_NONE);
}

- (void)setLabelIndexes:(NSSet *)indexes
{
    mAttributes[LABELS] = indexes;
}

- (NSSet*)labelIndexes
{
    NSMutableSet *indexes = mAttributes[LABELS];
    
    if (indexes == nil)
    {
        indexes = [[NSMutableSet alloc] init];
        mAttributes[LABELS] = indexes;
    }
    
    return indexes;
}

- (void)setComment:(NSString *)comment
{
    mAttributes[COMMENT_STRING] = comment?comment:@"";
}

- (void)setComment:(NSString *)comment as:(NSUInteger)type atRow:(NSUInteger)row
{    
    [self setComment:comment];
    mAttributes[COMMENT_TYPE] = [NSNumber numberWithInteger:type];
    mAttributes[COMMENT_ROW] = @(row);
}

- (void)addComment:(NSString *)comment as:(unsigned)type atRow:(int)row
{
    if (nil == mAttributes[COMMENT_STRING])
    {
        [self setComment:comment as:type atRow:row];
    }
    else
    {
        // If more than one comment is added, then the last comment added
        // will be the one stored in the old place and the previous ones in
        // the additional array
        NSMutableArray *comments = mAttributes[COMMENTS];
        
        if (nil == comments)
        {
            comments = [NSMutableArray array];
            mAttributes[COMMENTS] = comments;
        }
        
        // Store the previous comment in the array of comments
        NSMutableDictionary *cdic = [NSMutableDictionary dictionary];
        cdic[COMMENT_STRING] = mAttributes[COMMENT_STRING];
        cdic[COMMENT_TYPE] = mAttributes[COMMENT_TYPE];
        cdic[COMMENT_ROW] = mAttributes[COMMENT_ROW];
        [comments addObject:cdic];
        
        // Store the current comment in the usual place
        [self setComment:comment as:type atRow:row];
    }
}

- (void)enumerateComments:(StringModelCommentBlock)block
{
    for (NSDictionary *cdic in mAttributes[COMMENTS])
    {
        block(cdic[COMMENT_STRING], [cdic[COMMENT_TYPE] intValue], [cdic[COMMENT_ROW] intValue]);
    }
    
    block(mAttributes[COMMENT_STRING], [mAttributes[COMMENT_TYPE] intValue], [mAttributes[COMMENT_ROW] intValue]);
}

- (void)setKey:(NSString*)key
{
    mAttributes[KEY_STRING] = key?key:@"";    
}

- (void)setKey:(NSString *)key as:(NSUInteger)type atRow:(NSUInteger)row
{
    [self setKey:key];
    mAttributes[KEY_TYPE] = [NSNumber numberWithInteger:type];
    mAttributes[KEY_ROW] = @(row);    
}

- (void)setValue:(NSString *)value as:(NSUInteger)type atRow:(NSUInteger)row
{
    [self setValue:value];
    mAttributes[VALUE_TYPE] = [NSNumber numberWithInteger:type];
    mAttributes[VALUE_ROW] = @(row);    
}

- (void)setValue:(NSString *)value
{
    mAttributes[VALUE_STRING] = (value) ? value : @"";
}

- (int)commentRow
{
    return [mAttributes[COMMENT_ROW] intValue];
}

- (int)keyRow
{
    return [mAttributes[KEY_ROW] intValue];
}

- (int)valueRow
{
    return [mAttributes[VALUE_ROW] intValue];
}

- (void)setCommentType:(int)type
{
    mAttributes[COMMENT_TYPE] = @(type);        
}

- (int)commentType
{
    return [mAttributes[COMMENT_TYPE] intValue];    
}

- (int)keyType
{
    return [mAttributes[KEY_TYPE] intValue];    
}

- (int)valueType
{
    return [mAttributes[VALUE_TYPE] intValue];    
}

- (NSString *)comment
{
    return mAttributes[COMMENT_STRING];
}

- (NSString *)key
{
    return mAttributes[KEY_STRING];
}

- (NSString *)value
{
    return mAttributes[VALUE_STRING];
}

- (NSDictionary *)attributes
{
    return mAttributes;
}

- (BOOL)isEqual:(id)model
{
    return [mAttributes isEqualToDictionary:[(StringModel *)model attributes]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key = \"%@\", value = \"%@\", comment = \"%@\"", [self key], [self value], [self comment]];
}

- (NSComparisonResult)compareKeys:(id)other
{
    return [[self key] compare:[other key]];
}

@end
