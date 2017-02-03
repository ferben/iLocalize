//
//  FileModelAttributes.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class StringEncoding;

@interface FileModelAttributes : NSObject <NSCoding>
{
	NSMutableDictionary		*mAttributes;
}

- (void)setRelativeFilePath:(NSString *)file;
- (NSString *)relativeFilePath;

- (NSString *)filename;
- (NSString *)language;

- (void)setModificationDate:(NSDate *)date;
- (NSDate *)modificationDate;

- (void)setStatus:(unsigned char)status;
- (unsigned char)status;

- (void)setIgnore:(BOOL)flag;
- (BOOL)ignore;

- (void)setEOLType:(NSUInteger)type;
- (int)eolType;

- (void)setFormat:(NSUInteger)format;
- (int)format;

- (void)setLocal:(BOOL)flag;
- (BOOL)isLocal;

- (void)setHasEncoding:(BOOL)flag;
- (BOOL)hasEncoding;

- (void)setEncoding:(StringEncoding *)encoding;
- (StringEncoding *)encoding;

- (void)setLabelIndexes:(NSSet *)indexes;
- (NSSet *)labelIndexes;

- (void)setAuxiliaryData:(id)data forKey:(NSString *)key;
- (id)auxiliaryDataForKey:(NSString *)key;

@end
