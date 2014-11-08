//
//  FileModelContent.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class StringsContentModel;

@interface FileModelContent : NSObject <NSCoding> {
	BOOL	mNonPersistentContent;
	id		mContent;
}

- (void)setNonPersistentContent:(BOOL)flag;
- (BOOL)nonPersistentContent;

- (void)setContent:(id)content;
- (BOOL)hasContent;
- (id)content;
- (StringsContentModel*)stringsContent;

@end
