//
//  XMLStringsEngine.h
//  iLocalize
//
//  Created by Jean on 9/7/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

@class StringsContentModel;

@interface XMLStringsEngine : NSObject<NSXMLParserDelegate> {
    Class mModelClass;
    NSString *mKey;
    NSString *mValue;
    NSMutableString *mContent;
    int mContentHeaders;
    BOOL mParsingKey;
    BOOL mParsingContent;
    StringsContentModel *mEntries;
    int mFormat;
}
+ (BOOL)canHandleContent:(NSString*)c;
- (StringsContentModel*)parseText:(NSString*)text modelClass:(Class)c;
- (int)format;
@end
