//
//  FileModel.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class FileModelAttributes;
@class FileModelContent;
@class LanguageModel;
@class StringEncoding;

@interface FileModel : NSObject <NSCoding>
{
	FileModelAttributes	*mAttributes;
	FileModelContent	*mContent;
	
	// volatile
	LanguageModel		*mLanguageModel;
}

+ (FileModel *)modelWithRelativeFilePath:(NSString *)file;

- (void)setLanguageModel:(LanguageModel *)lm;

@end

@interface FileModel (Attributes)

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
- (NSUInteger)eolType;

- (void)setFormat:(NSUInteger)format;
- (NSUInteger)format;

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

@interface FileModel (Content)

- (void)setFileModelContent:(FileModelContent *)content;
- (FileModelContent *)fileModelContent;

@end
