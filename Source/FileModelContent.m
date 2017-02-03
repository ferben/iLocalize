//
//  FileModelContent.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "FileModelContent.h"
#import "StringsContentModel.h"

@implementation FileModelContent

+ (void)initialize
{
    if(self == [FileModelContent class]) {
        [self setVersion:0];
    }
}

+ (id)content
{
    return [[self alloc] init];
}

- (id)init
{
    if(self = [super init]) {
        mContent = NULL;
        // This flag indicates, if true, that the content should not be saved inside the project but
        // directly into its corresponding file (like RTF, etc).
        mNonPersistentContent = NO;
    }
    return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
    if(self = [super init]) {
        mContent = [coder decodeObject];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    if(mNonPersistentContent)
        [coder encodeObject:NULL];
    else
        [coder encodeObject:mContent];
}

- (id)copyWithZone:(NSZone*)zone
{
    FileModelContent *newContent = [[FileModelContent alloc] init];
    [newContent setNonPersistentContent:[self nonPersistentContent]];
    return newContent;
}

- (void)setNonPersistentContent:(BOOL)flag
{
    mNonPersistentContent = flag;
}

- (BOOL)nonPersistentContent
{
    return mNonPersistentContent;
}

- (void)setContent:(id)content
{
    mContent = content;
}

- (BOOL)hasContent
{
    return mContent != nil;
}

- (id)content
{
    return mContent;
}

- (StringsContentModel*)stringsContent
{
    if(![mContent isKindOfClass:[StringsContentModel class]]) {
        // Transform the array into the more specific strings content class
        NSArray *oldContent = mContent;
        mContent = [[StringsContentModel alloc] init];
        [mContent setStringModels:oldContent];
    }
    
    return mContent;
}

- (NSString*)description
{
    return [mContent description];
}

@end
