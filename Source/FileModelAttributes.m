//
//  FileModelAttributes.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "FileModelAttributes.h"
#import "LanguageTool.h"
#import "StringEncoding.h"

static NSString*    ATTRIBUTE_RELATIVE_PATH    = @"ATTRIBUTE_RELATIVE_PATH";
static NSString*    ATTRIBUTE_FILENAME    = @"ATTRIBUTE_FILENAME";
static NSString*    ATTRIBUTE_LANGUAGE    = @"ATTRIBUTE_LANGUAGE";
static NSString*    ATTRIBUTE_MODIFICATION_DATE    = @"ATTRIBUTE_MODIFICATION_DATE";
static NSString*    ATTRIBUTE_STATUS    = @"ATTRIBUTE_STATUS";
static NSString*    ATTRIBUTE_IGNORE    = @"ATTRIBUTE_IGNORE";
static NSString*    ATTRIBUTE_EOL    = @"ATTRIBUTE_EOL";
static NSString*    ATTRIBUTE_FORMAT    = @"ATTRIBUTE_FORMAT";
static NSString*    ATTRIBUTE_LOCAL    = @"ATTRIBUTE_LOCAL";
static NSString*    ATTRIBUTE_ENCODING = @"ATTRIBUTE_ENCODING";
static NSString*    ATTRIBUTE_HAS_ENCODING = @"ATTRIBUTE_HAS_ENCODING";
static NSString*    ATTRIBUTE_LABELS = @"ATTRIBUTE_LABELS";
static NSString*    ATTRIBUTE_AUXILIARY    = @"ATTRIBUTE_AUXILIARY";

@interface FileModelAttributes (PrivateMethods)
- (void)setPath:(NSString*)path;
- (void)setFileName:(NSString*)filename;
- (void)setLanguage:(NSString*)language;
@end

@implementation FileModelAttributes

+ (void)initialize
{
    if(self == [FileModelAttributes class]) {
        [self setVersion:0];
    }
}

- (id)init
{
    if(self = [super init]) {
        mAttributes = [[NSMutableDictionary alloc] init];
        
        [self setModificationDate:[NSDate date]];
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
    if(self = [super init]) {
        mAttributes = [coder decodeObject];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:mAttributes];
}

- (void)setRelativeFilePath:(NSString*)file
{
    mAttributes[ATTRIBUTE_RELATIVE_PATH] = file;

    [self setFileName:[file lastPathComponent]];
    [self setLanguage:[LanguageTool languageOfFile:file]];
}

- (NSString*)relativeFilePath
{
    return mAttributes[ATTRIBUTE_RELATIVE_PATH];
}

- (void)setFileName:(NSString*)filename
{
    mAttributes[ATTRIBUTE_FILENAME] = filename;    
}

- (NSString*)filename
{
    return mAttributes[ATTRIBUTE_FILENAME];
}

- (void)setLanguage:(NSString*)language
{
    mAttributes[ATTRIBUTE_LANGUAGE] = language;    
}

- (NSString*)language
{
    return mAttributes[ATTRIBUTE_LANGUAGE];
}

- (void)setModificationDate:(NSDate*)date
{
    if(date)
        mAttributes[ATTRIBUTE_MODIFICATION_DATE] = date;
}

- (NSDate*)modificationDate
{
    return mAttributes[ATTRIBUTE_MODIFICATION_DATE];
}

- (void)setStatus:(unsigned char)status
{
    mAttributes[ATTRIBUTE_STATUS] = @(status);
}

- (unsigned char)status
{
    return [mAttributes[ATTRIBUTE_STATUS] unsignedCharValue];
}

- (void)setIgnore:(BOOL)flag
{
    mAttributes[ATTRIBUTE_IGNORE] = @(flag);
}

- (BOOL)ignore
{
    NSNumber *ignore = mAttributes[ATTRIBUTE_IGNORE];
    if(ignore)
        return [ignore boolValue];
    else
        return NO;
}

- (void)setEOLType:(NSUInteger)type
{
    mAttributes[ATTRIBUTE_EOL] = @(type);
}

- (int)eolType
{
    return [mAttributes[ATTRIBUTE_EOL] intValue];
}

- (void)setFormat:(NSUInteger)format
{
    mAttributes[ATTRIBUTE_FORMAT] = @(format);    
}

- (int)format
{
    return [mAttributes[ATTRIBUTE_FORMAT] intValue];    
}

- (void)setLocal:(BOOL)flag
{
    mAttributes[ATTRIBUTE_LOCAL] = @(flag);    
}

- (BOOL)isLocal
{
    return [mAttributes[ATTRIBUTE_LOCAL] boolValue];        
}

- (void)setHasEncoding:(BOOL)flag
{
    mAttributes[ATTRIBUTE_HAS_ENCODING] = @(flag);
}

- (BOOL)hasEncoding
{
    return [mAttributes[ATTRIBUTE_HAS_ENCODING] boolValue];
}

- (void)setEncoding:(StringEncoding*)encoding
{
    mAttributes[ATTRIBUTE_ENCODING] = [encoding data];
}

- (StringEncoding*)encoding
{
    return [StringEncoding stringEncodingWithData:mAttributes[ATTRIBUTE_ENCODING]];
}

- (void)setLabelIndexes:(NSSet*)indexes
{
    mAttributes[ATTRIBUTE_LABELS] = indexes;
}

- (NSSet*)labelIndexes
{
    NSMutableSet *indexes = mAttributes[ATTRIBUTE_LABELS];
    if(indexes == nil) {
        indexes = [[NSMutableSet alloc] init];
        mAttributes[ATTRIBUTE_LABELS] = indexes;
    }
    return indexes;
}

- (void)setAuxiliaryData:(id)data forKey:(NSString*)key
{
    NSMutableDictionary *aux = mAttributes[ATTRIBUTE_AUXILIARY];
    if(aux == nil) {
        aux = [NSMutableDictionary dictionary];
        mAttributes[ATTRIBUTE_AUXILIARY] = aux;
    }
    
    if(data == nil)
        [aux removeObjectForKey:key];
    else
        aux[key] = data;
}

- (id)auxiliaryDataForKey:(NSString*)key
{
    return mAttributes[ATTRIBUTE_AUXILIARY][key];
}

- (NSDictionary*)attributes
{
    return mAttributes;
}

- (BOOL)isEqual:(id)model
{
    return [mAttributes isEqualToDictionary:[(FileModelAttributes*)model attributes]];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], mAttributes];
}

@end
