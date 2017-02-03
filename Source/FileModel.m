//
//  FileModel.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "FileModel.h"
#import "FileModelAttributes.h"
#import "FileModelContent.h"
#import "FileTool.h"

#import "LanguageModel.h"

@interface FileModel (PrivateMethods)
- (FileModelAttributes*)attributes;
@end

@implementation FileModel

+ (void)initialize
{
    if(self == [FileModel class]) {
        [self setVersion:0];
    }
}

+ (FileModel*)modelWithRelativeFilePath:(NSString*)file
{
    FileModel *model = [[FileModel alloc ] init];
    [model setRelativeFilePath:file];
    return model;
}

- (id)init
{
    if(self = [super init]) {
        mAttributes = [[FileModelAttributes alloc] init];
        mContent = [[FileModelContent alloc] init];
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
    if(self = [super init]) {
        mAttributes = [coder decodeObject];
        mContent = [coder decodeObject];        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:mAttributes];
    [coder encodeObject:mContent];
}

- (void)setLanguageModel:(LanguageModel*)lm
{
    mLanguageModel = lm;
}

- (BOOL)isEqual:(id)model
{
    return [mAttributes isEqual:[(FileModel*)model attributes]];
}

@end

@implementation FileModel (Attributes)

- (void)setRelativeFilePath:(NSString*)file
{
    [mLanguageModel removeFromCache:self];
    [mAttributes setRelativeFilePath:file];
    [mLanguageModel addToCache:self];
}

- (NSString*)relativeFilePath
{
    return [mAttributes relativeFilePath];
}

- (NSString*)filename
{
    return [mAttributes filename];
}

- (NSString*)language
{
    return [mAttributes language];
}

- (void)setModificationDate:(NSDate*)date
{
    [mAttributes setModificationDate:date];
}

- (NSDate*)modificationDate
{
    return [mAttributes modificationDate];
}

- (void)setStatus:(unsigned char)status
{
    [mAttributes setStatus:status];
}

- (unsigned char)status
{
    return [mAttributes status];
}

- (void)setIgnore:(BOOL)flag
{
    [mAttributes setIgnore:flag];
}

- (BOOL)ignore
{
    return [mAttributes ignore];
}

- (void)setEOLType:(NSUInteger)type
{
    [mAttributes setEOLType:type];
}

- (NSUInteger)eolType
{
    return [mAttributes eolType];
}

- (void)setFormat:(NSUInteger)format
{
    [mAttributes setFormat:format];    
}

- (NSUInteger)format
{
    return [mAttributes format];
}

- (void)setLocal:(BOOL)flag
{
    [mAttributes setLocal:flag];    
}

- (BOOL)isLocal
{
    return [mAttributes isLocal];    
}

- (void)setHasEncoding:(BOOL)flag
{
    [mAttributes setHasEncoding:flag];
}

- (BOOL)hasEncoding
{
    return [mAttributes hasEncoding];
}

- (void)setEncoding:(StringEncoding*)encoding
{
    [mAttributes setEncoding:encoding];
}

- (StringEncoding*)encoding
{
    return [mAttributes encoding];
}

- (void)setLabelIndexes:(NSSet*)indexes
{
    [mAttributes setLabelIndexes:indexes];
}

- (NSSet*)labelIndexes
{
    return [mAttributes labelIndexes];
}

- (void)setAuxiliaryData:(id)data forKey:(NSString*)key
{
    [mAttributes setAuxiliaryData:data forKey:key];
}

- (id)auxiliaryDataForKey:(NSString*)key
{
    return [mAttributes auxiliaryDataForKey:key];
}

- (FileModelAttributes*)attributes
{
    return mAttributes;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ [%@ - %@, local=%d]", [super description], [self relativeFilePath], [self filename], [self isLocal]];
}

@end

@implementation FileModel (Content)

- (void)setFileModelContent:(FileModelContent*)content
{
    mContent = content;
}

- (FileModelContent*)fileModelContent
{
    return mContent;
}

@end
