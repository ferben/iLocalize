//
//  AZCache.h
//  iLocalize
//
//  Created by Jean on 6/8/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@interface AZCache : NSObject {
	NSMutableDictionary *mTimeBasedSizeDic;
	NSMutableDictionary *mContentDic;
	int mCacheSize;
}
- (void)setCacheSize:(int)size;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (NSArray*)allValues;
@end
