//
//  StringModel.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#define COMMENT_SIMPLE		1
#define COMMENT_COMPLEX		2

#define STRING_QUOTED		1
#define STRING_IDENTIFIER	2
#define STRING_XML			3
#define STRING_OLDSTYLE		4

typedef void(^StringModelCommentBlock)(NSString *comment, unsigned type, int row);

@interface StringModel : NSObject <NSCoding> {
	NSMutableDictionary	*mAttributes;
}

+ (StringModel*)model;

- (void)setLock:(BOOL)lock;
- (BOOL)lock;

- (void)setStatus:(unsigned char)status;
- (unsigned char)status;

- (void)setLabelIndexes:(NSSet*)indexes;
- (NSSet*)labelIndexes;

- (void)setComment:(NSString*)comment;
- (void)setComment:(NSString*)comment as:(unsigned)type atRow:(int)row;
- (void)addComment:(NSString*)comment as:(unsigned)type atRow:(int)row;

- (void)setKey:(NSString*)key as:(unsigned)type atRow:(int)row;
- (void)setValue:(NSString*)value as:(unsigned)type atRow:(int)row;
- (void)setValue:(NSString*)value;

- (int)commentRow;
- (int)keyRow;
- (int)valueRow;

- (void)setCommentType:(int)type;
- (int)commentType;

- (int)keyType;
- (int)valueType;

- (NSString*)comment;
- (NSString*)key;
- (NSString*)value;

- (void)enumerateComments:(StringModelCommentBlock)block;
- (NSDictionary*)attributes;

- (NSComparisonResult)compareKeys:(id)other;

@end
