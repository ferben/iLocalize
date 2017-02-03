//
//  StringsContentModel.h
//  iLocalize
//
//  Created by Jean on 11/13/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

@class StringModel;

@interface StringsContentModel : NSObject
{
    NSMutableArray *mStrings;
    NSMutableDictionary *mCache;
}
+ (StringsContentModel *)model;
- (void)setStringModels:(NSArray *)models;
- (void)addStringModel:(StringModel *)sm;
- (void)removeAllStrings;
- (NSEnumerator *)stringsEnumerator;
- (NSUInteger)numberOfStrings;
- (StringModel *)stringModelAtIndex:(NSUInteger)index;
- (StringModel *)stringModelForKey:(NSString *)key;
- (void)sortByKeys;
- (NSMutableArray *)strings;
@end
